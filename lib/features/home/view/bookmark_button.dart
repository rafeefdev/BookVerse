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
            // apabila sudah disimpan di savedbook dan hendak dihapus, munculkan alert
            if (isBookmarked) {
              // tampilkan dialog
              showDialog(
                context: context,
                builder: (context) =>
                    RemoveBookmarkDialog(bookTitle: selectedBook.title),
              );
            } else {
              // jika belum ada di saved book, langsung ditoggle
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
      error: (error, stack) => IconButton(
        onPressed: null,
        icon: Icon(Icons.bookmark_border_rounded, color: Colors.grey),
      ),
      loading: () => IconButton(
        onPressed: null,
        icon: Icon(Icons.bookmark_border_rounded, color: Colors.grey),
      ),
    );
  }
}

class RemoveBookmarkDialog extends StatelessWidget {
  final String bookTitle;

  const RemoveBookmarkDialog({super.key, required this.bookTitle});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Are you sure to remove from saved book list?'),
      content: Text('Book "$bookTitle" will removed from saved book list'),
      // TODO : add action button to remove or cancel removing book
      actions: [],
    );
  }
}
