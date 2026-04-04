import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';

void main() {
  runApp(FitMindApp());
}

class FitMindApp extends StatelessWidget {
  const FitMindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WelcomeScreen(),
    );
  }
}