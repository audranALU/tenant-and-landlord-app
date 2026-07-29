import 'package:flutter/material.dart';
import '../core/services/auth_service.dart';


class RegisterScreen extends StatefulWidget {


  const RegisterScreen({super.key});


  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();

}



class _RegisterScreenState extends State<RegisterScreen>{


  final AuthService _authService = AuthService();


  final emailController = TextEditingController();

  final passwordController = TextEditingController();



  bool loading = false;



  Future<void> register() async {


    setState(() {

      loading = true;

    });



    await _authService.createAccount(

      emailController.text.trim(),

      passwordController.text.trim(),

    );



    setState(() {

      loading = false;

    });


  }





  @override
  Widget build(BuildContext context){


    return Scaffold(


      appBar: AppBar(

        title: const Text(
          "Register",
        ),

      ),



      body: Padding(

        padding: const EdgeInsets.all(24),


        child: Column(

          mainAxisAlignment:
          MainAxisAlignment.center,


          children: [


            const Text(

              "Create Account",

              style: TextStyle(

                fontSize: 30,

                fontWeight: FontWeight.bold,

              ),

            ),



            const SizedBox(height:30),



            TextField(

              controller: emailController,

              decoration: const InputDecoration(

                labelText:"Email",

                border:OutlineInputBorder(),

              ),

            ),



            const SizedBox(height:15),



            TextField(

              controller: passwordController,

              obscureText:true,

              decoration: const InputDecoration(

                labelText:"Password",

                border:OutlineInputBorder(),

              ),

            ),



            const SizedBox(height:20),



            ElevatedButton(

              onPressed:
              loading ? null : register,


              child:

              loading

              ? const CircularProgressIndicator()

              : const Text(
                "CREATE ACCOUNT",
              ),

            )


          ],

        ),

      ),

    );


  }


}