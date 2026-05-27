import 'dart:developer';

import 'package:book_verse/core/models/book_model.dart';
import 'package:book_verse/features/library/model/library_repo_di.dart';
import 'package:book_verse/features/library/model/library_folder_model.dart';
import 'package:book_verse/features/library/model/library_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'library_viewmodel.g.dart';

@Riverpod(keepAlive: true)
class LibraryNotifier extends _$LibraryNotifier {
  @override
  Future<LibraryState> build() async {
    try {
      final repo = ref.read(libraryRepoProvider);
      final allProgress = await repo.getAllProgressWithBooks();
      final folders = await repo.getAllFolders();

      final currentlyReading = allProgress
          .where((p) => p.book != null && p.currentPage < (p.book!.pageCount))
          .toList();
      final finished = allProgress
          .where(
            (p) =>
                p.book != null &&
                p.book!.pageCount > 0 &&
                p.currentPage >= p.book!.pageCount,
          )
          .toList();

      return LibraryState(
        currentlyReading: currentlyReading,
        finished: finished,
        folders: folders,
      );
    } catch (e, stack) {
      log('LibraryNotifier.build error: $e\n$stack');
      throw Exception('Failed to load library: $e');
    }
  }

  Future<void> createFolder(String name) async {
    try {
      final repo = ref.read(libraryRepoProvider);
      final folder = LibraryFolder(
        id: LibraryFolder.generateId(),
        name: name,
        createdAt: DateTime.now(),
      );
      await repo.createFolder(folder);
      ref.invalidateSelf();
      await future;
    } catch (e, stack) {
      log('createFolder error: $e\n$stack');
    }
  }

  Future<void> renameFolder(String folderId, String newName) async {
    try {
      final repo = ref.read(libraryRepoProvider);
      await repo.renameFolder(folderId, newName);
      ref.invalidateSelf();
      await future;
    } catch (e, stack) {
      log('renameFolder error: $e\n$stack');
    }
  }

  Future<void> deleteFolder(String folderId) async {
    try {
      final repo = ref.read(libraryRepoProvider);
      await repo.deleteFolder(folderId);
      ref.invalidateSelf();
      await future;
    } catch (e, stack) {
      log('deleteFolder error: $e\n$stack');
    }
  }

  Future<void> addBookToFolder(String folderId, String bookId) async {
    try {
      final repo = ref.read(libraryRepoProvider);
      await repo.addBookToFolder(folderId, bookId);
      ref.invalidateSelf();
      await future;
    } catch (e, stack) {
      log('addBookToFolder error: $e\n$stack');
    }
  }

  Future<void> removeBookFromFolder(String folderId, String bookId) async {
    try {
      final repo = ref.read(libraryRepoProvider);
      await repo.removeBookFromFolder(folderId, bookId);
      ref.invalidateSelf();
      await future;
    } catch (e, stack) {
      log('removeBookFromFolder error: $e\n$stack');
    }
  }

  Future<List<String>> getFolderIdsForBook(String bookId) async {
    try {
      final repo = ref.read(libraryRepoProvider);
      return repo.getFolderIdsForBook(bookId);
    } catch (e, stack) {
      log('getFolderIdsForBook error: $e\n$stack');
      return [];
    }
  }

  Future<void> removeBookFromAllFolders(String bookId) async {
    try {
      final repo = ref.read(libraryRepoProvider);
      await repo.removeBookFromAllFolders(bookId);
      ref.invalidateSelf();
      await future;
    } catch (e, stack) {
      log('removeBookFromAllFolders error: $e\n$stack');
    }
  }

  Future<List<Book>> getBooksInFolder(String folderId) async {
    try {
      final repo = ref.read(libraryRepoProvider);
      final bookIds = await repo.getBookIdsInFolder(folderId);
      final allBooks = await repo.getAllBookmarkedBooks();
      return allBooks.where((b) => bookIds.contains(b.id)).toList();
    } catch (e) {
      log('getBooksInFolder error: $e');
      return [];
    }
  }
}
