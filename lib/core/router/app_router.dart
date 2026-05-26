import 'package:book_verse/core/models/book_model.dart';
import 'package:book_verse/core/router/shell_scaffold.dart';
import 'package:book_verse/features/bookmarks/view/bookmarks_page.dart';
import 'package:book_verse/features/home/view/pages/detail_page.dart';
import 'package:book_verse/features/home/view/pages/new_homepage.dart';
import 'package:book_verse/features/onboarding/view/pages/splash_screens/first_page.dart';
import 'package:book_verse/features/onboarding/view/pages/splash_screens/fourth_page.dart';
import 'package:book_verse/features/onboarding/view/pages/splash_screens/second_page.dart';
import 'package:book_verse/features/onboarding/view/pages/splash_screens/third_page.dart';
import 'package:book_verse/features/onboarding/viewmodel/onboarding_viewmodel.dart';
import 'package:book_verse/features/reading_tracker/view/reading_tracker_detail_page.dart';
import 'package:book_verse/features/reading_tracker/view/session_recording_page.dart';
import 'package:book_verse/features/reading_tracker/viewmodel/reading_tracker_viewmodel.dart';
import 'package:book_verse/features/search/view/pages/search_page.dart';
import 'package:book_verse/features/settings/view/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

class _ShellRouteMarker extends ConsumerStatefulWidget {
  final bool isShell;
  final Widget child;
  const _ShellRouteMarker({required this.isShell, required this.child});

  @override
  ConsumerState<_ShellRouteMarker> createState() => _ShellRouteMarkerState();
}

class _ShellRouteMarkerState extends ConsumerState<_ShellRouteMarker> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(isShellRouteProvider.notifier).state = widget.isShell;
      }
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class RouteTrackerObserver extends NavigatorObserver {
  final void Function(String path) onRouteChanged;
  RouteTrackerObserver(this.onRouteChanged);

  void _notify() {
    final nav = navigator;
    if (nav == null || !nav.context.mounted) return;
    final router = GoRouter.maybeOf(nav.context);
    if (router == null) return;
    onRouteChanged(router.state.matchedLocation);
  }

  @override
  void didPush(Route route, Route? previousRoute) => _notify();

  @override
  void didPop(Route route, Route? previousRoute) => _notify();

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) => _notify();
}

final routerProvider = Provider<GoRouter>((ref) {
  final onBoardingStatus = ref.watch(onBoardingServiceProvider);

  final observer = RouteTrackerObserver((path) {
    ref.read(currentRoutePathProvider.notifier).state = path;
  });

  final goRouter = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    observers: [observer],
    redirect: (context, state) {
      // Using when to handle async value
      return onBoardingStatus.when(
        data: (hasOpened) {
          final isGoingToOnboarding = state.matchedLocation.startsWith(
            '/onboarding',
          );

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
          GoRoute(path: '2', builder: (context, state) => SecondScreen()),
          GoRoute(path: '3', builder: (context, state) => ThirdScreen()),
          GoRoute(path: '4', builder: (context, state) => FourthScreen()),
        ],
      ),
      GoRoute(
        path: '/error',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Something went wrong'))),
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
                builder: (context, state) => const BookmarksPage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            const _ShellRouteMarker(isShell: false, child: SettingsPage()),
      ),
      GoRoute(
        path: '/search',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            const _ShellRouteMarker(isShell: false, child: SearchPage()),
      ),
      GoRoute(
        path: '/detail/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final isTemporarySource =
              state.uri.queryParameters['isTemporarySource'] == 'true';
          return _ShellRouteMarker(
            isShell: false,
            child: DetailPage(
              selectedBookId: id,
              isTemporarySource: isTemporarySource,
            ),
          );
        },
      ),
      GoRoute(
        path: '/tracked-book-detail/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return _ShellRouteMarker(
            isShell: false,
            child: ReadingTrackerDetailPage(bookId: id),
          );
        },
      ),
      GoRoute(
        path: '/record-session/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final book = state.extra as Book?;
          return SessionRecordingPage(bookId: id, initialBook: book);
        },
      ),
    ],
  );
  return goRouter;
});
