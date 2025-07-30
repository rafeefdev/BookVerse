import 'package:book_verse/core/shared/components/dotindicator_component.dart';
import 'package:book_verse/core/shared/components/nextbutton_components.dart';
import 'package:book_verse/features/auth/view/authwrapper.dart';
import 'package:book_verse/features/auth/view/pages/authentication_page.dart';
import 'package:book_verse/features/auth/viewmodel/auth_provider.dart';
import 'package:book_verse/features/home/view/pages/mainpage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FourthScreen extends ConsumerWidget {
  const FourthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider);

    return Scaffold(
      body: Container(
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            children: [
              SizedBox(height: 480),
              // Subtitle kecil
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Book Recomendation',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
              const SizedBox(height: 10),
              // Judul besar
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'The Right Book for You',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 15),

              // Deskripsi singkat
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Intelligent algorithms recommend books based on your activities and preferences.',
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),
              const Spacer(),
              // bottom widgets
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Dot indicator (simbol halaman aktif)
                  Row(
                    children: [
                      dotIndicator(false),
                      dotIndicator(false),
                      dotIndicator(true),
                    ],
                  ),
                  // Tombol Next
                  nextButton(context, nextScreen: const AuthWrapper()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
