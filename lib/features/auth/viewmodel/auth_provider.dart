// File: lib/providers/auth_provider.dart

import 'package:book_verse/core/models/authuser_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';

part 'auth_provider.g.dart';

/// Enum untuk merepresentasikan berbagai status autentikasi
///
/// Dengan menggunakan enum, kita bisa menghindari penggunaan string magic
/// dan mendapatkan type safety yang lebih baik
enum AuthStatus {
  /// Status ketika aplikasi baru dimulai dan belum mengecek auth state
  initial,

  /// Status ketika sedang proses autentikasi (loading)
  loading,

  /// Status ketika user sudah berhasil login
  authenticated,

  /// Status ketika user belum login atau sudah logout
  unauthenticated,

  /// Status ketika terjadi error dalam proses autentikasi
  error,
}

/// Class yang merepresentasikan state autentikasi secara keseluruhan
///
/// Class ini menggabungkan status autentikasi, data user, dan error message
/// dalam satu tempat sehingga UI bisa dengan mudah mengetahui kondisi
/// autentikasi saat ini dan mengambil tindakan yang sesuai
class AuthState {
  const AuthState({required this.status, this.user, this.errorMessage});

  /// Status autentikasi saat ini
  final AuthStatus status;

  /// Data user yang sedang login (null jika belum login)
  final Authuser? user;

  /// Pesan error jika terjadi masalah dalam proses autentikasi
  final String? errorMessage;

  /// Factory constructor untuk membuat state awal (initial)
  factory AuthState.initial() {
    return const AuthState(status: AuthStatus.initial);
  }

  /// Factory constructor untuk state loading
  factory AuthState.loading() {
    return const AuthState(status: AuthStatus.loading);
  }

  /// Factory constructor untuk state authenticated dengan data user
  factory AuthState.authenticated(Authuser user) {
    return AuthState(status: AuthStatus.authenticated, user: user);
  }

  /// Factory constructor untuk state unauthenticated
  factory AuthState.unauthenticated() {
    return const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Factory constructor untuk state error dengan pesan error
  factory AuthState.error(String message) {
    return AuthState(status: AuthStatus.error, errorMessage: message);
  }

  /// Method untuk membuat copy dari state dengan perubahan tertentu
  AuthState copyWith({
    AuthStatus? status,
    Authuser? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Getter untuk mengecek apakah user sedang login
  bool get isAuthenticated =>
      status == AuthStatus.authenticated && user != null;

  /// Getter untuk mengecek apakah sedang dalam proses loading
  bool get isLoading => status == AuthStatus.loading;

  /// Getter untuk mengecek apakah terjadi error
  bool get hasError => status == AuthStatus.error;

  @override
  String toString() {
    return 'AuthState(status: $status, user: ${user?.email}, error: $errorMessage)';
  }
}

/// Notifier class yang mengelola state autentikasi
///
/// Class ini bertindak sebagai "pengendali utama" untuk semua operasi
/// autentikasi. Dia mendengarkan perubahan dari Supabase, mengelola
/// state transitions, dan menyediakan method untuk operasi auth
@riverpod
class AuthNotifier extends _$AuthNotifier {
  late final AuthService _authService;

  @override
  AuthState build() {
    // Mendapatkan instance AuthService dari provider
    _authService = ref.read(authServiceProvider);

    // Memulai listening untuk perubahan auth state dari Supabase
    _listenToAuthChanges();

    // Mengecek apakah sudah ada user yang login saat aplikasi dimulai
    final currentUser = _authService.getCurrentUser();
    if (currentUser != null) {
      return AuthState.authenticated(currentUser);
    }

    return AuthState.initial();
  }

  /// Method private untuk mendengarkan perubahan auth state dari Supabase
  ///
  /// Method ini seperti "petugas keamanan" yang terus memantau pintu masuk
  /// dan memberitahu sistem ketika ada yang masuk atau keluar
  void _listenToAuthChanges() {
    _authService.watchAuthState().listen(
      (user) {
        if (user != null) {
          // User berhasil login atau session masih valid
          state = AuthState.authenticated(user);
        } else {
          // User logout atau session expired
          state = AuthState.unauthenticated();
        }
      },
      onError: (error) {
        // Terjadi error dalam stream auth state
        state = AuthState.error('Error monitoring auth state: $error');
      },
    );
  }

  /// Method untuk melakukan sign in dengan Google
  ///
  /// Method ini mengatur proses sign in dari awal hingga akhir,
  /// termasuk mengubah state ke loading, menangani hasil sign in,
  /// dan mengupdate state sesuai hasil yang didapat
  Future<void> signInWithGoogle() async {
    // Mengubah state ke loading untuk memberitahu UI
    state = AuthState.loading();

    try {
      // Melakukan proses sign in dengan Google
      final user = await _authService.signInWithGoogle();

      // Sign in berhasil, update state ke authenticated
      state = AuthState.authenticated(user);
    } on AuthException catch (e) {
      // Error spesifik dari proses autentikasi
      state = AuthState.error(e.message);
    } catch (e) {
      // Error umum lainnya
      state = AuthState.error('Terjadi kesalahan yang tidak terduga: $e');
    }
  }

  /// Method untuk melakukan sign out
  ///
  /// Method ini menghapus session user dan mengubah state kembali
  /// ke unauthenticated
  Future<void> signOut() async {
    // Mengubah state ke loading selama proses sign out
    state = AuthState.loading();

    try {
      // Melakukan proses sign out
      await _authService.signOut();

      // Sign out berhasil, state akan otomatis berubah ke unauthenticated
      // melalui stream listener yang sudah kita setup
    } catch (e) {
      // Jika terjadi error, tetap ubah ke unauthenticated
      // karena sign out secara lokal sudah terjadi
      state = AuthState.unauthenticated();
    }
  }

  /// Method untuk refresh session
  ///
  /// Berguna ketika token sudah hampir expired atau kita ingin
  /// memastikan session masih valid
  Future<void> refreshSession() async {
    try {
      final user = await _authService.refreshSession();
      state = AuthState.authenticated(user);
    } catch (e) {
      // Jika refresh gagal, kemungkinan session sudah expired
      state = AuthState.unauthenticated();
    }
  }

  /// Method untuk clear error state
  ///
  /// Berguna ketika kita ingin menghilangkan pesan error setelah
  /// user sudah membacanya
  void clearError() {
    if (state.hasError) {
      final currentUser = _authService.getCurrentUser();
      if (currentUser != null) {
        state = AuthState.authenticated(currentUser);
      } else {
        state = AuthState.unauthenticated();
      }
    }
  }
}
