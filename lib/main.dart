import 'package:expenxo/view/auth/splash_screen.dart';
import 'package:expenxo/view/nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expenxo',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFAFAFA),
        textTheme: GoogleFonts.abelTextTheme(),
        // textTheme: GoogleFonts.aBeeZeeTextTheme(),
      ),
      home: SplashScreen(),
    );
  }
}
