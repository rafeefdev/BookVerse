import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  static const Color _primary = Color(0xFF1A1A1A);
  static const Color _secondary = Color(0xFF4D4D4D);
  static const Color _caption = Color(0xFF888888);

  static String get fontFamily => GoogleFonts.plusJakartaSans().fontFamily!;

  static TextTheme get textTheme {
    final base = GoogleFonts.plusJakartaSansTextTheme();
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(color: _primary),
      displayMedium: base.displayMedium?.copyWith(color: _primary),
      displaySmall: base.displaySmall?.copyWith(color: _primary),
      headlineLarge: base.headlineLarge?.copyWith(color: _primary),
      headlineMedium: base.headlineMedium?.copyWith(color: _primary),
      headlineSmall: base.headlineSmall?.copyWith(color: _primary),
      titleLarge: base.titleLarge?.copyWith(color: _secondary),
      titleMedium: base.titleMedium?.copyWith(color: _secondary),
      titleSmall: base.titleSmall?.copyWith(color: _secondary),
      bodyLarge: base.bodyLarge?.copyWith(color: _primary),
      bodyMedium: base.bodyMedium?.copyWith(color: _primary),
      bodySmall: base.bodySmall?.copyWith(color: _caption),
      labelLarge: base.labelLarge?.copyWith(color: _primary),
      labelMedium: base.labelMedium?.copyWith(color: _caption),
      labelSmall: base.labelSmall?.copyWith(color: _caption),
    );
  }
}
