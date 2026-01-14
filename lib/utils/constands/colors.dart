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
  static const Color scaffoldLight = Color(0xFFFAFAFA);
  static const Color cardLight = Colors.white;
  static const Color textPrimaryLight = Colors.black87;
  static const Color textSecondaryLight = Colors.grey;
  static const Color iconLight = Colors.black87;
  static const Color dividerLight = Color(0xFFEEEEEE);

  // Dark Theme Colors
  static const Color scaffoldDark = Color(0xFF121212); // Standard Dark BG
  static const Color cardDark = Color(0xFF1E1E1E); // Slightly lighter for cards
  static const Color textPrimaryDark = Colors.white;
  static const Color textSecondaryDark = Colors.white70;
  static const Color iconDark = Colors.white70;
  static const Color dividerDark = Color(0xFF333333);

  // Semantic Colors
  static const Color error = Color(0xFFFF5252);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
}
