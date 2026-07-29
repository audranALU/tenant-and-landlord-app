import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../../screens/login_screen.dart';
import '../../screens/home_screen.dart';



class AuthWrapper extends StatelessWidget {

  const AuthWrapper({super.key});


  @override
  Widget build(BuildContext context) {


    final auth =
        Provider.of<AuthProvider>(context);


    if(auth.user == null){

      return LoginScreen();

    }


    return HomeScreen();


  }

}