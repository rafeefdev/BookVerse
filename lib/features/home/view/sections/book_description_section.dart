import 'dart:developer';
import 'package:book_verse/core/theme/themes_extension.dart';
import 'package:flutter/material.dart';

class BookDescriptionSection extends StatelessWidget {
  final String description;
  const BookDescriptionSection(this.description, {super.key});

  @override
  Widget build(BuildContext context) {
    log(
      '[BookDescriptionSection] called with: "${description.length > 100 ? "${description.substring(0, 100)}..." : description}"',
    );
    log('[BookDescriptionSection] length: ${description.length}');

    if (description == "No Description") {
      log('[BookDescriptionSection] → fallback No Description');
      return Text(
        description,
        style: context.textTheme.bodyMedium?.copyWith(
          fontStyle: FontStyle.italic,
          color: context.colorScheme.onSurfaceVariant,
        ),
      );
    }

    final paragraphs = description
        .split(RegExp(r'\n\n'))
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();

    log('[BookDescriptionSection] paragraphs count: ${paragraphs.length}');
    for (int i = 0; i < paragraphs.length && i < 3; i++) {
      log(
        '[BookDescriptionSection] paragraph[$i]: "${paragraphs[i].length > 80 ? "${paragraphs[i].substring(0, 80)}..." : paragraphs[i]}"',
      );
    }

    if (paragraphs.isEmpty) {
      log('[BookDescriptionSection] → fallback (empty after split)');
      return Text(
        "No Description",
        style: context.textTheme.bodyMedium?.copyWith(
          fontStyle: FontStyle.italic,
          color: context.colorScheme.onSurfaceVariant,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < paragraphs.length; i++) ...[
          SelectableText(paragraphs[i], style: context.textTheme.bodyMedium),
          if (i < paragraphs.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}
