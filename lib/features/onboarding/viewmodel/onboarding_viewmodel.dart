import 'dart:developer';
import 'package:book_verse/features/onboarding/service/useronboarding_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'onboarding_viewmodel.g.dart';

@riverpod
Future<bool> onBoardingService(Ref ref) {
  final service = UserOnBoardingService();
  try {
    return service.hasUserOpenedAppBefore();
  } catch (e) {
    log('Error when checking on boarding status : $e');
    return Future.value(false);
  }
}
