import 'package:book_verse/core/models/book_model.dart';
import 'package:book_verse/core/services/sqflite_service.dart';
import 'package:book_verse/features/bookmarks/model/local_bookmark_service.dart';
import 'package:book_verse/features/reading_tracker/model/reading_progress_model.dart';

class BookmarkRepo {
  final LocalBookmarkService localBookmarkService;
  final SqfliteService _sqfliteService = SqfliteService.instance;

  BookmarkRepo({required this.localBookmarkService});

  Future<List<ReadingProgressModel>> getReadingProgressWithBooks() async {
    final booksMap = await localBookmarkService.getBookmarkedBooks();
    final progressMap = await _sqfliteService.getAllReadingProgress();

    final List<Book> books = booksMap.map((b) => Book.fromJson(b)).toList();

    return progressMap.map((progress) {
      final book = books.firstWhere((b) => b.id == progress.bookId,
          orElse: () => Book(
              id: progress.bookId,
              title: 'Unknown Book',
              authors: [],
              description: '',
              thumbnail: '',
              publishedDate: '',
              pageCount: 0,
              publisher: '',
              subTitle: ''));
      return progress.copyWith(book: book);
    }).toList();
  }

  Future<void> addToBookmark(Book book) async {
    await localBookmarkService.addToBookmark(book.toMap());
    final initialProgress = ReadingProgressModel(
      bookId: book.id,
      currentPage: 0,
    );
    await _sqfliteService.saveReadingProgress(initialProgress);
  }

  Future<void> removeBookmark(String bookId) async {
    await localBookmarkService.removeBookmark(bookId);
    await _sqfliteService.deleteReadingProgress(bookId);
  }

  Future<bool> isBookmarked(String id) async {
    final progress = await _sqfliteService.getReadingProgress(id);
    return progress != null;
  }
}
