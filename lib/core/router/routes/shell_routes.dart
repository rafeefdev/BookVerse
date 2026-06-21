import 'package:book_verse/core/router/shell_scaffold.dart';
import 'package:book_verse/features/dashboard/view/pages/dashboard_page.dart';
import 'package:book_verse/features/home/view/pages/new_homepage.dart';
import 'package:book_verse/features/library/view/library_page.dart';
import 'package:book_verse/features/library/view/widgets/folder_detail_page.dart';
import 'package:go_router/go_router.dart';

RouteBase get shellRoute => StatefulShellRoute.indexedStack(
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
);
