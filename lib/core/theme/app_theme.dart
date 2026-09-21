import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.scaffoldBackground,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primaryBlue,
          onPrimary: AppColors.white,
          secondary: AppColors.primaryRed,
          onSecondary: AppColors.white,
          surface: AppColors.white,
          onSurface: AppColors.black,
          error: AppColors.error,
        ),
        fontFamily: 'NotoSansEthiopic',

        // AppBar theme (blue background, white text)
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: AppColors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: AppColors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: AppColors.white),
        ),

        // Elevated button (red primary)
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryRed,
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // Text button (black secondary)
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.black,
          ),
        ),

        // Outlined button
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.black,
            side: const BorderSide(color: AppColors.black),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),

        // Input decoration
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.lightGray,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          labelStyle: const TextStyle(color: AppColors.darkGray),
          hintStyle: const TextStyle(color: AppColors.mediumGray),
        ),

        // Card theme
        cardTheme: CardThemeData(
          color: AppColors.cardBackground,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.borderGray, width: 0.5),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        ),

        // Chip theme (black background, white text for category pills)
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.black,
          labelStyle: const TextStyle(color: AppColors.white),
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),

        // Drawer theme (blue background, white text)
        drawerTheme: const DrawerThemeData(
          backgroundColor: AppColors.primaryBlue,
        ),

        // Divider
        dividerTheme: const DividerThemeData(
          color: AppColors.borderGray,
          thickness: 0.5,
        ),
      );
}