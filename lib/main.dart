import 'package:flutter/material.dart';
import 'package:hatch_care/screens/splash_screen.dart';

void main() {
  runApp(const HatchCareApp());
}

class HatchCareApp extends StatelessWidget {
  const HatchCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}