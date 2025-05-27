import 'package:BookVerse/view/pages/splash_screens/second_page.dart';
import 'package:flutter/material.dart';

class FirstScreen extends StatelessWidget {
  const FirstScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 320),
            literaLifeLogo(150),
            SizedBox(height: 320),
            FilledButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SecondScreen()),
                );
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
