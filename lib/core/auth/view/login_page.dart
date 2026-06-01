import 'dart:async';
import 'dart:io';

import 'package:book_verse/core/auth/providers/auth_provider.dart';
import 'package:book_verse/core/auth/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum _LoginStep { idle, loading, waitingForBrowser }

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => LoginPageController();
}

class LoginPageController extends ConsumerState<LoginPage> {
  _LoginStep _step = _LoginStep.idle;
  StreamSubscription<AuthState>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = ref.read(authServiceProvider).onAuthStateChange.listen((auth) {
      if (auth.session != null && _step != _LoginStep.idle) {
        _step = _LoginStep.idle;
        if (mounted) setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (Platform.isAndroid) {
      setState(() => _step = _LoginStep.loading);
      try {
        await ref.read(authServiceProvider).signInWithGoogle();
      } on AuthCancelledException {
        setState(() => _step = _LoginStep.idle);
      } catch (e) {
        setState(() => _step = _LoginStep.idle);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Sign in failed: $e')));
        }
      }
    } else {
      setState(() => _step = _LoginStep.waitingForBrowser);
      try {
        await ref.read(authServiceProvider).signInWithGoogle();
      } catch (e) {
        setState(() => _step = _LoginStep.idle);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to open browser: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.auto_stories,
                  size: 80,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  'BookVerse',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your personal reading companion',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 48),
                if (_step == _LoginStep.loading)
                  const CircularProgressIndicator()
                else if (_step == _LoginStep.waitingForBrowser)
                  Column(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        'Complete login in your browser,\nthen return to the app.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  )
                else
                  FilledButton.icon(
                    onPressed: _signIn,
                    icon: const Icon(Icons.login),
                    label: const Text('Sign in with Google'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                      textStyle: theme.textTheme.titleMedium,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
