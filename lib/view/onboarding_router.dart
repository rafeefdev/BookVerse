import 'package:book_verse/provider/onboarding_provider.dart';
import 'package:book_verse/view/pages/mainpage.dart';
import 'package:book_verse/view/pages/splash_screens/first_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingRouter extends ConsumerWidget {
  const OnboardingRouter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onBoardingStatus = ref.watch(onBoardingServiceProvider);

    return onBoardingStatus.when(
      data: (hasOpened) => hasOpened ? MainPage() : FirstScreen(),
      loading: () => const Scaffold(body: CircularProgressIndicator()),
      error:
          (error, stack) => Scaffold(
            body: Center(
              child: Column(
                children: [
                  Text('Failed to load app'),
                  FilledButton(
                    onPressed: () => ref.refresh(onBoardingServiceProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
