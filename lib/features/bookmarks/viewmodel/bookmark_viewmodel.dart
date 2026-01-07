import 'dart:developer';

import 'package:book_verse/core/models/book_model.dart';
import 'package:book_verse/features/bookmarks/model/bookmarkrepo_di.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'bookmark_viewmodel.g.dart';

@Riverpod(keepAlive: true)
class BookmarkNotifier extends _$BookmarkNotifier {
  @override
  Future<List<Book>> build() async {
    final bookmarkRepo = ref.watch(bookmarkRepoProvider);
    // return bookmarkrepo
    final bookmarkList = await bookmarkRepo.getBookmarkedBooks();
    return bookmarkList.map((book) => Book.fromJson(book)).toList();
  }

  Future<void> toggleBookmark(Book book) async {
    final currenctState = state;

    if (currenctState is! AsyncData<List<Book>>) return;

    final currentBooks = state.value;
    final index = currentBooks!.indexWhere((b) => b.id == book.id);

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
      // add bookmark to repo
      ref.read(bookmarkRepoProvider).addToBookmark(updatedBook);
      log('book "${book.title}" added to favorite list');
      state = AsyncData([...currentBooks, updatedBook]);
    } else {
      // Book in list, remove it
      log('book "${book.title}" removed from favorite list');
      // remove from repo
      ref.read(bookmarkRepoProvider).removeBookmark(book.id);
      state = AsyncData(currentBooks.where((b) => b.id != book.id).toList());
    }
  }

  bool isBookmarked(String bookId) {
    final stateValue = state.value;
    return stateValue!.any((book) => book.id == bookId);
  }
}
