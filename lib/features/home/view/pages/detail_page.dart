import 'package:book_verse/core/extensions/iterable_extensions.dart';
import 'package:book_verse/core/models/book_model.dart';
import 'package:book_verse/features/reading_tracker/model/reading_progress_model.dart';
import 'package:book_verse/core/shared/components/bookdetailinfo_component.dart';
import 'package:book_verse/core/shared/components/icontext_horizontal_component.dart';
import 'package:book_verse/core/shared/helpers/book_authors.dart';
import 'package:book_verse/core/shared/helpers/book_categories.dart';
import 'package:book_verse/core/shared/helpers/book_publishdate.dart';
import 'package:book_verse/core/theme/themes_extension.dart';
import 'package:book_verse/features/bookmarks/viewmodel/bookmark_viewmodel.dart';
import 'package:book_verse/features/home/providers/detail_providers.dart';
import 'package:book_verse/features/home/view/components/book_thumbnail.dart';
import 'package:book_verse/features/home/view/sections/book_description_section.dart';
import 'package:book_verse/features/home/view/sections/library_action_sheet.dart';
import 'package:book_verse/features/home/view/sections/reading_progress_section.dart';
import 'package:book_verse/features/search/viewmodel/search_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    if (isTemporarySource) {
      final searchBookResult = ref.watch(searchNotifierProvider).result;
      return _buildDetailPage(
        context,
        books: searchBookResult,
        selectedBookId: selectedBookId,
        ref: ref,
      );
    } else {
      final bookmarkedItems = ref.watch(bookmarkNotifierProvider);
      return bookmarkedItems.when(
        data: (bookProgressList) {
          final ReadingProgressModel? progress = bookProgressList
              .firstWhereOrNull((p) => p.bookId == selectedBookId);
          final Book? book = progress?.book;

          if (book != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref
                  .read(bookCacheProvider.notifier)
                  .update((state) => {...state, book.id: book});
            });
            return _buildDetailPage(
              context,
              book: book,
              selectedBookId: selectedBookId,
              ref: ref,
            );
          }

          final cachedBook = ref.read(bookCacheProvider)[selectedBookId];
          if (cachedBook != null) {
            return _buildDetailPage(
              context,
              book: cachedBook,
              selectedBookId: selectedBookId,
              ref: ref,
            );
          }

          return Scaffold(
            appBar: AppBar(
              title: Text('Detail', style: context.textTheme.titleLarge),
            ),
            body: const Center(child: Text('Book not found')),
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
}

Widget _buildDetailPage(
  BuildContext context, {
  List<Book>? books,
  Book? book,
  required String selectedBookId,
  required WidgetRef ref,
}) {
  Book selectedBook;
  if (book != null) {
    selectedBook = book;
  } else {
    if (books == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail')),
        body: const Center(child: Text('Book data not available')),
      );
    }
    int index = books.indexWhere((book) => book.id == selectedBookId);
    if (index == -1) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail')),
        body: const Center(child: Text('Book not found')),
      );
    }
    selectedBook = books[index];
  }

  return Scaffold(
    appBar: AppBar(
      title: Text('Detail', style: context.textTheme.titleLarge),
      actions: [
        LibraryActionButton(selectedBook: selectedBook),
        const SizedBox(width: 12),
      ],
    ),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: 28,
          right: 28,
          top: 12,
          bottom: 28,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: 216,
                child: BookThumbnail(selectedBook),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.start,
              verticalDirection: VerticalDirection.down,
              runSpacing: 8,
              children: [
                Text(
                  bookAuthors(selectedBook),
                  softWrap: true,
                  style: context.textTheme.titleLarge,
                ),
                Text(
                  (selectedBook.subTitle != null &&
                          selectedBook.subTitle!.isNotEmpty)
                      ? selectedBook.subTitle!
                      : 'Description is not available',
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
            ReadingProgressSection(selectedBook),
            const SizedBox(height: 24),
            BookDescriptionSection(selectedBook.description),
          ],
        ),
      ),
    ),
  );
}
