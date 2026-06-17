import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF000000), // Hitam pekat Netflix
      primaryColor: const Color(0xFFE50914), // Warna aksen utama (misal: Merah Premium)
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFE50914),
        surface: Color(0xFF121212), // Abu-abu sangat gelap untuk card background
        onSurface: Colors.white,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        bodyLarge: TextStyle(fontSize: 14, color: Colors.white),
        bodyMedium: TextStyle(fontSize: 12, color: Color(0xFFB3B3B3)), // Abu-abu pudar untuk metadata
      ),
    );
  }
}