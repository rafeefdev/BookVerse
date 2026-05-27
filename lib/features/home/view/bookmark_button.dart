import 'dart:developer';

import 'package:book_verse/core/models/book_model.dart';
import 'package:book_verse/features/bookmarks/viewmodel/bookmark_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookmarkButton extends ConsumerWidget {
  const BookmarkButton({super.key, required this.selectedBook});

  final Book selectedBook;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    log('bookmark button pressed & rebuilded');

    final bookMarkedBooks = ref.watch(bookmarkNotifierProvider);

    return bookMarkedBooks.when(
      data: (data) {
        final isBookmarked = data.any(
          (progress) => progress.bookId == selectedBook.id,
        );
        return IconButton(
          onPressed: () {
            if (isBookmarked) {
              showDialog(
                context: context,
                builder: (context) => _RemoveBookmarkDialog(
                  bookTitle: selectedBook.title,
                  onConfirm: () {
                    ref
                        .read(bookmarkNotifierProvider.notifier)
                        .toggleBookmark(selectedBook);
                    Navigator.of(context).pop();
                  },
                ),
              );
            } else {
              ref
                  .read(bookmarkNotifierProvider.notifier)
                  .toggleBookmark(selectedBook);
            }
          },
          icon: Icon(
            isBookmarked ? Icons.bookmark : Icons.bookmark_border_rounded,
          ),
        );
      },
      error: (error, stack) {
        final scheme = Theme.of(context).colorScheme;
        return IconButton(
          onPressed: null,
          icon: Icon(
            Icons.bookmark_border_rounded,
            color: scheme.onSurfaceVariant.withValues(alpha: 0.38),
          ),
        );
      },
      loading: () {
        final scheme = Theme.of(context).colorScheme;
        return IconButton(
          onPressed: null,
          icon: Icon(
            Icons.bookmark_border_rounded,
            color: scheme.onSurfaceVariant.withValues(alpha: 0.38),
          ),
        );
      },
    );
  }
}

class _RemoveBookmarkDialog extends StatelessWidget {
  final String bookTitle;
  final VoidCallback onConfirm;

  const _RemoveBookmarkDialog({
    required this.bookTitle,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Are you sure to remove from saved book list?'),
      content: Text('Book "$bookTitle" will removed from saved book list'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: onConfirm, child: const Text('Remove')),
      ],
    );
  }
}
