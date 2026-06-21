import 'package:book_verse/core/auth/providers/auth_provider.dart';
import 'package:book_verse/core/router/redirect_logic.dart';
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
    redirect: (context, state) => computeRedirect(
      matchedLocation: state.matchedLocation,
      isAuthenticated: isAuthenticated,
      onBoardingStatus: onBoardingStatus,
    ),
    routes: [...authRoutes, ...onboardingRoutes, shellRoute, ...modalRoutes],
  );
});
