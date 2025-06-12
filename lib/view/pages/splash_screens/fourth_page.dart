import 'package:BookVerse/main.dart';
import 'package:BookVerse/view/components/dotindicator_component.dart';
import 'package:BookVerse/view/components/nextbutton_components.dart';
import 'package:flutter/material.dart';

class FourthScreen extends StatelessWidget {
  const FourthScreen({super.key});

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
                nextButton(context, nextScreen: MainPage()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
