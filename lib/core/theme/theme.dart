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
    bottomSheetTheme: const BottomSheetThemeData(
      dragHandleColor: bgColorButton,
      dragHandleSize: Size(60, 4),
      backgroundColor: bgColor,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
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
      height: 70,
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: selectedNavBarItemColor);
        }
        return const IconThemeData(color: unselectedNavBarItemColor);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            color: selectedNavBarItemColor,
            fontWeight: FontWeight.w600,
            fontSize: 11,
          );
        }
        return const TextStyle(
          color: unselectedNavBarItemColor,
          fontWeight: FontWeight.w500,
          fontSize: 11,
        );
      }),
    ),
  );
}
