import 'package:book_verse/core/shared/components/dotindicator_component.dart';
import 'package:book_verse/core/shared/components/nextbutton_components.dart';
import 'package:book_verse/features/onboarding/view/gradient_background.dart';
import 'package:book_verse/features/onboarding/view/pages/third_page.dart';
import 'package:flutter/material.dart';

class SecondScreen extends StatelessWidget {
  const SecondScreen({super.key});

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
              child: Icon(Icons.search, color: Colors.white, size: 120),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Powerfull Search',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Explore the Ocean of Knowledge',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Deep search into millions of books across genres, authors, and publishers',
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          dotIndicator(true),
                          dotIndicator(false),
                          dotIndicator(false),
                        ],
                      ),
                      nextButton(context, nextScreen: const ThirdScreen()),
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