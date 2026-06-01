import 'package:book_verse/core/auth/providers/auth_provider.dart';
import 'package:book_verse/core/auth/view/login_page.dart';
import 'package:book_verse/core/router/shell_scaffold.dart';
import 'package:book_verse/features/dashboard/view/pages/dashboard_page.dart';
import 'package:book_verse/features/home/view/pages/detail_page.dart';
import 'package:book_verse/features/home/view/pages/new_homepage.dart';
import 'package:book_verse/features/library/view/library_page.dart';
import 'package:book_verse/features/library/view/widgets/folder_detail_page.dart';
import 'package:book_verse/features/onboarding/view/pages/splash_screens/first_page.dart';
import 'package:book_verse/features/onboarding/view/pages/splash_screens/fourth_page.dart';
import 'package:book_verse/features/onboarding/view/pages/splash_screens/second_page.dart';
import 'package:book_verse/features/onboarding/view/pages/splash_screens/third_page.dart';
import 'package:book_verse/features/onboarding/viewmodel/onboarding_viewmodel.dart';
import 'package:book_verse/features/reading_tracker/view/reading_tracker_detail_page.dart';
import 'package:book_verse/features/reading_tracker/view/session_recording_page.dart';
import 'package:book_verse/features/search/view/pages/search_page.dart';
import 'package:book_verse/features/settings/view/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final onBoardingStatus = ref.watch(onBoardingServiceProvider);
  final isAuthenticated = ref.watch(isAuthenticatedProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
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
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => FirstScreen(),
        routes: [
          GoRoute(path: '2', builder: (context, state) => SecondScreen()),
          GoRoute(path: '3', builder: (context, state) => ThirdScreen()),
          GoRoute(path: '4', builder: (context, state) => FourthScreen()),
        ],
      ),
      GoRoute(
        path: '/error',
        builder: (context, state) => Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                const Text('Something went wrong'),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => context.go('/dashboard'),
                  icon: const Icon(Icons.bar_chart),
                  label: const Text('Go to Dashboard'),
                ),
              ],
            ),
          ),
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
                path: '/dashboard',
                builder: (context, state) => const DashboardPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/explore',
                builder: (context, state) => const NewHomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/library',
                builder: (context, state) => const LibraryPage(),
                routes: [
                  GoRoute(
                    path: 'folder/:folderId',
                    builder: (context, state) {
                      final folderId = state.pathParameters['folderId'] ?? '';
                      return FolderDetailPage(folderId: folderId);
                    },
                  ),
                ],
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
          final id = state.pathParameters['id'] ?? '';
          final isTemporarySource =
              state.uri.queryParameters['isTemporarySource'] == 'true';
          if (id.isEmpty) {
            return const Scaffold(body: Center(child: Text('Invalid book ID')));
          }
          return DetailPage(
            selectedBookId: id,
            isTemporarySource: isTemporarySource,
          );
        },
      ),
      GoRoute(
        path: '/tracked-book-detail/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          if (id.isEmpty) {
            return const Scaffold(body: Center(child: Text('Invalid book ID')));
          }
          return ReadingTrackerDetailPage(bookId: id);
        },
      ),
      GoRoute(
        path: '/record-session/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          if (id.isEmpty) {
            return const Scaffold(body: Center(child: Text('Invalid book ID')));
          }
          return SessionRecordingPage(bookId: id);
        },
      ),
    ],
  );
});
