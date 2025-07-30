import 'package:book_verse/core/shared/mediaquery_extension.dart';
import 'package:book_verse/core/shared/themes_extension.dart';
import 'package:book_verse/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthenticationPage extends ConsumerWidget {
  const AuthenticationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome to BookVerse !',
                style: context.textTheme.headlineLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Start your literacy life here !',
                style: context.textTheme.bodyLarge,
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: context.mq.size.width * 0.7,
                height: 45,
                child: FilledButton(
                  onPressed: () {
                    ref.read(authProvider.notifier).signInWithGoogle();
                  },
                  child: const Text('Sign-in With Google'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
