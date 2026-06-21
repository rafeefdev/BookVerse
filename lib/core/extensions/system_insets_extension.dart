import 'package:flutter/material.dart';

extension SystemInsetsExtension on BuildContext {
  double get safeBottomPadding =>
      MediaQuery.of(this).padding.bottom +
      MediaQuery.of(this).systemGestureInsets.bottom;
}
