import 'dart:developer';

import 'package:book_verse/core/database/database_provider.dart';
import 'package:book_verse/core/router/app_router.dart';
import 'package:book_verse/core/services/supabase_service.dart';
import 'package:book_verse/core/theme/providers/thememode_provider.dart';
import 'package:book_verse/core/theme/app_theme.dart';
import 'package:book_verse/features/notifications/providers/notification_providers.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart';
import 'package:timezone/data/latest.dart' as tz;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  try {
    await dotenv.load();
  } catch (e) {
    log('Failed to load .env file: $e');
  }

  try {
    await initSupabase();
  } catch (e, stack) {
    log('Failed to initialize Supabase: $e\n$stack');
  }

  try {
    await initDatabase();
  } catch (e, stack) {
    log('Failed to initialize database: $e\n$stack');
  }

  tz.initializeTimeZones();

  runApp(
    ProviderScope(
      child: DevicePreview(
        enabled: !kReleaseMode,
        builder: (context) => const MyApp(),
      ),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    try {
      final service = ref.read(notificationServiceProvider);
      await service.initialize();
      await scheduleDailyReminder(ref);
    } catch (e, stack) {
      log('Failed to initialize notifications: $e\n$stack');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeMode appThemeMode =
        ref.watch(thememodeProviderProvider).value ?? ThemeMode.system;

    if (appThemeMode != ThemeMode.system) {
      final isDark = appThemeMode == ThemeMode.dark;
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarDividerColor: Colors.transparent,
          statusBarBrightness: isDark ? Brightness.light : Brightness.dark,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          systemNavigationBarIconBrightness:
              isDark ? Brightness.light : Brightness.dark,
        ),
      );
    }

    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'book_verse',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: appThemeMode,
      builder: DevicePreview.appBuilder,
      locale: DevicePreview.locale(context),
      routerConfig: router,
    );
  }
}
