import 'package:book_verse/core/shared/typography_theme.dart';
import 'package:flutter/material.dart';

const _seedColor = Color(0xFF6750A4);

ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: _seedColor,
    brightness: Brightness.light,
  ),
  fontFamily: AppTypography.fontFamily,
  textTheme: AppTypography.textTheme,
  iconTheme: IconThemeData(
    color: ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.light,
    ).onSurfaceVariant,
  ),
);

ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: ColorScheme.fromSeed(
    seedColor: _seedColor,
    brightness: Brightness.dark,
  ),
  fontFamily: AppTypography.fontFamily,
  textTheme: AppTypography.textTheme,
  iconTheme: IconThemeData(
    color: ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.dark,
    ).onSurfaceVariant,
  ),
);
