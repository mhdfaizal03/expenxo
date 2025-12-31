import 'package:expenxo/view/auth/on_boarding_screen.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  @override
  void initState() {
    // TODO: implement initState
    Future.delayed(Duration(milliseconds: 1000), () {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => OnBoardingScreen()),
        (route) => false,
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: Text(
            'Expenxo',
            style: TextStyle(fontSize: 55, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
