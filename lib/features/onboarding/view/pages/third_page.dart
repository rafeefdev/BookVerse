import 'package:book_verse/core/shared/components/dotindicator_component.dart';
import 'package:book_verse/core/shared/components/nextbutton_components.dart';
import 'package:book_verse/features/onboarding/view/gradient_background.dart';
import 'package:book_verse/features/onboarding/view/pages/fourth_page.dart';
import 'package:flutter/material.dart';

class ThirdScreen extends StatelessWidget {
  const ThirdScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 480,
            width: double.infinity,
            decoration: BoxDecoration(gradient: gradientBackground),
            child: const Center(
              child: Icon(Icons.timer, color: Colors.white, size: 120),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Reading Timer',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Keep Track of Your Reading Moments',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'A special stopwatch helps track your reading habits in precise detail.',
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          dotIndicator(false),
                          dotIndicator(true),
                          dotIndicator(false),
                        ],
                      ),
                      nextButton(context, nextScreen: const FourthScreen()),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}