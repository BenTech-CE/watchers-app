import 'package:flutter/material.dart';
import 'package:watchers/core/theme/colors.dart';
import 'package:watchers/core/theme/texts.dart';

class AppTheme {
  AppTheme._();

  static ThemeData theme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: colorPrimary,
      brightness: Brightness.dark,
    ),
    textTheme: appTextTheme,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
        backgroundColor: colorPrimary,
        foregroundColor: tColorPrimary,
        textStyle: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
        side: const BorderSide(color: bgColorButton, width: 1),
        foregroundColor: tColorPrimary,
        backgroundColor: bgColorButton,
        textStyle: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
          color: tColorQuarternary,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
  );
}
