import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  late final AuthService _authService;

  firebase_auth.User? _user;
  UserModel? _userModel; // holds the role
  bool _loadingRole = false;

  // Cache key for storing user role locally
  static const String _userRoleCacheKey = 'user_role_cache';
  static const String _userModelCacheKey = 'user_model_cache';

  firebase_auth.User? get user => _user;
  UserModel? get userModel => _userModel;
  String? get role => _userModel?.role;
  bool get loadingRole => _loadingRole;

  AuthProvider({AuthService? authService}) {
    _authService = authService ?? AuthService();
    _initializeFromCache();
    _authService.authStateChanges.listen((firebase_auth.User? user) async {
      _user = user;
      if (user != null) {
        await _loadUserRole(user.uid);
      } else {
        _userModel = null;
        _loadingRole = false;
        _clearCache();
        notifyListeners();
      }
    });
  }

  /// Load cached user data from local storage (fast startup)
  Future<void> _initializeFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_userModelCacheKey);
      if (cachedJson != null) {
        final Map<String, dynamic> data = json.decode(cachedJson);
        _userModel = UserModel.fromMap(data);
        notifyListeners();
      }
    } catch (e) {
      // Cache is corrupted or unavailable, ignore
    }
  }

  /// Save user data to local cache
  Future<void> _saveToCache(UserModel model) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userModelCacheKey, json.encode(model.toMap()));
    } catch (e) {
      // Failed to cache, but don't fail the login
    }
  }

  /// Clear cached user data
  Future<void> _clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userModelCacheKey);
      await prefs.remove(_userRoleCacheKey);
    } catch (e) {
      // Ignore cache clearing errors
    }
  }

  Future<void> _loadUserRole(String uid) async {
    // First, try to load from cache immediately for faster UI response
    // Then refresh from Firestore in the background
    _loadingRole = true;
    notifyListeners();

    try {
      final userModel = await _authService.getUserModel(uid);

      if (userModel != null) {
        _userModel = userModel;
        _saveToCache(userModel);
      } else {
        // User document doesn't exist, create it with default role
        await _authService.ensureUserProfile(
          uid: uid,
          email: _user?.email ?? "",
          name: _user?.displayName,
          role: "tenant",
        );

        _userModel = UserModel(
          uid: uid,
          email: _user?.email ?? "",
          name: _user?.displayName,
          role: "tenant",
        );
        _saveToCache(_userModel!);
      }
    } catch (e) {
      // If Firestore fails, try to use cached data
      // If no cache, use default tenant role
      _userModel ??= UserModel(
        uid: uid,
        email: _user?.email ?? "",
        name: _user?.displayName,
        role: "tenant",
      );
    } finally {
      _loadingRole = false;
      notifyListeners();
    }
  }

  /// REGISTER with role
  Future<String?> register({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    try {
      await _authService.createAccount(
        email: email,
        password: password,
        name: name,
        role: role,
      );
      return null; // success
    } on firebase_auth.FirebaseAuthException catch (e) {
      return _friendlyError(e.code);
    } catch (e) {
      return "Something went wrong. Please try again.";
    }
  }

  /// LOGIN with email
  Future<String?> loginEmail(String email, String password) async {
    try {
      await _authService.signInWithEmail(email, password);
      return null;
    } on firebase_auth.FirebaseAuthException catch (e) {
      return _friendlyError(e.code);
    } catch (e) {
      return "Something went wrong. Please try again.";
    }
  }

  /// LOGIN with Google
  Future<String?> loginGoogle() async {
    try {
      final result = await _authService.signInWithGoogle();
      if (result == null) return "Google sign-in cancelled.";
      return null;
    } catch (e) {
      return "Google sign-in failed. Please try again.";
    }
  }

  /// PASSWORD RESET
  Future<String?> sendPasswordReset(String email) async {
    try {
      await _authService.sendPasswordReset(email);
      return null;
    } on firebase_auth.FirebaseAuthException catch (e) {
      return _friendlyError(e.code);
    } catch (e) {
      return "Could not send reset email.";
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    _userModel = null;
    _clearCache();
    notifyListeners();
  }

  /// Convert Firebase error codes to friendly messages
  String _friendlyError(String code) {
    switch (code) {
      case "invalid-email":
        return "That email address looks invalid.";
      case "user-not-found":
        return "No account found with that email.";
      case "wrong-password":
      case "invalid-credential":
        return "Incorrect email or password.";
      case "email-already-in-use":
        return "An account already exists with that email.";
      case "weak-password":
        return "Password should be at least 6 characters.";
      default:
        return "Authentication error. Please try again.";
    }
  }
}