import 'package:book_verse/core/models/book_model.dart';
import 'package:book_verse/core/shared/helpers/book_authors.dart';
import 'package:book_verse/features/reading_tracker/model/reading_progress_model.dart';
import 'package:flutter/material.dart';

class SessionBookCard extends StatelessWidget {
  final Book book;
  final ReadingProgressModel readingProgress;
  final Widget Function(double w, double h) onFallback;

  const SessionBookCard({
    super.key,
    required this.book,
    required this.readingProgress,
    required this.onFallback,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        border: Border.all(color: scheme.outlineVariant, width: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: book.thumbnail.isNotEmpty
                ? Image.network(
                    book.thumbnail,
                    width: 44,
                    height: 62,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        onFallback(44, 62),
                  )
                : onFallback(44, 62),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  bookAuthors(book),
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Page ${readingProgress.currentPage} · ${readingProgress.effectivePageCount} pages',
                    style: textTheme.labelSmall?.copyWith(
                      color: scheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
