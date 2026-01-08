import 'dart:developer';

import 'package:book_verse/core/models/book_model.dart';
import 'package:book_verse/features/bookmarks/model/bookmarkrepo_di.dart';
import 'package:book_verse/features/reading_tracker/model/reading_progress_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'bookmark_viewmodel.g.dart';

@Riverpod(keepAlive: true)
class BookmarkNotifier extends _$BookmarkNotifier {
  @override
  Future<List<ReadingProgressModel>> build() async {
    final bookmarkRepo = ref.watch(bookmarkRepoProvider);
    return bookmarkRepo.getReadingProgressWithBooks();
  }

  Future<void> toggleBookmark(Book book) async {
    final bookmarkRepo = ref.read(bookmarkRepoProvider);
    final isCurrentlyBookmarked = await bookmarkRepo.isBookmarked(book.id);

    if (isCurrentlyBookmarked) {
      log('book "${book.title}" removed from favorite list');
      await bookmarkRepo.removeBookmark(book.id);
    } else {
      log('book "${book.title}" added to favorite list');
      await bookmarkRepo.addToBookmark(book);
    }
    // Refresh the state
    ref.invalidateSelf();
    await future;
  }

  bool isBookmarked(String bookId) {
    final stateValue = state.valueOrNull ?? [];
    return stateValue.any((progress) => progress.bookId == bookId);
  }
}
