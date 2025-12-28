import 'package:shared_preferences/shared_preferences.dart';

class UserOnBoardingService {
  static const _hasOpenedAppKey = 'hasOpenedApp';

  Future<bool> hasUserOpenedAppBefore() async {
    //get shared preferences instance with await keyword
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasOpenedAppKey) ?? false;
  } 

  Future<void> setUserHasOpenedApp() async {
    //get shared preferences instance with await keyword
    final prefs = await SharedPreferences.getInstance();
    //run setBool method with await keyword
    await prefs.setBool(_hasOpenedAppKey, true);
  }
}