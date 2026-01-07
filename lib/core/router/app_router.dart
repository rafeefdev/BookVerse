import 'package:book_verse/core/router/shell_scaffold.dart';
import 'package:book_verse/features/bookmarks/view/pages/savedbook_page.dart';
import 'package:book_verse/features/home/view/pages/detail_page.dart';
import 'package:book_verse/features/home/view/pages/new_homepage.dart';
import 'package:book_verse/features/onboarding/view/pages/splash_screens/first_page.dart';
import 'package:book_verse/features/onboarding/view/pages/splash_screens/fourth_page.dart';
import 'package:book_verse/features/onboarding/view/pages/splash_screens/second_page.dart';
import 'package:book_verse/features/onboarding/view/pages/splash_screens/third_page.dart';
import 'package:book_verse/features/onboarding/viewmodel/onboarding_viewmodel.dart';
import 'package:book_verse/features/search/view/pages/search_page.dart';
import 'package:book_verse/features/settings/view/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final onBoardingStatus = ref.watch(onBoardingServiceProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    redirect: (context, state) {
      // Using when to handle async value
      return onBoardingStatus.when(
        data: (hasOpened) {
          final isGoingToOnboarding = state.matchedLocation.startsWith('/onboarding');

          if (!hasOpened && !isGoingToOnboarding) {
            return '/onboarding';
          }

          if (hasOpened && isGoingToOnboarding) {
            return '/home';
          }

          return null;
        },
        loading: () => null, // Or show a loading screen
        error: (err, stack) => '/error', // Or show an error screen
      );
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => FirstScreen(),
        routes: [
          GoRoute(
            path: '2',
            builder: (context, state) => SecondScreen(),
          ),
          GoRoute(
            path: '3',
            builder: (context, state) => ThirdScreen(),
          ),
          GoRoute(
            path: '4',
            builder: (context, state) => FourthScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/error',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Something went wrong')),
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ShellScaffold(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const NewHomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/bookmarks',
                builder: (context, state) => const SavedbookPage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/search',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SearchPage(),
      ),
      GoRoute(
        path: '/detail/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final isTemporarySource =
              state.uri.queryParameters['isTemporarySource'] == 'true';
          return DetailPage(
            selectedBookId: id,
            isTemporarySource: isTemporarySource,
          );
        },
      ),
    ],
  );
});
