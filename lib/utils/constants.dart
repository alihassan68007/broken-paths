import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color forestGreen = Color(0xFF228B22);
  static const Color gold = Color(0xFFFFD700);
  static const Color creamWhite = Color(0xFFFFFDD0);
  static const Color darkBackground = Color(0xFF1A1A1A);
}

class AppConstants {
  static const int chapterUnlockCoins = 500;
  static const double aspectRatio = 16 / 9;
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      primaryColor: AppColors.forestGreen,
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: GoogleFonts.latoTextTheme().copyWith(
        bodyLarge: const TextStyle(color: AppColors.creamWhite, fontSize: 18),
        bodyMedium: const TextStyle(color: AppColors.creamWhite, fontSize: 16),
        displayLarge: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.forestGreen,
          foregroundColor: AppColors.creamWhite,
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
