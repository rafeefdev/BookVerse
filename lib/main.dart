import 'dart:io';

import 'package:book_verse/core/services/sqflite_service.dart';
import 'package:book_verse/core/theme/providers/thememode_provider.dart';
import 'package:book_verse/core/shared/app_theme.dart';
import 'package:book_verse/features/onboarding/view/onboarding_router.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // load .env file
  await dotenv.load();

  // Inisialisasi database (multiplatform)
  if (Platform.isAndroid || Platform.isIOS) {
    // Mobile: otomatis pakai sqflite biasa
    await SqfliteService.instance.database;
  } else {
    // Desktop (Linux, Windows, macOS) pakai sqflite_common_ffi
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    await SqfliteService.instance.database;
  }

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => const ProviderScope(child: MyApp()),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeMode appThemeMode =
        ref.watch(thememodeProviderProvider).value ?? ThemeMode.system;

    return MaterialApp(
      title: 'book_verse',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: appThemeMode,
      builder: DevicePreview.appBuilder,
      // ignore: deprecated_member_use
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      home: const OnboardingRouter(),
    );
  }
}
