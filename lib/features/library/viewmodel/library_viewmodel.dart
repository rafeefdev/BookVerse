import 'dart:developer';

import 'package:book_verse/core/models/book_model.dart';
import 'package:book_verse/features/library/model/finished_book_info.dart';
import 'package:book_verse/features/library/model/library_repo_di.dart';
import 'package:book_verse/features/library/model/library_folder_model.dart';
import 'package:book_verse/features/library/model/library_state.dart';
import 'package:book_verse/features/reading_tracker/data/reading_tracker_datasource.dart';
import 'package:book_verse/features/reading_tracker/model/reading_progress_model.dart';
import 'package:book_verse/features/reading_tracker/model/reading_session_model.dart';
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

      final currentlyReading = allProgress.where((p) {
        final book = p.book;
        return book != null &&
            p.currentPage < p.effectivePageCount &&
            p.totalReadingTimeInSeconds > 0;
      }).toList();
      final finished = allProgress.where((p) {
        final book = p.book;
        return book != null &&
            p.effectivePageCount > 0 &&
            p.currentPage >= p.effectivePageCount;
      }).toList();

      final finishedInfo = await _computeFinishedInfo(finished);

      return LibraryState(
        currentlyReading: currentlyReading,
        finished: finished,
        finishedInfo: finishedInfo,
        folders: folders,
      );
    } catch (e, stack) {
      log('LibraryNotifier.build error: $e\n$stack');
      throw Exception('Failed to load library: $e');
    }
  }

  Future<List<FinishedBookInfo>> _computeFinishedInfo(
    List<ReadingProgressModel> finished,
  ) async {
    if (finished.isEmpty) return [];

    final datasource = ref.read(readingTrackerDatasourceProvider);
    final allSessions = await datasource.getAllReadingSessions();

    final byBook = <String, List<ReadingSessionModel>>{};
    for (final s in allSessions) {
      byBook.putIfAbsent(s.bookId, () => []).add(s);
    }

    return finished.map((progress) {
      final sessions = byBook[progress.bookId] ?? [];
      sessions.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      final firstSession = sessions.isNotEmpty
          ? sessions.first.timestamp
          : null;
      final lastSession = sessions.isNotEmpty ? sessions.last.timestamp : null;
      final completionDate = progress.lastRead ?? lastSession;

      String? formattedDate;
      if (completionDate != null) {
        final months = [
          '',
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ];
        formattedDate =
            '${completionDate.day} ${months[completionDate.month]} ${completionDate.year}, '
            '${completionDate.hour.toString().padLeft(2, '0')}:'
            '${completionDate.minute.toString().padLeft(2, '0')}';
      }

      String? formattedDays;
      if (firstSession != null && lastSession != null) {
        final days = lastSession.difference(firstSession).inDays + 1;
        if (days >= 1) {
          formattedDays = '$days days';
        }
      }

      final totalSeconds = progress.totalReadingTimeInSeconds;
      final hours = totalSeconds ~/ 3600;
      final minutes = (totalSeconds % 3600) ~/ 60;
      final formattedTime = hours > 0 ? '${hours}j ${minutes}m' : '${minutes}m';

      return FinishedBookInfo(
        progress: progress,
        formattedCompletionDate: formattedDate,
        formattedDaysSpent: formattedDays,
        formattedTotalTime: formattedTime,
        totalSessions: sessions.length,
      );
    }).toList();
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
    final repo = ref.read(libraryRepoProvider);
    await repo.deleteFolder(folderId);
    ref.invalidateSelf();
    await future;
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
