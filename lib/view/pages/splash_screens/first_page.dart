import 'package:book_verse/services/useronboarding_service.dart';
import 'package:book_verse/view/pages/splash_screens/second_page.dart';
import 'package:flutter/material.dart';

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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SecondScreen()),
                  );
                  UserOnBoardingService().setUserHasOpenedApp();
                },
                style: ButtonStyle(
                  fixedSize: WidgetStatePropertyAll(
                    Size(MediaQuery.of(context).size.width * 0.8, 45),
                  ),
                ),
                child: const Text('Start !'),
              ),
              SizedBox(height: 32),
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
