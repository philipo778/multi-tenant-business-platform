import 'package:flutter/material.dart';

class AppTheme {
  static const Color background = Color(0xE7E9EBEA);
  // static const Color background = Color(0xF4F5F7FF);
  // static const Color background = Color(0xFFFCFAEE);
  static const Color action = Color(0xFFFF6801);
  static const Color border = Color(0xFFDBD0BE);
  static const Color header = Color(0xFF0C5446);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: background,

    colorScheme: ColorScheme.fromSeed(
      seedColor: header,
      primary: header,
      secondary: action,
      surface: background,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: header,
      foregroundColor: Colors.white,
      elevation: 0,
    ),

    cardTheme: CardThemeData(
      color: background,
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: const BorderSide(
          color: border,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
    ),

    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: action,
      ),
    ),
  );
}