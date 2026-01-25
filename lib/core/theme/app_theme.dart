import 'package:flutter/material.dart';
import 'app_color.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: AppColor.background,
    primaryColor: AppColor.primary,

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColor.primary,
      foregroundColor: Colors.white,
      elevation: 0,
    ),

    colorScheme: ColorScheme.light(
      primary: AppColor.primary,
      background: AppColor.background,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColor.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  );
}
