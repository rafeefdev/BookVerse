import 'dart:developer';
import 'dart:io';

import 'package:book_verse/core/router/app_router.dart';
import 'package:book_verse/core/services/sqflite_service.dart';
import 'package:book_verse/core/services/supabase_service.dart';
import 'package:book_verse/core/theme/providers/thememode_provider.dart';
import 'package:book_verse/core/theme/app_theme.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

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
    if (Platform.isAndroid || Platform.isIOS) {
      await SqfliteService.instance.database;
    } else {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      await SqfliteService.instance.database;
    }
  } catch (e, stack) {
    log('Failed to initialize database: $e\n$stack');
  }

  runApp(
    ProviderScope(
      child: DevicePreview(
        enabled: !kReleaseMode,
        builder: (context) => const MyApp(),
      ),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          systemNavigationBarIconBrightness: isDark
              ? Brightness.light
              : Brightness.dark,
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
      // ignore: deprecated_member_use
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      routerConfig: router,
    );
  }
}
