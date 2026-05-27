import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

Widget nextButton(BuildContext context, {required String path}) {
  return Container(
    decoration: const BoxDecoration(shape: BoxShape.circle),
    child: IconButton(
      icon: const Icon(Icons.arrow_forward_ios_rounded),
      onPressed: () {
        context.go(path);
      },
    ),
  );
}
