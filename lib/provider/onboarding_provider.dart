import 'dart:developer';

import 'package:book_verse/services/useronboarding_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final onBoardingServiceProvider = FutureProvider<bool>((ref) async {
  final service = UserOnBoardingService();
  try {
    return service.hasUserOpenedAppBefore();
  } catch (e) {
    log('Error when checking on boarding status : $e');
    return false;
  }
});
