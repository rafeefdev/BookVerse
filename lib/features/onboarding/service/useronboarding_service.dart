import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';

class UserOnBoardingService {
  static const _hasOpenedAppKey = 'hasOpenedApp';

  Future<bool> hasUserOpenedAppBefore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_hasOpenedAppKey) ?? false;
    } catch (e, stack) {
      log('hasUserOpenedAppBefore error: $e\n$stack');
      return false;
    }
  }

  Future<void> setUserHasOpenedApp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_hasOpenedAppKey, true);
    } catch (e, stack) {
      log('setUserHasOpenedApp error: $e\n$stack');
    }
  }
}
