import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';


class AuthProvider extends ChangeNotifier {


  final AuthService _authService = AuthService();


  User? _user;


  User? get user => _user;



  AuthProvider(){

    _authService.authStateChanges.listen(
      (User? user){

        _user = user;

        notifyListeners();

      },
    );

  }



  Future<void> loginEmail(
      String email,
      String password,
      ) async {

    await _authService.signInWithEmail(
      email,
      password,
    );

  }



  Future<void> loginGoogle() async {

    await _authService.signInWithGoogle();

  }



  Future<void> logout() async {

    await _authService.signOut();

  }


}