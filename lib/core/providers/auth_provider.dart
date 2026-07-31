import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  UserModel? _userModel; // holds the role
  bool _loadingRole = false;

  User? get user => _user;
  UserModel? get userModel => _userModel;
  String? get role => _userModel?.role;
  bool get loadingRole => _loadingRole;

  AuthProvider() {
    _authService.authStateChanges.listen((User? user) async {
      _user = user;
      if (user != null) {
        await _loadUserRole(user.uid);
      } else {
        _userModel = null;
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserRole(String uid) async {
    _loadingRole = true;
    notifyListeners();
    _userModel = await _authService.getUserModel(uid);
    _loadingRole = false;
    notifyListeners();
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
    } on FirebaseAuthException catch (e) {
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
    } on FirebaseAuthException catch (e) {
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
    } on FirebaseAuthException catch (e) {
      return _friendlyError(e.code);
    } catch (e) {
      return "Could not send reset email.";
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    _userModel = null;
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
