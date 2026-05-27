import 'package:book_verse/core/shared/components/booklisttile_component.dart';
import 'package:book_verse/features/library/model/library_state.dart';
import 'package:book_verse/features/reading_tracker/model/reading_progress_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CurrentlyReadingTab extends StatelessWidget {
  final LibraryState state;

  const CurrentlyReadingTab({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final books = state.currentlyReading;
    final scheme = Theme.of(context).colorScheme;
    if (books.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book_outlined,
              size: 64,
              color: scheme.outlineVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No books being read',
              style: TextStyle(fontSize: 16, color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final progress = books[index];
        final book = progress.book;
        if (book == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: bookListTile(
            context,
            book,
            isWrappedByCard: true,
            isTemporarySource: false,
            readingProgress: ReadingProgressModel(
              bookId: progress.bookId,
              currentPage: progress.currentPage,
              totalReadingTimeInSeconds: progress.totalReadingTimeInSeconds,
              lastRead: progress.lastRead,
              book: progress.book,
            ),
            onTap: () {
              context.push('/tracked-book-detail/${progress.bookId}');
            },
          ),
        );
      },
    );
  }
}
