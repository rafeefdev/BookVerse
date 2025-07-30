import 'package:flutter/material.dart';

Container dotIndicator(bool isIndexed) {
  return Container(
    height: 8,
    width: 8,
    margin: const EdgeInsets.symmetric(horizontal: 2),
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: isIndexed ? Colors.deepPurple : Colors.purple,
    ),
  );
}
