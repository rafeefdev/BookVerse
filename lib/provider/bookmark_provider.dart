import 'dart:developer';

import 'package:book_verse/model/book_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'bookmark_provider.g.dart';

@Riverpod(keepAlive: true)
class BookmarkNotifier extends _$BookmarkNotifier {
  @override
  List<Book> build() {
    return [];
  }

  void toggleBookmark(Book book) {
    final currentBooks = state;
    final index = currentBooks.indexWhere((b) => b.id == book.id);

    if (index == -1) {
      // Book not in list, add it
      final updatedBook = Book(
        id: book.id,
        title: book.title,
        authors: book.authors,
        description: book.description,
        thumbnail: book.thumbnail,
        publishedDate: book.publishedDate,
        pageCount: book.pageCount,
        categories: book.categories,
        publisher: book.publisher,
        subTitle: book.subTitle,
        isFavorite: true,
      );
      log('book "${book.title}" added to favorite list');
      state = [...currentBooks, updatedBook];
    } else {
      // Book in list, remove it
      log('book "${book.title}" removed from favorite list');
      state = currentBooks.where((b) => b.id != book.id).toList();
    }
  }

  bool isBookmarked(String bookId) {
    return state.any((book) => book.id == bookId);
  }

  List<Book> getBookmarkedBooks() {
    return state;
  }
}
