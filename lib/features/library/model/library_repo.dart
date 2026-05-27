import 'dart:developer';
import 'package:book_verse/core/models/book_model.dart';
import 'package:book_verse/features/bookmarks/model/local_bookmark_service.dart';
import 'package:book_verse/features/library/model/library_folder_model.dart';
import 'package:book_verse/features/library/model/library_folder_service.dart';
import 'package:book_verse/features/reading_tracker/model/reading_progress_model.dart';
import 'package:book_verse/core/services/sqflite_service.dart';

class LibraryRepo {
  final LocalBookmarkService _bookmarkService = LocalBookmarkService();
  final LibraryFolderService _folderService = LibraryFolderService();
  final SqfliteService _sqflite = SqfliteService.instance;

  Future<List<ReadingProgressModel>> getAllProgressWithBooks() async {
    try {
      final booksMap = await _bookmarkService.getBookmarkedBooks();
      final progressMap = await _sqflite.getAllReadingProgress();
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
      final booksMap = await _bookmarkService.getBookmarkedBooks();
      return booksMap.map((b) => Book.fromJson(b)).toList();
    } catch (e, stack) {
      log('getAllBookmarkedBooks error: $e\n$stack');
      return [];
    }
  }

  Future<List<LibraryFolder>> getAllFolders() {
    return _folderService.getAllFolders();
  }

  Future<List<String>> getAllBookIdsInAnyFolder() {
    return _folderService.getAllBookIdsInAnyFolder();
  }

  Future<List<String>> getBookIdsInFolder(String folderId) {
    return _folderService.getBookIdsInFolder(folderId);
  }

  Future<List<String>> getFolderIdsForBook(String bookId) {
    return _folderService.getFolderIdsForBook(bookId);
  }

  Future<void> createFolder(LibraryFolder folder) {
    return _folderService.createFolder(folder);
  }

  Future<void> renameFolder(String folderId, String newName) {
    return _folderService.renameFolder(folderId, newName);
  }

  Future<void> deleteFolder(String folderId) {
    return _folderService.deleteFolder(folderId);
  }

  Future<void> addBookToFolder(String folderId, String bookId) async {
    await _folderService.addBookToFolder(folderId, bookId);
  }

  Future<void> removeBookFromFolder(String folderId, String bookId) async {
    await _folderService.removeBookFromFolder(folderId, bookId);
  }

  Future<bool> isBookInAnyFolder(String bookId) async {
    final ids = await _folderService.getFolderIdsForBook(bookId);
    return ids.isNotEmpty;
  }

  Future<void> saveBook(Book book) async {
    await _bookmarkService.addToBookmark(book.toMap());
    await _folderService.assignToDefaultFolder(book.id);
    final initialProgress = ReadingProgressModel(
      bookId: book.id,
      currentPage: 0,
    );
    await _sqflite.saveReadingProgress(initialProgress);
  }

  Future<void> removeBookFromAllFolders(String bookId) async {
    final ids = await _folderService.getFolderIdsForBook(bookId);
    for (final folderId in ids) {
      await _folderService.removeBookFromFolder(folderId, bookId);
    }
  }

  Future<void> ensureDefaultFolder() {
    return _folderService.ensureDefaultFolder();
  }

  Future<void> removeBookmark(String bookId) async {
    await _bookmarkService.removeBookmark(bookId);
  }
}
