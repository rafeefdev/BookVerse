import 'package:book_verse/core/shared/loading_page.dart';
import 'package:book_verse/features/auth/view/pages/authentication_page.dart';
import 'package:book_verse/features/auth/viewmodel/auth_provider.dart';
import 'package:book_verse/features/home/view/pages/new_homepage.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watching auth state menggunakan Riverpod
    // Setiap kali auth state berubah, widget ini akan rebuild otomatis
    final authState = ref.watch(authNotifierProvider);

    // Menentukan widget mana yang ditampilkan berdasarkan auth status
    return switch (authState.status) {
      // Status initial atau loading - tampilkan loading screen
      AuthStatus.initial || AuthStatus.loading => const LoadingScreen(),

      // User sudah authenticated - tampilkan home screen
      AuthStatus.authenticated => const NewHomePage(),

      // User belum login atau ada error - tampilkan auth screen
      AuthStatus.unauthenticated || AuthStatus.error => const AuthScreen(),
    };
  }
}
