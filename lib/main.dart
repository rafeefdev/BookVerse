import 'package:BookVerse/provider/thememode_provider.dart';
import 'package:BookVerse/view/onboarding_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:BookVerse/shared/app_theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(); //load .env file
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeMode appThemeMode = ref.watch(thememodeProviderProvider).value ?? ThemeMode.system;

    return MaterialApp(
      title: 'BookVerse',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(),
      darkTheme: darkTheme,
      themeMode: appThemeMode,
      home: const OnboardingRouter(),
    );
  }
}
