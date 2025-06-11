import 'package:BookVerse/model/book_model.dart';
import 'package:BookVerse/provider/search_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'bookmark_provider.g.dart';

@riverpod
class BookmarkNotifier extends _$BookmarkNotifier {
  @override
  List<Book> build() {
    return [];
  }

  void toggleBookmark(Book book) {
    final searchResult = ref.watch(searchNotifierProvider).result; 
    final currentBooks = state;
    final index = searchResult.indexWhere((b) => b.id == book.id);
    
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
      state = [...currentBooks, updatedBook];
    } else {
      // Book in list, remove it
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