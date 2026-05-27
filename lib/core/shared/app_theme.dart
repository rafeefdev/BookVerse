import 'package:book_verse/core/shared/typography_theme.dart';
import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  fontFamily: AppTypography.fontFamily,
  textTheme: AppTypography.textTheme,
);

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  fontFamily: AppTypography.fontFamily,
  textTheme: AppTypography.textTheme,
);
