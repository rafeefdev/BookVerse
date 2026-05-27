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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            children: [
              SizedBox(height: 480),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Book Recomendation',
                  style: TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(height: 10),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'The Right Book for You',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 15),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Intelligent algorithms recommend books based on your activities and preferences.',
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
                      dotIndicator(context, false),
                      dotIndicator(context, true),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(width: 0.1),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_forward_ios_rounded),
                      onPressed: () async {
                        await UserOnBoardingService().setUserHasOpenedApp();
                        ref.invalidate(onBoardingServiceProvider);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
