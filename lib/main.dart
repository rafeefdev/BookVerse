import 'package:book_verse/core/providers/thememode_provider.dart';
import 'package:book_verse/core/services/useronboarding_service.dart';
import 'package:book_verse/core/shared/app_theme.dart';
import 'package:book_verse/core/shared/initialerror_page.dart';
import 'package:book_verse/features/onboarding/view/onboarding_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //load .env file
  await dotenv.load();

  try {
    //initialize supabase
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );

    runApp(ProviderScope(child: MyApp()));
  } catch (e) {
    runApp(ProviderScope(child: InitialerrorPage(errorMessage: e.toString())));
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeMode appThemeMode =
        ref.watch(thememodeProviderProvider).value ?? ThemeMode.system;

    UserOnBoardingService.setCustomCondition(false);

    return MaterialApp(
      title: 'book_verse',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: appThemeMode,
      home: const OnboardingRouter(),
    );
  }
}
