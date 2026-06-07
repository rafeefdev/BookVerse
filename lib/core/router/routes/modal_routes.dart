import 'package:book_verse/features/home/view/pages/detail_page.dart';
import 'package:book_verse/features/insights/view/insights_page.dart';
import 'package:book_verse/features/reading_tracker/view/reading_tracker_detail_page.dart';
import 'package:book_verse/features/reading_tracker/view/session_recording_page.dart';
import 'package:book_verse/features/search/view/pages/search_page.dart';
import 'package:book_verse/features/settings/view/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

GlobalKey<NavigatorState> get rootNavigatorKey => _rootNavigatorKey;

List<RouteBase> get modalRoutes => [
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
        path: '/insights',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const InsightsPage(),
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
    ];
