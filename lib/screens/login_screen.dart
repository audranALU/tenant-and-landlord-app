import 'package:flutter/material.dart';
import '../core/services/auth_service.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          child: const Text("Login Test User"),
          onPressed: () async {
            await _authService.signInWithEmail(
              "test@test.com",
              "Test123456",
            );
          },
        ),
      ),
    );
  }
}