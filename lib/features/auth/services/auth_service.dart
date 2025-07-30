// File: lib/services/auth_service.dart

import 'package:book_verse/core/models/authuser_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Ini akan generate file auth_service.g.dart ketika kita run build_runner
part 'auth_service.g.dart';

/// Service yang menangani semua operasi autentikasi dengan Supabase
///
/// Class ini bertindak sebagai layer abstraksi antara UI dan Supabase client
/// sehingga jika suatu saat kita ingin ganti backend, kita hanya perlu
/// mengubah implementasi di class ini tanpa menyentuh UI
class AuthService {
  AuthService(this._supabase);

  final SupabaseClient _supabase;

  /// Mendapatkan user yang sedang login saat ini
  ///
  /// Method ini seperti "mengecek kartu identitas" siapa yang sedang
  /// menggunakan aplikasi. Jika tidak ada yang login, akan return null
  Authuser? getCurrentUser() {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    return Authuser.fromSupabaseUser(user);
  }

  /// Stream yang memberitahu perubahan status autentikasi
  ///
  /// Ini seperti "sistem notifikasi" yang akan memberitahu aplikasi
  /// ketika ada perubahan status login (login, logout, session expired, dll)
  Stream<Authuser?> watchAuthState() {
    return _supabase.auth.onAuthStateChange.map((authState) {
      final user = authState.session?.user;
      if (user == null) return null;

      return Authuser.fromSupabaseUser(user);
    });
  }

  /// Melakukan sign in dengan Google menggunakan OAuth flow
  ///
  /// Method ini akan membuka browser untuk proses autentikasi Google.
  /// Prosesnya seperti ini:
  /// 1. Aplikasi membuka browser dengan URL OAuth Google
  /// 2. User memasukkan kredensial Google mereka
  /// 3. Google redirect kembali ke aplikasi dengan authorization code
  /// 4. Supabase menukar code tersebut dengan access token
  /// 5. User berhasil login dan session tersimpan
  Future<Authuser> signInWithGoogle() async {
    try {
      // Melakukan OAuth flow dengan Google
      // redirectTo harus sesuai dengan deep link configuration di AndroidManifest/Info.plist
      final AuthResponse response =
          (await _supabase.auth.signInWithOAuth(
                OAuthProvider.google,
                redirectTo:
                    'com.example.bookverse://login-callback/', // Sesuaikan dengan package name
                authScreenLaunchMode: LaunchMode.externalApplication,
              ))
              as AuthResponse;

      // Mengecek apakah sign in berhasil
      if (response.user == null) {
        throw const AuthException('Sign in dibatalkan atau gagal');
      }

      // Membuat Authuser object dari hasil response
      return Authuser.fromSupabaseUser(response.user!);
    } on AuthException catch (error) {
      // Error spesifik dari Supabase (misal: network error, invalid credentials)
      throw AuthException('Error autentikasi: ${error.message}');
    } catch (error) {
      // Error umum lainnya (misal: browser tidak bisa dibuka, dll)
      throw Exception('Gagal melakukan sign in dengan Google: $error');
    }
  }

  /// Melakukan sign out dari aplikasi
  ///
  /// Method ini akan menghapus session user dan mengembalikan mereka
  /// ke state "tidak login". Seperti "logout" dari sistem komputer
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (error) {
      throw Exception('Gagal melakukan sign out: $error');
    }
  }

  /// Refresh session token jika diperlukan
  ///
  /// JWT token memiliki masa expired, method ini berguna untuk
  /// memperpanjang session tanpa harus login ulang
  Future<Authuser> refreshSession() async {
    try {
      final AuthResponse response = await _supabase.auth.refreshSession();

      if (response.user == null) {
        throw const AuthException('Session tidak valid');
      }

      return Authuser.fromSupabaseUser(response.user!);
    } catch (error) {
      throw Exception('Gagal refresh session: $error');
    }
  }

  /// Mengecek apakah user sedang dalam status login
  bool get isSignedIn => _supabase.auth.currentUser != null;
}

/// Provider untuk Supabase client instance
///
/// Provider ini menyediakan instance Supabase client yang sudah dikonfigurasi
/// dan bisa digunakan di seluruh aplikasi
@riverpod
SupabaseClient supabaseClient(Ref ref) {
  return Supabase.instance.client;
}

/// Provider untuk AuthService
///
/// Provider ini membuat instance AuthService yang sudah terhubung
/// dengan Supabase client. Dengan menggunakan provider ini,
/// kita bisa mengakses AuthService dari mana saja di aplikasi
@riverpod
AuthService authService(Ref ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return AuthService(supabaseClient);
}

/// Provider untuk current user yang sedang login
///
/// Provider ini memberikan informasi user yang sedang login.
/// Jika tidak ada user yang login, akan return null
@riverpod
Authuser? currentUser(Ref ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.getCurrentUser();
}

/// Provider untuk watch perubahan auth state
///
/// Provider ini menggunakan stream untuk memberitahu perubahan
/// status autentikasi secara real-time. UI yang menggunakan provider ini
/// akan otomatis rebuild ketika status auth berubah
@riverpod
Stream<Authuser?> authState(AuthStateRef ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.watchAuthState();
}
