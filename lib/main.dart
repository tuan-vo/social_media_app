import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/auth/auth.dart';
import 'package:social_media_app/theme/dark_theme.dart';
import 'package:social_media_app/theme/light_theme.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // This is the last thing you need to add.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      home: const AuthPage(),
    );
  }
}
