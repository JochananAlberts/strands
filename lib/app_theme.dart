import 'package:flutter/material.dart';

class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  // Primary Colors (Brand/UI)
  static const Color primary = Colors.blueAccent;
  static const Color primaryLight = Color(0xFFE3F2FD); // Colors.blue[50]
  static const Color primaryBorder = Color(0xFF90CAF9); // Colors.blue[200]

  // Success Colors (Victory/Completion)
  static const Color success = Color(0xFF388E3C); // Colors.green[700]
  static const Color successBg = Color(0xFFE8F5E9); // Colors.green[50]
  static const Color successBorder = Color(0xFF81C784); // Colors.green[300]

  // Accent Colors (Hints/Medals/Interactive)
  static const Color accent = Colors.amber;
  static const Color accentBright = Colors.yellowAccent; // For lightbulb glow
  static const Color accentOrange = Colors.orangeAccent; // For warm glows

  // Medal Colors
  static const Color medalGold = Colors.amber;
  static const Color medalSilver = Color(0xFFBDBDBD); // Colors.grey[400]
  static const Color medalBronze = Color(0xFFA1887F); // Colors.brown[300]

  // Neutrals (Backgrounds/Text)
  static const Color background = Colors.white;
  static const Color surface = Colors.white; // Added for cards
  static const Color text = Colors.black87; // Added generic text
  static const Color textMain = Colors.black87;
  static const Color textDark = Colors.black;
  static const Color disabled = Colors.grey;
  static const Color disabledBg = Color(0xFFF5F5F5); // Colors.grey[100]
  
  // Text Styles (Helpers if needed later, but keeping to Colors for now)
}
