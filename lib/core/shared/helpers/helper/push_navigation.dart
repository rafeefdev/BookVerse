import 'package:flutter/material.dart';

VoidCallback pushNavigation(BuildContext context, {required Widget destinationPage}) {
  return ()=> Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => destinationPage),
  );
}
