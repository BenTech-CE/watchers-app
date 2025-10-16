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
        padding: EdgeInsets.symmetric(vertical: 0, horizontal: 4),
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
        padding: EdgeInsets.zero,
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
    scaffoldBackgroundColor: Colors.black,
    navigationBarTheme: NavigationBarThemeData(
      overlayColor: MaterialStateProperty.all(Colors.transparent),
      iconTheme: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return const IconThemeData(color: selectedNavBarItemColor);
        }
        return const IconThemeData(color: unselectedNavBarItemColor);
      }),
      labelTextStyle: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return const TextStyle(
              color: selectedNavBarItemColor);
        }
        return const TextStyle(color: unselectedNavBarItemColor);
      }),
    ),
  );
}
