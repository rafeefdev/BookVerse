import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:BookVerse/model/book_model.dart';
import 'package:BookVerse/provider/playbook_services_provider.dart';
import 'package:BookVerse/provider/search_provider.dart';
import 'package:BookVerse/provider/bookmark_provider.dart';

class DetailPage extends ConsumerWidget {
  final String selectedBookId;
  final bool isFromSearch;

  const DetailPage({
    required this.selectedBookId,
    this.isFromSearch = false,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var textTheme = Theme.of(context).textTheme;
    
    // Get book data from appropriate provider
    List<Book> books = isFromSearch 
        ? ref.watch(searchNotifierProvider).result
        : ref.watch(bookNotifierProvider).data;
        
    int index = books.indexWhere((book) => book.id == selectedBookId);
    
    if (index == -1) {
      return Scaffold(
        appBar: AppBar(title: Text('Detail')),
        body: Center(
          child: Text('Book not found'),
        ),
      );
    }
    
    log('selectedBookId : $selectedBookId');

    Book selectedBook = books[index];

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail'),
        actionsPadding: EdgeInsets.only(right: 16),
        actions: [
          BookmarkButton(selectedBook: selectedBook),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title:
                  selectedBook.thumbnail.isEmpty
                      ? Center(
                        child: AspectRatio(
                          aspectRatio: 3 / 4,
                          child: Container(
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.black,
                                width: 0.05,
                              ),
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
            ),
            SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                spacing: 8,
                children: [
                  Text(
                    selectedBook.title,
                    style: TextStyle(
                      height: 1.2,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Visibility(
                    visible: selectedBook.subTitle != null,
                    child: Text(
                      selectedBook.subTitle!,
                      style: TextStyle(height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              title: Text(bookAuthors(selectedBook)),
              subtitle: Text('Author'),
              leading: Icon(Icons.person),
            ),
            ListTile(
              title: Text(selectedBook.publishedDate),
              subtitle: Text('Published date'),
              leading: Icon(Icons.calendar_month),
            ),
            ListTile(
              title: Text('${selectedBook.pageCount}'),
              subtitle: Text('Page count'),
              leading: Icon(Icons.menu_book_rounded),
            ),
            ListTile(
              title: Text(bookCategories(selectedBook)),
              subtitle: Text('Categories'),
              leading: Icon(Icons.file_copy),
            ),
            ListTile(
              title: Text(selectedBook.publisher),
              subtitle: Text('Publisher'),
              leading: Icon(Icons.print_rounded),
            ),
            ListTile(
              subtitle: Text(
                selectedBook.description,
                style: textTheme.bodyMedium,
                textAlign: TextAlign.justify,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String bookCategories(Book selectedBook) {
    List? bookCategories = selectedBook.categories;
    String result = 'Unknown Category';

    if (bookCategories!.length == 1) {
      result = bookCategories[0];
      return result;
    } else if (bookCategories.length > 1) {
      result = '${selectedBook.categories!.join(', ')}, etc';
    }
    return result;
  }
}

class BookmarkButton extends ConsumerWidget {
  const BookmarkButton({
    super.key,
    required this.selectedBook,
  });

  final Book selectedBook;

 
@override
  Widget build(BuildContext context, WidgetRef ref) {
    log('bookmark button pressed & rebuilded');

    final bookMarkedBooks = ref.watch(bookmarkNotifierProvider);
    final isBookmarked = bookMarkedBooks.any((book)=>book.id == selectedBook.id);

    return IconButton(
      onPressed: () {
        ref.read(bookmarkNotifierProvider.notifier).toggleBookmark(selectedBook);
      },
      icon: Icon(
        isBookmarked ? Icons.bookmark : Icons.bookmark_border_rounded,
      ),
    );
  }
}
