import 'dart:developer';

import 'package:BookVerse/helper/book_authors.dart';
import 'package:BookVerse/helper/book_categories.dart';
import 'package:BookVerse/view/components/bookdetailinfo_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:BookVerse/model/book_model.dart';
import 'package:BookVerse/provider/search_provider.dart';
import 'package:BookVerse/provider/bookmark_provider.dart';

class NewDetailpage extends ConsumerWidget {
  final String selectedBookId;
  final bool isTemporarySource;

  const NewDetailpage({
    required this.selectedBookId,
    super.key,
    required this.isTemporarySource,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var textTheme = Theme.of(context).textTheme;

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
      'selectedBookId : $selectedBookId\nauthors count : ${selectedBook.authors.length}',
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail'),
        actionsPadding: EdgeInsets.only(right: 16),
        actions: [BookmarkButton(selectedBook: selectedBook)],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(left: 28, right: 28, top: 12, bottom: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            selectedBook.thumbnail.isEmpty
                ? Center(
                  child: AspectRatio(
                    aspectRatio: 3 / 4,
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black, width: 0.05),
                      ),
                      child: Icon(Icons.print, size: 35),
                    ),
                  ),
                )
                : AspectRatio(
                  aspectRatio: 3 / 4,
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      border: Border.all(color: Colors.black, width: 0.2),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(selectedBook.thumbnail),
                      ),
                    ),
                  ),
                ),
            SizedBox(height: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedBook.title,
                  style: TextStyle(
                    height: 1.2,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  selectedBook.subTitle!.isEmpty
                      ? 'Description is not avalable'
                      : selectedBook.subTitle!,
                  style: TextStyle(height: 1.3),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                bookDetailInfoTile(
                  title: 'Authors',
                  data: bookAuthors(selectedBook),
                  icon: Icons.person_2_rounded,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                bookDetailInfoTile(
                  title: 'Published Date',
                  data: selectedBook.publishedDate,
                  icon: Icons.calendar_month_rounded,
                ),
                const SizedBox(width: 12),
                bookDetailInfoTile(
                  title: 'Page Count',
                  data: selectedBook.pageCount.toString(),
                  icon: Icons.menu_book_rounded,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                bookDetailInfoTile(
                  data: bookCategories(selectedBook),
                  icon: Icons.file_copy,
                  title: 'Categories',
                ),
                const SizedBox(width: 8),
                bookDetailInfoTile(
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
              style: TextStyle(fontSize: 16, color: Colors.blueGrey),
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
