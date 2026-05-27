import 'package:flutter/material.dart';

Container dotIndicator(BuildContext context, bool isIndexed) {
  final scheme = Theme.of(context).colorScheme;
  return Container(
    height: 8,
    width: 8,
    margin: const EdgeInsets.symmetric(horizontal: 2),
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: isIndexed ? scheme.primary : scheme.primaryContainer,
    ),
  );
}
