import 'package:book_verse/core/models/book_model.dart';
import 'package:book_verse/core/shared/helpers/helper/book_authors.dart';
import 'package:book_verse/features/reading_tracker/model/reading_progress_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

Widget bookListTile(
  BuildContext context,
  Book book, {
  bool isWrappedByCard = false,
  bool isTemporarySource = false,
  ReadingProgressModel? readingProgress,
  void Function()? onTap,
}) {
  double progressValue = 0.0;
  String progressText = 'Not started';

  if (readingProgress != null && book.pageCount > 0) {
    progressValue = readingProgress.currentPage / book.pageCount;
    progressText = '${readingProgress.currentPage} / ${book.pageCount} pages';
  }

  Widget listTileContent = Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        leading: book.thumbnail.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  book.thumbnail,
                  width: 50,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.book),
                ),
              )
            : Container(
                width: 50,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(child: Icon(Icons.book, color: Colors.grey[600])),
              ),
        title: Text(
          book.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(bookAuthors(book)),
        trailing: onTap != null ? const Icon(Icons.arrow_forward_ios) : null,
      ),
      if (readingProgress != null)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LinearProgressIndicator(
                value: progressValue,
                backgroundColor: Colors.grey[300],
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 4),
              Text(
                progressText,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
    ],
  );

  Widget lisTile = InkWell(
    onTap: onTap ??
        () {
          context.push('/detail/${book.id}?isTemporarySource=$isTemporarySource');
        },
    child: listTileContent,
  );

  return isWrappedByCard
      ? Card(
          elevation: 2.6,
          margin: const EdgeInsets.only(bottom: 12),
          child: lisTile,
        )
      : lisTile;
}
