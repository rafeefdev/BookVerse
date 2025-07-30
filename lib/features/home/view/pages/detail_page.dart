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
    //if temporary source, indexing file from search provider
    //and from bookmark provider when its from bookmark provider
    var searchBookResult = ref.watch(searchNotifierProvider).result;
    var bookmarkedItems = ref.watch(bookmarkNotifierProvider);
    List<Book> books = isTemporarySource ? searchBookResult : bookmarkedItems;

    int index = books.indexWhere((book) => book.id == selectedBookId);

    if (index == -1) {
      return Scaffold(
        appBar: AppBar(title: Text('Detail')),
        body: Center(child: Text('Book not found')),
      );
    }

    Book selectedBook = books[index];
    log(
      '''selectedBookId : $selectedBookId\nauthors count : ${selectedBook.authors.length}
      \ntitle count : ${selectedBook.title.characters.length},''',
      level: 2,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail', style: context.textTheme.titleLarge),
        actionsPadding: EdgeInsets.only(right: 16),
        actions: [BookmarkButton(selectedBook: selectedBook)],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(left: 28, right: 28, top: 12, bottom: 28),
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
              spacing: 8,
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

    final bookMarkedBooks = ref.watch(bookmarkNotifierProvider);
    final isBookmarked = bookMarkedBooks.any(
      (book) => book.id == selectedBook.id,
    );

    return IconButton(
      onPressed: () {
        ref
            .read(bookmarkNotifierProvider.notifier)
            .toggleBookmark(selectedBook);
      },
      icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border_rounded),
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
          child: Icon(Icons.print, size: 35),
        ),
      )
      : AspectRatio(
        aspectRatio: 3 / 4,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            border: Border.all(color: Colors.black, width: 0.2),
            image: DecorationImage(
              fit: BoxFit.cover,
              image: NetworkImage(selectedBook.thumbnail),
            ),
          ),
        ),
      );
}
