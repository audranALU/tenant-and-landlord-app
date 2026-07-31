import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/providers/auth_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/auth_wrapper.dart';
import 'firebase_options.dart';
import 'providers/landlord_provider.dart';

Future<void> main() async {
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
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LandlordProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'iRembo Maintenance',
        theme: AppTheme.lightTheme,
        home: const AuthWrapper(),
      ),
    );
  }
}