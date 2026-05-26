import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeRepository {
  static const _key = 'app_theme';

  Future<void> saveThemeMode(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, mode.name);
    } catch (e, stack) {
      log('saveThemeMode error: $e\n$stack');
    }
  }

  Future<ThemeMode> loadThemeData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getString(_key);

      if (value == null) return ThemeMode.system;
      switch (value) {
        case 'light':
          return ThemeMode.light;
        case 'dark':
          return ThemeMode.dark;
        case 'system':
          return ThemeMode.system;
        default:
          return ThemeMode.system;
      }
    } catch (e, stack) {
      log('loadThemeData error: $e\n$stack');
      return ThemeMode.system;
    }
  }
}
