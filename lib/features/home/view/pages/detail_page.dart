import 'dart:developer';
import 'package:book_verse/core/models/book_model.dart';
import 'package:book_verse/core/shared/components/bookdetailinfo_component.dart';
import 'package:book_verse/core/shared/components/icontext_horizontal_component.dart';
import 'package:book_verse/core/shared/helpers/helper/book_authors.dart';
import 'package:book_verse/core/shared/helpers/helper/book_categories.dart';
import 'package:book_verse/core/shared/helpers/helper/book_publishdate.dart';
import 'package:book_verse/core/shared/helpers/helper/book_title.dart';
import 'package:book_verse/core/shared/themes_extension.dart';
import 'package:book_verse/features/bookmarks/viewmodel/bookmark_viewmodel.dart';
import 'package:book_verse/features/reading_tracker/model/reading_progress_model.dart';
import 'package:book_verse/features/search/viewmodel/search_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Extension to provide firstWhereOrNull functionality
extension IterableExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}

class DetailPage extends ConsumerWidget {
  final String selectedBookId;
  final bool isTemporarySource;

  const DetailPage({
    required this.selectedBookId,
    super.key,
    required this.isTemporarySource,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchBookResult = ref.watch(searchNotifierProvider).result;
    final bookmarkedItems = ref.watch(bookmarkNotifierProvider);

    if (isTemporarySource) {
      // For temporary source, we don't have reading progress, just display book details
      return _buildDetailPage(
        context,
        books: searchBookResult,
        selectedBookId: selectedBookId,
        ref: ref,
      );
    } else {
      // For bookmarked items, we have reading progress
      return bookmarkedItems.when(
        data: (bookProgressList) {
          final ReadingProgressModel? progress = bookProgressList
              .firstWhereOrNull((p) => p.bookId == selectedBookId);
          final Book? book = progress?.book;

          if (book == null) {
            return Scaffold(
              appBar: AppBar(title: Text('Detail', style: context.textTheme.titleLarge)),
              body: const Center(child: Text('Book not found')),
            );
          }

          return _buildDetailPage(
            context,
            book: book,
            selectedBookId: selectedBookId,
            ref: ref,
            readingProgress: progress,
          );
        },
        error: (err, stack) => Scaffold(
          appBar: AppBar(
            title: Text('Detail', style: context.textTheme.titleLarge),
          ),
          body: Center(child: Text('Error Occured : $err\n$stack')),
        ),
        loading: () => Scaffold(
          appBar: AppBar(
            title: Text('Detail', style: context.textTheme.titleLarge),
          ),
          body: const Center(child: CircularProgressIndicator()),
        ),
      );
    }
  }

  Widget _buildDetailPage(
    BuildContext context, {
    List<Book>? books, // Only used for isTemporarySource
    Book? book, // Directly passed for non-temporary sources
    required String selectedBookId,
    required WidgetRef ref,
    ReadingProgressModel? readingProgress, // Passed for non-temporary sources
  }) {
    Book selectedBook;
    if (book != null) {
      selectedBook = book;
    } else {
      // Logic for isTemporarySource
      int index = books!.indexWhere((book) => book.id == selectedBookId);
      if (index == -1) {
        return Scaffold(
          appBar: AppBar(title: const Text('Detail')),
          body: const Center(child: Text('Book not found')),
        );
      }
      selectedBook = books[index];
    }

    log(
      '''selectedBookId : $selectedBookId\nauthors count : ${selectedBook.authors.length}
      \ntitle count : ${selectedBook.title.characters.length},''',
      level: 2,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail', style: context.textTheme.titleLarge),
        actions: [
          BookmarkButton(selectedBook: selectedBook),
          const SizedBox(width: 16), // Adjust padding
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 28, right: 28, top: 12, bottom: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.center,
              child: SizedBox(width: 216, child: bookThumbnail(selectedBook)),
            ),
            const SizedBox(height: 12),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.start,
              verticalDirection: VerticalDirection.down,
              runSpacing: 8,
              children: [
                Text(
                  bookTitle(selectedBook.title, 60),
                  softWrap: true,
                  style: context.textTheme.titleLarge,
                ),
                Text(
                  selectedBook.subTitle!.isEmpty
                      ? 'Description is not avalable'
                      : selectedBook.subTitle!,
                  style: context.textTheme.titleSmall,
                ),
                iconWithTextHorizontal(
                  context,
                  selectedBook,
                  icon: Icons.person_2,
                  text: bookAuthors(selectedBook),
                ),
                iconWithTextHorizontal(
                  context,
                  selectedBook,
                  icon: Icons.file_copy_rounded,
                  text: bookCategories(selectedBook),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                bookDetailInfoTile(
                  context,
                  title: 'Published Date',
                  data: bookPublishDate(selectedBook.publishedDate),
                  icon: Icons.calendar_month_rounded,
                ),
                bookDetailInfoTile(
                  context,
                  title: 'Page Count',
                  data: selectedBook.pageCount.toString(),
                  icon: Icons.menu_book_rounded,
                ),
                bookDetailInfoTile(
                  context,
                  data: selectedBook.publisher,
                  icon: Icons.print_rounded,
                  dataMaxLines: 1,
                  title: 'Publisher',
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (readingProgress != null && !isTemporarySource) ...[
              Text(
                'Your Reading Progress',
                style: context.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: selectedBook.pageCount > 0 ? readingProgress.currentPage / selectedBook.pageCount : 0.0,
                backgroundColor: Colors.grey[300],
                color: context.colorScheme.primary,
                minHeight: 10,
                borderRadius: BorderRadius.circular(5),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${readingProgress.currentPage} / ${selectedBook.pageCount} pages',
                    style: context.textTheme.bodyLarge,
                  ),
                  Text(
                    '${((selectedBook.pageCount > 0 ? readingProgress.currentPage / selectedBook.pageCount : 0.0) * 100).toStringAsFixed(1)}%',
                    style: context.textTheme.bodyLarge,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.push('/record-session/${selectedBook.id}');
                  },
                  icon: const Icon(Icons.timer),
                  label: const Text('Record New Session'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
            Text(
              selectedBook.description,
              style: context.textTheme.bodyMedium,
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }
}

class BookmarkButton extends ConsumerWidget {
  const BookmarkButton({super.key, required this.selectedBook});

  final Book selectedBook;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    log('bookmark button pressed & rebuilded');

    final bookmarkedItems = ref.watch(bookmarkNotifierProvider);

    return bookmarkedItems.when(
      data: (data) {
        // data is now List<ReadingProgressModel>
        final isBookmarked = data.any((progress) => progress.bookId == selectedBook.id);
        return IconButton(
          onPressed: () {
            if (isBookmarked) {
              _showRemoveBookmarkAlert(context, ref);
            } else {
              _toggleBookmark(ref);
            }
          },
          icon: Icon(
            isBookmarked ? Icons.bookmark : Icons.bookmark_border_rounded,
          ),
        );
      },
      error: (error, stack) => IconButton(
        onPressed: null,
        icon: const Icon(Icons.bookmark_border_rounded, color: Colors.grey),
      ),
      loading: () => IconButton(
        onPressed: null,
        icon: const Icon(Icons.bookmark_border_rounded, color: Colors.grey),
      ),
    );
  }

  Future<void> _toggleBookmark(WidgetRef ref) {
    return ref
        .read(bookmarkNotifierProvider.notifier)
        .toggleBookmark(selectedBook);
  }

  Future<dynamic> _showRemoveBookmarkAlert(
    BuildContext context,
    WidgetRef ref,
  ) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Are You Sure Want to Delete ?'),
        content: Text(
          'Book "${selectedBook.title}" will removed from bookmarked items',
          style: const TextStyle(fontWeight: FontWeight.w300),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              _toggleBookmark(ref);
              Navigator.pop(context);
            },
            child: const Text('Remove Book'),
          ),
        ],
      ),
    );
  }
}

Widget bookThumbnail(Book selectedBook) {
  return selectedBook.thumbnail.isEmpty
      ? AspectRatio(
          aspectRatio: 3 / 4,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black, width: 0.05),
            ),
            child: const Icon(Icons.print, size: 35),
          ),
        )
      : AspectRatio(
          aspectRatio: 3 / 4,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              border: Border.all(color: Colors.black, width: 0.2),
              image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(selectedBook.thumbnail),
              ),
            ),
          ),
        );
}
