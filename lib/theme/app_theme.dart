import 'package:flutter/material.dart';

class AppTheme {
  static final Color _lightPrimaryColor = Colors.red[800]!;
  static final Color _darkPrimaryColor = Colors.red[300]!;

  static final ThemeData lightTheme = ThemeData(
    primaryColor: _lightPrimaryColor,
    scaffoldBackgroundColor: Colors.grey[50],
    appBarTheme: AppBarTheme(
      color: _lightPrimaryColor,
      foregroundColor: Colors.white,
    ),
    textTheme: const TextTheme(
      headlineSmall: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
      titleLarge: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _lightPrimaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: _lightPrimaryColor,
      unselectedItemColor: Colors.grey[600],
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    primaryColor: _darkPrimaryColor,
    brightness: Brightness.dark, // Memberitahu Flutter ini adalah tema gelap
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: AppBarTheme(
      color: Colors.grey[900],
      foregroundColor: _darkPrimaryColor,
    ),
    textTheme: const TextTheme(
      headlineSmall: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      titleLarge: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _darkPrimaryColor,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: _darkPrimaryColor,
      unselectedItemColor: Colors.grey[500],
    ),
    cardColor: Colors.grey[850],
    chipTheme: ChipThemeData(
      backgroundColor: Colors.grey[800],
      labelStyle: const TextStyle(color: Colors.white)
    ),
  );
}