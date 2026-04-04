import 'package:flutter/material.dart';

class AppTheme {
  static const Color bg = Color(0xFFEAF4E1);
  static const Color surface = Color(0xFFF9FBF4);
  static const Color card = Color(0xFFDFF2C8);

  static const Color primary = Color(0xFF234F25);
  static const Color primarySoft = Color(0xFFCFE5AF);

  static const Color textDark = Color(0xFF1F2E1F);
  static const Color textSoft = Color(0xFF6E7B61);

  static const Color divider = Color(0xFFDDE6CF);
  static const Color error = Colors.red;

  static const Color healthy = Color(0xFF4CAF50);
  static const Color disease = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFA000);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    fontFamily: 'Poppins',

    scaffoldBackgroundColor: bg,

    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: primary,
      onPrimary: Colors.white,
      secondary: primarySoft,
      onSecondary: primary,
      error: error,
      onError: Colors.white,
      surface: surface,
      onSurface: textDark,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: textDark,
      elevation: 0,
      centerTitle: false,
    ),

    // 🔥 PREMIUM TEXT STYLES
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        color: textDark,
        letterSpacing: -0.5,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textDark,
        letterSpacing: -0.3,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textDark,
      ),
      bodyLarge: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: textDark,
      ),
      bodyMedium: TextStyle(
        fontSize: 13.5,
        fontWeight: FontWeight.w400,
        color: textSoft,
      ),
    ),

    // 🔥 CARD (SOFTER + MODERN)
    cardTheme: CardThemeData(
      color: card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    ),

    // 🔥 BUTTON (PLANTIX STYLE)
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // 🔥 INPUT FIELD (MORE PREMIUM)
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      hintStyle: const TextStyle(
        color: textSoft,
        fontSize: 14,
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
    ),

    dividerColor: divider,
  );
}