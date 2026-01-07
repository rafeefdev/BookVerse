import 'package:book_verse/core/shared/components/dotindicator_component.dart';
import 'package:book_verse/features/onboarding/service/useronboarding_service.dart';
import 'package:book_verse/features/onboarding/viewmodel/onboarding_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FourthScreen extends ConsumerWidget {
  const FourthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Padding(
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
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 0.1),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_forward_ios_rounded),
                    onPressed: () async {
                      await UserOnBoardingService().setUserHasOpenedApp();
                      ref.invalidate(onBoardingServiceProvider);
                      // The router's redirect will handle the navigation
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
