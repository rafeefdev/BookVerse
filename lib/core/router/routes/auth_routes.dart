import 'package:book_verse/core/auth/view/login_page.dart';
import 'package:go_router/go_router.dart';

List<RouteBase> get authRoutes => [
  GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
];
