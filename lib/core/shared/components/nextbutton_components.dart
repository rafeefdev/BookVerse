import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

Widget nextButton(BuildContext context, {required String path}) {
  return Container(
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white,
      border: Border.all(color: Colors.black, width: 0.1),
    ),
    child: IconButton(
      icon: const Icon(Icons.arrow_forward_ios_rounded),
      onPressed: () {
        context.go(path);
      },
    ),
  );
}
