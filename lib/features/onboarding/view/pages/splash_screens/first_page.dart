import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FirstScreen extends StatelessWidget {
  const FirstScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox.expand(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Spacer(flex: 2),
              literaLifeLogo(150),
              const Spacer(flex: 3),
              FilledButton(
                onPressed: () {
                  context.go('/onboarding/2');
                },
                style: ButtonStyle(
                  fixedSize: WidgetStatePropertyAll(
                    Size(MediaQuery.of(context).size.width * 0.8, 45),
                  ),
                ),
                child: const Text('Start !'),
              ),
              SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

Widget literaLifeLogo(double size) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      SizedBox(
        height: size,
        width: size,
        child: Card(
          elevation: 4,
          child: Icon(
            Icons.book,
            size: size / 2,
            color: Colors.deepPurpleAccent,
          ),
        ),
      ),
      SizedBox(height: 16),
      Text(
        'LiteraLife',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
      ),
    ],
  );
}
