import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color mainColor = Color(0xFF00C9A7); // Teal
  static const Color accentColor = Color(
    0xFFB8AA6E,
  ); // Gold/Accent (from gradient)
  static const Color secondaryColor = Color(
    0xFF68B96E,
  ); // Green (from gradient)

  // Light Theme Colors
  static const Color scaffoldLight = Color(0xFFF2F2F7); // iOS System Grey 6
  static const Color cardLight = Colors.white;
  static const Color textPrimaryLight = Colors.black87;
  static const Color textSecondaryLight = Colors.grey;
  static const Color iconLight = Colors.black87;
  static const Color dividerLight = Color(0xFFEEEEEE);

  // Dark Theme Colors
  static const Color scaffoldDark =
      Colors.black; // Pure Black for OLED Glass pop
  static const Color cardDark = Color(0xFF1C1C1E); // iOS System Grey 6 Dark
  static const Color textPrimaryDark = Colors.white;
  static const Color textSecondaryDark = Colors.white70;
  static const Color iconDark = Colors.white70;
  static const Color dividerDark = Color(0xFF333333);

  // Glassmorphism Colors
  static final Color glassBgLight = Colors.white.withOpacity(0.5);
  static final Color glassBgDark = Color(0xFF1E1E1E).withOpacity(0.5);
  static final Color glassBorderLight = Colors.white.withOpacity(0.4);
  static final Color glassBorderDark = Colors.white.withOpacity(0.1);
  static const double glassBlur = 10.0;

  // Semantic Colors
  static const Color error = Color(0xFFFF5252);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
}
