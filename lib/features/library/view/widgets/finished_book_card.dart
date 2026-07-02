import 'package:book_verse/core/shared/helpers/book_authors.dart';
import 'package:book_verse/features/library/model/finished_book_info.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FinishedBookCard extends StatelessWidget {
  final FinishedBookInfo info;

  const FinishedBookCard({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final book = info.progress.book;
    if (book == null) return const SizedBox.shrink();

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () =>
            context.push('/tracked-book-detail/${info.progress.bookId}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: book.thumbnail.isNotEmpty
                    ? Image.network(
                        book.thumbnail,
                        width: 50,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 50,
                          height: 70,
                          color: scheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.book,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    : Container(
                        width: 50,
                        height: 70,
                        color: scheme.surfaceContainerHighest,
                        child: Icon(Icons.book, color: scheme.onSurfaceVariant),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
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
                    if (info.formattedCompletionDate != null)
                      _infoRow(
                        Icons.check_circle,
                        Colors.green,
                        'Selesai: ${info.formattedCompletionDate}',
                        textTheme,
                        scheme,
                      ),
                    if (info.formattedDaysSpent != null)
                      _infoRow(
                        Icons.calendar_today,
                        scheme.onSurfaceVariant,
                        '${info.formattedDaysSpent} membaca',
                        textTheme,
                        scheme,
                      ),
                    _infoRow(
                      Icons.timer_outlined,
                      scheme.onSurfaceVariant,
                      'Total: ${info.formattedTotalTime}',
                      textTheme,
                      scheme,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(
    IconData icon,
    Color color,
    String text,
    TextTheme textTheme,
    ColorScheme scheme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
