import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authServiceProvider).onAuthStateChange;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authServiceProvider).currentSession != null;
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authServiceProvider).currentUser;
});

final userInitialsProvider = Provider<String>((ref) {
  final user = ref.watch(currentUserProvider);
  final name = user?.userMetadata?['full_name'] as String? ?? '';
  if (name.isEmpty) return '?';
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.length >= 2) {
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
  return name.isNotEmpty ? name[0].toUpperCase() : '?';
});
