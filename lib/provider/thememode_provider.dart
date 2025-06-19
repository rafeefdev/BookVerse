import 'package:book_verse/repositories/theme_repository.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'thememode_provider.g.dart';

@riverpod
class ThememodeProvider extends _$ThememodeProvider {
  @override
  Future<ThemeMode> build() async {
    return ThemeRepository().loadThemeData();
  }

  Future<void> changeTheme(ThemeMode newMode) async {
    state = AsyncValue.data(newMode);
    ThemeRepository().saveThemeMode(newMode);
  }
}
