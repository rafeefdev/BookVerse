import 'package:book_verse/features/onboarding/view/pages/splash_screens/first_page.dart';
import 'package:book_verse/features/onboarding/view/pages/splash_screens/fourth_page.dart';
import 'package:book_verse/features/onboarding/view/pages/splash_screens/second_page.dart';
import 'package:book_verse/features/onboarding/view/pages/splash_screens/third_page.dart';
import 'package:go_router/go_router.dart';

List<RouteBase> get onboardingRoutes => [
  GoRoute(
    path: '/onboarding',
    builder: (context, state) => FirstScreen(),
    routes: [
      GoRoute(path: '2', builder: (context, state) => SecondScreen()),
      GoRoute(path: '3', builder: (context, state) => ThirdScreen()),
      GoRoute(path: '4', builder: (context, state) => FourthScreen()),
    ],
  ),
];
