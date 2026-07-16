import 'package:flutter/material.dart';
import '../core/services/auth_service.dart';
import 'register_screen.dart';


class LoginScreen extends StatefulWidget {

  const LoginScreen({super.key});


  @override
  State<LoginScreen> createState() => _LoginScreenState();

}


class _LoginScreenState extends State<LoginScreen> {


  final AuthService _authService = AuthService();


  final emailController = TextEditingController();
  final passwordController = TextEditingController();


  bool loading = false;


  Future<void> login() async {

    setState(() {
      loading = true;
    });


    await _authService.signInWithEmail(
      emailController.text.trim(),
      passwordController.text.trim(),
    );


    setState(() {
      loading = false;
    });

  }



  Future<void> googleLogin() async {

    setState(() {
      loading = true;
    });


    await _authService.signInWithGoogle();


    setState(() {
      loading = false;
    });

  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "Tenant & Landlord App",
        ),
      ),


      body: Padding(

        padding: const EdgeInsets.all(24),


        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,


          children: [


            const Text(
              "Login",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),


            const SizedBox(height: 30),



            TextField(

              controller: emailController,

              decoration: const InputDecoration(

                labelText: "Email",

                border: OutlineInputBorder(),

              ),

            ),



            const SizedBox(height: 15),



            TextField(

              controller: passwordController,

              obscureText: true,

              decoration: const InputDecoration(

                labelText: "Password",

                border: OutlineInputBorder(),

              ),

            ),



            const SizedBox(height: 20),



            SizedBox(

              width: double.infinity,

              child: ElevatedButton(

                onPressed: loading ? null : login,

                child: loading

                    ? const CircularProgressIndicator()

                    : const Text("LOGIN"),

              ),

            ),



            const SizedBox(height: 15),



            SizedBox(

              width: double.infinity,

              child: ElevatedButton.icon(

                onPressed: loading ? null : googleLogin,

                icon: const Icon(Icons.login),

                label: const Text(
                  "Continue with Google",
                ),

              ),

            ),



            const SizedBox(height: 20),



            TextButton(

              onPressed: (){


                Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder: (_) => const RegisterScreen(),

                  ),

                );


              },

              child: const Text(
                "Don't have an account? Register",
              ),

            )

          ],

        ),

      ),

    );

  }

}