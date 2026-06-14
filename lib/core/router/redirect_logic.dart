import 'package:flutter_riverpod/flutter_riverpod.dart';

String? computeRedirect({
  required String matchedLocation,
  required bool isAuthenticated,
  required AsyncValue<bool> onBoardingStatus,
}) {
  final isGoingToOnboarding = matchedLocation.startsWith('/onboarding');
  final isGoingToLogin = matchedLocation == '/login';

  return onBoardingStatus.when(
    data: (hasOpened) {
      if (!hasOpened) {
        if (!isGoingToOnboarding) return '/onboarding';
        return null;
      }

      if (!isAuthenticated && !isGoingToLogin) return '/login';
      if (isAuthenticated && isGoingToLogin) return '/dashboard';
      if (isAuthenticated && isGoingToOnboarding) return '/dashboard';

      if (matchedLocation.startsWith('/bookmarks')) return '/library';

      return null;
    },
    loading: () => null,
    error: (err, stack) => '/error',
  );
}
