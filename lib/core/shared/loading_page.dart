// File: lib/screens/loading_screen.dart

import 'package:flutter/material.dart';

/// Screen yang ditampilkan saat aplikasi sedang loading
/// 
/// Screen ini seperti "layar pembuka" yang memberitahu user bahwa
/// aplikasi sedang memproses sesuatu dan mereka perlu menunggu sebentar
class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Gradient background yang konsisten dengan theme aplikasi
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
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo atau icon aplikasi
              Icon(
                Icons.book_rounded,
                size: 80,
                color: Colors.white,
              ),
              SizedBox(height: 24),
              
              // Nama aplikasi
              Text(
                'BookVerse',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 48),
              
              // Loading indicator
              SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3,
                ),
              ),
              SizedBox(height: 24),
              
              // Loading text
              Text(
                'Mempersiapkan aplikasi...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}