import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/providers/auth_provider.dart';


class HomeScreen extends StatelessWidget {

  const HomeScreen({super.key});


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: Center(

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            const Text(
              "Home Dashboard",
              style: TextStyle(fontSize: 30),
            ),


            ElevatedButton(

              onPressed: (){

                Provider.of<AuthProvider>(
                  context,
                  listen: false,
                ).logout();

              },

              child: const Text("Logout"),

            )

          ],

        ),

      ),

    );

  }

}