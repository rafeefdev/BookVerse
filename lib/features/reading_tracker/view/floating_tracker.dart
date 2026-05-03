import 'package:flutter/material.dart';

class FloatingTracker extends StatelessWidget {
  const FloatingTracker({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: Card(
        child: Row(
          children: [
            Container(),
            Column(children: [Text('Title'), Text('Page readed percentage')]),
            Spacer(),
            Text("08.00"),
          ],
        ),
      ),
    );
  }
}
