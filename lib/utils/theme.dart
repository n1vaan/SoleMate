// themes.dart
import 'package:flutter/material.dart';
import 'package:sole_mate/utils/appcolors.dart';

final ThemeData lightTheme = ThemeData(
  scaffoldBackgroundColor: Color.fromARGB(255, 255, 255, 255),
  primaryColor: AppColors.primary,
  brightness: Brightness.light,
  fontFamily: 'Montserrat',
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.primary,
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(color: AppColors.textPrimary),
    displayMedium: TextStyle(color: AppColors.textPrimary),
    displaySmall: TextStyle(color: AppColors.textPrimary),
    headlineLarge: TextStyle(color: AppColors.textPrimary),
    headlineMedium: TextStyle(color: AppColors.textPrimary),
    headlineSmall: TextStyle(color: AppColors.textPrimary),
    titleLarge: TextStyle(color: AppColors.textPrimary),
    titleMedium: TextStyle(color: AppColors.textPrimary),
    titleSmall: TextStyle(color: AppColors.textPrimary),
    bodyLarge: TextStyle(color: AppColors.textPrimary),
    bodyMedium: TextStyle(color: AppColors.textPrimary),
    bodySmall: TextStyle(color: AppColors.textPrimary),
    labelLarge: TextStyle(fontSize: 17, color: Colors.white), // Button text style
    labelMedium: TextStyle(color: AppColors.textPrimary),
    labelSmall: TextStyle(color: AppColors.textPrimary),
  ),
  buttonTheme: const ButtonThemeData(
    buttonColor: AppColors.primary,
  ),
);

final ThemeData darkTheme = ThemeData(
  scaffoldBackgroundColor: Colors.black,
  primaryColor: AppColors.primary,
  brightness: Brightness.dark,
  buttonTheme: const ButtonThemeData(
    buttonColor: AppColors.secondary,
  ),
  fontFamily: 'Montserrat',
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.primary,
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(color: AppColors.textSecondary),
    displayMedium: TextStyle(color: AppColors.textSecondary),
    displaySmall: TextStyle(color: AppColors.textSecondary),
    headlineLarge: TextStyle(color: AppColors.textSecondary),
    headlineMedium: TextStyle(color: AppColors.textSecondary),
    headlineSmall: TextStyle(color: AppColors.textSecondary),
    titleLarge: TextStyle(color: AppColors.textSecondary),
    titleMedium: TextStyle(color: AppColors.textSecondary),
    titleSmall: TextStyle(color: AppColors.textSecondary),
    bodyLarge: TextStyle(color: AppColors.textSecondary),
    bodyMedium: TextStyle(color: AppColors.textSecondary),
    bodySmall: TextStyle(color: AppColors.textSecondary),
    labelLarge: TextStyle(fontSize: 17, color: Colors.white), // Button text style
    labelMedium: TextStyle(color: AppColors.textSecondary),
    labelSmall: TextStyle(color: AppColors.textSecondary),
  ),
);
