import 'package:book_verse/core/auth/providers/auth_provider.dart';
import 'package:book_verse/core/router/routes/auth_routes.dart';
import 'package:book_verse/core/router/routes/modal_routes.dart';
import 'package:book_verse/core/router/routes/onboarding_routes.dart';
import 'package:book_verse/core/router/routes/shell_routes.dart';
import 'package:book_verse/features/onboarding/viewmodel/onboarding_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final onBoardingStatus = ref.watch(onBoardingServiceProvider);
  final isAuthenticated = ref.watch(isAuthenticatedProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/dashboard',
    redirect: (context, state) {
      final isGoingToLogin = state.matchedLocation == '/login';

      if (!isAuthenticated && !isGoingToLogin) return '/login';
      if (isAuthenticated && isGoingToLogin) return '/dashboard';

      return onBoardingStatus.when(
        data: (hasOpened) {
          final isGoingToOnboarding = state.matchedLocation.startsWith(
            '/onboarding',
          );

          if (!hasOpened && !isGoingToOnboarding) {
            return '/onboarding';
          }

          if (hasOpened && isGoingToOnboarding) {
            return '/dashboard';
          }

          final isGoingToBookmarks = state.matchedLocation.startsWith(
            '/bookmarks',
          );
          if (isGoingToBookmarks) {
            return '/library';
          }

          return null;
        },
        loading: () => null,
        error: (err, stack) => '/error',
      );
    },
    routes: [
      ...authRoutes,
      ...onboardingRoutes,
      shellRoute,
      ...modalRoutes,
    ],
  );
});
