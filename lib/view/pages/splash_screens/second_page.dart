import 'package:BookVerse/view/components/dotindicator_component.dart';
import 'package:BookVerse/view/components/nextbutton_components.dart';
import 'package:BookVerse/view/pages/splash_screens/third_page.dart';
import 'package:flutter/material.dart';

class SecondScreen extends StatelessWidget {
  const SecondScreen({super.key});

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
                'Powerfull Search',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
            const SizedBox(height: 10),
            // Judul besar
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Explore the Ocean of Knowledge',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 15),

            // Deskripsi singkat
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Deep search into millions of books across genres, authors, and publishers',
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
                    dotIndicator(true),
                    dotIndicator(false),
                    dotIndicator(false),
                  ],
                ),
                // Tombol Next
                nextButton(context, nextScreen: ThirdScreen()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
