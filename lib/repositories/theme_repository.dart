import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeRepository {
  static const _key = 'isDarkMode';

  Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, mode.index == 1 ? false : true);
  }

  Future<ThemeMode> loadThemeData() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getBool(_key);

    if (value == null) return ThemeMode.system;
    return value ? ThemeMode.dark : ThemeMode.light;
  }
}
