import 'package:book_verse/core/shared/components/dotindicator_component.dart';
import 'package:book_verse/core/shared/components/nextbutton_components.dart';
import 'package:flutter/material.dart';

class ThirdScreen extends StatelessWidget {
  const ThirdScreen({super.key});

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
                child: Text('Reading Timer', style: TextStyle(fontSize: 14)),
              ),
              const SizedBox(height: 10),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Keep Track of Your Reading Moments',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 15),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'A special stopwatch helps track your reading habits in precise detail.',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      dotIndicator(context, false),
                      dotIndicator(context, true),
                      dotIndicator(context, false),
                    ],
                  ),
                  nextButton(context, path: '/onboarding/4'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
