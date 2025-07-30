import 'package:flutter/material.dart';

Widget nextButton(BuildContext context, {required Widget nextScreen}) {
  return Container(
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white,
      border: Border.all(color: Colors.black, width: 0.1),
    ),
    child: IconButton(
      icon: const Icon(Icons.arrow_forward_ios_rounded),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => nextScreen),
        );
      },
    ),
  );
}
