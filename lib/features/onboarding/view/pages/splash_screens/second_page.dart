import 'package:book_verse/core/shared/components/dotindicator_component.dart';
import 'package:book_verse/core/shared/components/nextbutton_components.dart';
import 'package:flutter/material.dart';

class SecondScreen extends StatelessWidget {
  const SecondScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            children: [
              SizedBox(height: 480),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Powerfull Search', style: TextStyle(fontSize: 14)),
              ),
              const SizedBox(height: 10),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Explore the Ocean of Knowledge',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 15),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Deep search into millions of books across genres, authors, and publishers',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      dotIndicator(context, true),
                      dotIndicator(context, false),
                      dotIndicator(context, false),
                    ],
                  ),
                  nextButton(context, path: '/onboarding/3'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
