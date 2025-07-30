// File: lib/screens/auth_screen.dart

import 'package:book_verse/features/auth/viewmodel/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Screen untuk proses autentikasi pengguna
/// 
/// Screen ini bertindak sebagai "pintu gerbang" aplikasi di mana user
/// harus membuktikan identitas mereka sebelum bisa mengakses fitur utama
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  @override
  void initState() {
    super.initState();
    
    // Mendengarkan perubahan auth state untuk menampilkan error jika ada
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Mengecek apakah ada error saat screen pertama kali dibuat
      final authState = ref.read(authNotifierProvider);
      if (authState.hasError && authState.errorMessage != null) {
        _showErrorSnackBar(authState.errorMessage!);
      }
    });
  }

  /// Method untuk menampilkan error message menggunakan SnackBar
  /// 
  /// SnackBar dipilih karena tidak menghalangi user untuk mencoba lagi
  /// dan akan hilang otomatis setelah beberapa detik
  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Tutup',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            // Clear error state setelah user menutup snackbar
            ref.read(authNotifierProvider.notifier).clearError();
          },
        ),
      ),
    );
  }

  /// Method yang dipanggil ketika user menekan tombol Sign in with Google
  /// 
  /// Method ini menggunakan Riverpod untuk memanggil fungsi sign in
  /// dan menangani hasilnya secara reaktif
  Future<void> _handleGoogleSignIn() async {
    try {
      // Memanggil method signInWithGoogle dari AuthNotifier
      await ref.read(authNotifierProvider.notifier).signInWithGoogle();
      
      // Tidak perlu navigasi manual karena AuthWrapper akan otomatis
      // mengarahkan user ke HomeScreen ketika auth state berubah ke authenticated
      
    } catch (error) {
      // Error sudah ditangani di AuthNotifier, tapi kita bisa menambahkan
      // logging atau analytics tracking di sini jika diperlukan
      debugPrint('Error during Google sign in: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Menggunakan ref.listen untuk mendengarkan perubahan auth state
    // dan menampilkan error jika ada
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      // Menampilkan error snackbar jika ada error baru
      if (next.hasError && 
          next.errorMessage != null && 
          next.errorMessage != previous?.errorMessage) {
        _showErrorSnackBar(next.errorMessage!);
      }
    });

    // Watching auth state untuk mendapatkan status loading
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      body: Container(
        // Background gradient yang konsisten dengan LoadingScreen
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1565C0), // Blue 800
              Color(0xFF7B1FA2), // Purple 700
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Spacer untuk mendorong konten ke tengah
                const Spacer(flex: 2),
                
                // Header section dengan logo dan title
                _buildHeaderSection(),
                
                const Spacer(flex: 1),
                
                // Sign in button section
                _buildSignInSection(isLoading),
                
                const SizedBox(height: 32),
                
                // Footer dengan terms and privacy
                _buildFooterSection(),
                
                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Widget untuk bagian header (logo, title, subtitle)
  Widget _buildHeaderSection() {
    return Column(
      children: [
        // App icon dengan efek shadow
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.book_rounded,
            size: 64,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 32),
        
        // App title
        const Text(
          'BookVerse',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        
        // App subtitle/tagline
        const Text(
          'Temukan buku favorit Anda\ndan mulai petualangan membaca',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white70,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  /// Widget untuk bagian sign in button
  Widget _buildSignInSection(bool isLoading) {
    return Column(
      children: [
        // Google Sign In Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: isLoading ? null : _handleGoogleSignIn,
            icon: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                    ),
                  )
                : const Icon(
                    Icons.login, // Bisa diganti dengan Google logo jika ada asset
                    size: 24,
                  ),
            label: Text(
              isLoading ? 'Sedang masuk...' : 'Masuk dengan Google',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              elevation: 8,
              shadowColor: Colors.black.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              // Disable button ketika loading
              disabledBackgroundColor: Colors.white.withOpacity(0.7),
              disabledForegroundColor: Colors.grey,
            ),
          ),
        ),
        
        // Loading text ketika proses sign in
        if (isLoading) ...[
          const SizedBox(height: 16),
          const Text(
            'Membuka browser untuk autentikasi...',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ],
    );
  }

  /// Widget untuk bagian footer dengan terms dan privacy
  Widget _buildFooterSection() {
    return Column(
      children: [
        // Divider dengan text
        Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                color: Colors.white.withOpacity(0.3),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Dengan melanjutkan, Anda menyetujui',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 12,
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 1,
                color: Colors.white.withOpacity(0.3),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Terms and Privacy links
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                // TODO: Implementasi navigasi ke halaman Terms of Service
                _showInfoDialog('Terms of Service', 
                  'Halaman Terms of Service akan segera tersedia.');
              },
              child: const Text(
                'Syarat & Ketentuan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const Text(
              ' dan ',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 12,
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Implementasi navigasi ke halaman Privacy Policy
                _showInfoDialog('Privacy Policy', 
                  'Halaman Privacy Policy akan segera tersedia.');
              },
              child: const Text(
                'Kebijakan Privasi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Method untuk menampilkan dialog informasi
  void _showInfoDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}