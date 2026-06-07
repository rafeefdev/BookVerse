import 'package:book_verse/core/models/book_model.dart';
import 'package:book_verse/core/shared/helpers/book_authors.dart';
import 'package:book_verse/features/reading_tracker/model/reading_progress_model.dart';
import 'package:flutter/material.dart';

Widget bookGridTile({
  required Book book,
  required TextTheme textTheme,
  required ColorScheme colorScheme,
  double? aspectRatio,
  ReadingProgressModel? readingProgress,
}) {
  double progressValue = 0.0;
  String progressText = 'Not started';

  if (readingProgress != null && book.pageCount > 0) {
    progressValue = readingProgress.currentPage / book.pageCount;
    progressText = '${readingProgress.currentPage} / ${book.pageCount} pages';
  }

  return AspectRatio(
    aspectRatio: aspectRatio ?? 3 / 4,
    child: Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            _thumbnail(book, colorScheme),
            Padding(
              padding: const EdgeInsets.only(left: 6, top: 4),
              child: SizedBox(
                height: readingProgress != null ? 90 : 72,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.book, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            book.title.length < 25
                                ? book.title
                                : '${book.title.substring(0, 25)}...',
                            style: textTheme.labelLarge,
                            maxLines: 3,
                            overflow: TextOverflow.fade,
                            softWrap: true,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.person, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            bookAuthors(book, maxAuthorsDisplayed: 1),
                            maxLines: 1,
                            style: textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                    if (readingProgress != null) ...[
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: progressValue,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        color: textTheme.bodySmall?.color,
                      ),
                      const SizedBox(height: 4),
                      Text(progressText, style: textTheme.bodySmall),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _thumbnail(Book book, ColorScheme colorScheme) {
  return Expanded(
    child: AspectRatio(
      aspectRatio: 3 / 4,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outlineVariant, width: 0.05),
          color: colorScheme.surfaceContainerHighest,
        ),
        child: book.thumbnail.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  book.thumbnail,
                  fit: BoxFit.fill,
                  errorBuilder: (context, error, stackTrace) =>
                      const Center(child: Icon(Icons.book, size: 32)),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              )
            : Center(
                child: Icon(
                  Icons.book,
                  size: 48,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
      ),
    ),
  );
}
