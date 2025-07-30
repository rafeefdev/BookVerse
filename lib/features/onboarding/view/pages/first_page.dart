import 'package:book_verse/core/services/useronboarding_service.dart';
import 'package:book_verse/features/onboarding/view/gradient_background.dart';
import 'package:book_verse/features/onboarding/view/pages/second_page.dart';
import 'package:flutter/material.dart';

class FirstScreen extends StatelessWidget {
  const FirstScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(decoration: BoxDecoration(gradient: gradientBackground)),
          SafeArea(
            child: SizedBox.expand(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Spacer(flex: 2),
                  bookVerseLogo(150),
                  const Spacer(flex: 3),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SecondScreen(),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons
                              .login, // Bisa diganti dengan Google logo jika ada asset
                          size: 24,
                        ),
                        label: Text(
                          'Start',
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
                          disabledBackgroundColor: Colors.white.withOpacity(
                            0.7,
                          ),
                          disabledForegroundColor: Colors.grey,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget bookVerseLogo(double size) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
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
        child: const Icon(Icons.book_rounded, size: 64, color: Colors.white),
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
    ],
  );
}
