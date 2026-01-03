import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: const Color(0xFF5B5FEF),
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF7F8FC),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: const Color(0xFF5B5FEF),
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0F1115),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
    );
  }
}
