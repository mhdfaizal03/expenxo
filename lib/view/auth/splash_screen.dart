import 'package:expenxo/services/firestore_service.dart';
import 'package:expenxo/view/auth/login_page.dart';
import 'package:expenxo/view/auth/on_boarding_screen.dart';
import 'package:expenxo/view/nav_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expenxo/utils/constands/colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward();
    _navigate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _navigate() async {
    final user = FirebaseAuth.instance.currentUser;

    // Prefetch data if user is logged in
    if (user != null) {
      await FirestoreService().prefetchAllData();
    }

    // Ensure animation completes and minimum time passes
    await Future.wait([
      Future.delayed(const Duration(milliseconds: 2000)),
      if (user == null) Future.delayed(const Duration(milliseconds: 1000)),
    ]);

    final targetScreen = await _getTargetScreen();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => targetScreen),
      (route) => false,
    );
  }

  Future<Widget> _getTargetScreen() async {
    final user = FirebaseAuth.instance.currentUser;
    final prefs = await SharedPreferences.getInstance();
    final seenOnboarding = prefs.getBool('seenOnboarding') ?? false;

    if (user != null) {
      return const NavBar();
    } else {
      if (seenOnboarding) {
        return const LoginPage();
      } else {
        return const OnBoardingScreen();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Colors.black : AppColors.scaffoldLight,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _scaleAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Image.asset(
                      isDark ? 'assets/logo2.png' : 'assets/logo3.png',
                      height: 400,
                      width: 400,
                      // color: isDark ? Colors.white : null,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
