import 'package:flutter/material.dart';
import 'appcolors.dart';

class AppText {
  static const TextStyle displayLarge = TextStyle(
    fontFamily: 'Montserrat',
    color: AppColors.textPrimary,
    fontSize: 36,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: 'Montserrat',
    color: AppColors.textPrimary,
    fontSize: 24,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle button = TextStyle(
    fontFamily: 'Montserrat',
    color: AppColors.background,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );
}
