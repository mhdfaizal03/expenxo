
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: const Text(
            'Expenxo',
            style: TextStyle(fontSize: 55, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
