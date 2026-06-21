import 'package:book_verse/core/shared/components/booklisttile_component.dart';
import 'package:book_verse/features/dashboard/model/dashboard_state.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CurrentlyReadingSection extends StatelessWidget {
  final DashboardState state;
  final TextTheme textTheme;
  final ColorScheme colorScheme;
  const CurrentlyReadingSection(
    this.state,
    this.textTheme,
    this.colorScheme, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (state.currentlyReading.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Currently Reading', style: textTheme.titleMedium),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'No books being read yet',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Currently Reading', style: textTheme.titleMedium),
            TextButton(
              onPressed: () => context.go('/library'),
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ...state.currentlyReading.map((progress) {
          final book = progress.book!;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: bookListTile(
              context,
              book,
              readingProgress: progress,
              isWrappedByCard: true,
              onTap: () => context.push('/tracked-book-detail/${book.id}'),
            ),
          );
        }),
      ],
    );
  }
}
