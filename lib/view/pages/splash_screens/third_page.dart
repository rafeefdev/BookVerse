import 'package:BookVerse/view/components.dart';
import 'package:BookVerse/view/pages/splash_screens/fourth_page.dart';
import 'package:flutter/material.dart';

class ThirdScreen extends StatelessWidget {
  const ThirdScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                'Reading Timer',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
            const SizedBox(height: 10),
            // Judul besar
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Keep Track of Your Reading Moments',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 15),

            // Deskripsi singkat
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'A special stopwatch helps track your reading habits in precise detail.',
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
                    dotIndicator(true),
                    dotIndicator(false),
                  ],
                ),
                // Tombol Next
                nextButton(context, nextScreen: FourthScreen()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
