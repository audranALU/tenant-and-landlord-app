import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/providers/auth_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/auth_wrapper.dart';
<<<<<<< HEAD
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
=======
import 'providers/landlord_provider.dart';


>>>>>>> origin/main

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
<<<<<<< HEAD
        ChangeNotifierProvider(create: (_) => AuthProvider()),
=======

        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => LandlordProvider(),
        ),

>>>>>>> origin/main
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
<<<<<<< HEAD
        title: 'Tenant & Landlord App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const AuthWrapper(), // this will auto-switch Home/Login
=======

        title: 'iRembo Maintenance',

        theme: AppTheme.lightTheme,

        home: const AuthWrapper(),

>>>>>>> origin/main
      ),
    );
  }
}