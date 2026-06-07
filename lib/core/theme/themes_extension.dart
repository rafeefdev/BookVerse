import 'package:flutter/material.dart';

extension ExTheme on BuildContext {
  //getter for inherited theme
  ThemeData get theme => Theme.of(this);
  //getter for textstyle
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;
}