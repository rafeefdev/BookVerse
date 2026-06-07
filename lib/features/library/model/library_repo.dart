import 'dart:developer';
import 'package:book_verse/core/models/book_model.dart';
import 'package:book_verse/features/bookmarks/data/bookmark_datasource.dart';
import 'package:book_verse/features/library/data/library_folder_datasource.dart';
import 'package:book_verse/features/library/model/library_folder_model.dart';
import 'package:book_verse/features/reading_tracker/data/reading_tracker_datasource.dart';
import 'package:book_verse/features/reading_tracker/model/reading_progress_model.dart';

class LibraryRepo {
  final BookmarkDatasource _bookmarkDatasource;
  final LibraryFolderDatasource _folderDatasource;
  final ReadingTrackerDatasource _readingTrackerDatasource;

  LibraryRepo({
    required BookmarkDatasource bookmarkDatasource,
    required LibraryFolderDatasource libraryFolderDatasource,
    required ReadingTrackerDatasource readingTrackerDatasource,
  })  : _bookmarkDatasource = bookmarkDatasource,
        _folderDatasource = libraryFolderDatasource,
        _readingTrackerDatasource = readingTrackerDatasource;

  Future<List<ReadingProgressModel>> getAllProgressWithBooks() async {
    try {
      final booksMap = await _bookmarkDatasource.getBookmarkedBooks();
      final progressMap =
          await _readingTrackerDatasource.getAllReadingProgress();
      final books = booksMap.map((b) => Book.fromJson(b)).toList();

      return progressMap.map((progress) {
        final book = books.firstWhere(
          (b) => b.id == progress.bookId,
          orElse: () => Book(
            id: progress.bookId,
            title: 'Unknown Book',
            authors: [],
            description: '',
            thumbnail: '',
            publishedDate: '',
            pageCount: 0,
            publisher: '',
            subTitle: '',
          ),
        );
        return progress.copyWith(book: book);
      }).toList();
    } catch (e, stack) {
      log('getAllProgressWithBooks error: $e\n$stack');
      return [];
    }
  }

  Future<List<Book>> getAllBookmarkedBooks() async {
    try {
      final booksMap = await _bookmarkDatasource.getBookmarkedBooks();
      return booksMap.map((b) => Book.fromJson(b)).toList();
    } catch (e, stack) {
      log('getAllBookmarkedBooks error: $e\n$stack');
      return [];
    }
  }

  Future<List<LibraryFolder>> getAllFolders() {
    return _folderDatasource.getAllFolders();
  }

  Future<List<String>> getAllBookIdsInAnyFolder() {
    return _folderDatasource.getAllBookIdsInAnyFolder();
  }

  Future<List<String>> getBookIdsInFolder(String folderId) {
    return _folderDatasource.getBookIdsInFolder(folderId);
  }

  Future<List<String>> getFolderIdsForBook(String bookId) {
    return _folderDatasource.getFolderIdsForBook(bookId);
  }

  Future<void> createFolder(LibraryFolder folder) {
    return _folderDatasource.createFolder(folder);
  }

  Future<void> renameFolder(String folderId, String newName) {
    return _folderDatasource.renameFolder(folderId, newName);
  }

  Future<void> deleteFolder(String folderId) {
    return _folderDatasource.deleteFolder(folderId);
  }

  Future<void> addBookToFolder(String folderId, String bookId) async {
    await _folderDatasource.addBookToFolder(folderId, bookId);
  }

  Future<void> removeBookFromFolder(String folderId, String bookId) async {
    await _folderDatasource.removeBookFromFolder(folderId, bookId);
  }

  Future<bool> isBookInAnyFolder(String bookId) async {
    final ids = await _folderDatasource.getFolderIdsForBook(bookId);
    return ids.isNotEmpty;
  }

  Future<void> saveBook(Book book) async {
    await _bookmarkDatasource.addToBookmark(book.toMap());
    await _folderDatasource.assignToDefaultFolder(book.id);
    final initialProgress = ReadingProgressModel(
      bookId: book.id,
      currentPage: 0,
    );
    await _readingTrackerDatasource.saveReadingProgress(initialProgress);
  }

  Future<void> removeBookFromAllFolders(String bookId) async {
    final ids = await _folderDatasource.getFolderIdsForBook(bookId);
    for (final folderId in ids) {
      await _folderDatasource.removeBookFromFolder(folderId, bookId);
    }
  }

  Future<void> ensureDefaultFolder() {
    return _folderDatasource.ensureDefaultFolder();
  }

  Future<void> removeBookmark(String bookId) async {
    await _bookmarkDatasource.removeBookmark(bookId);
    await _readingTrackerDatasource.deleteReadingProgress(bookId);
    await _readingTrackerDatasource.deleteReadingSessions(bookId);
  }
}
