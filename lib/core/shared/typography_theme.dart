import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  static String get fontFamily => GoogleFonts.plusJakartaSans().fontFamily!;

  static TextTheme get textTheme {
    return GoogleFonts.plusJakartaSansTextTheme();
  }
}
