import 'dart:developer';
import 'package:book_verse/core/services/sqflite_service.dart';
import 'package:book_verse/features/library/model/library_folder_model.dart';
import 'package:sqflite/sqflite.dart';

class LibraryFolderService {
  final SqfliteService _sqflite = SqfliteService.instance;
  static const _foldersTable = 'library_folders';
  static const _folderBooksTable = 'library_folder_books';
  static const defaultFolderId = '__default__';

  Future<void> ensureDefaultFolder() async {
    try {
      final db = await _sqflite.database;
      final existing = await db.query(
        _foldersTable,
        where: 'id = ?',
        whereArgs: [defaultFolderId],
      );
      if (existing.isEmpty) {
        await db.insert(_foldersTable, {
          'id': defaultFolderId,
          'name': 'Tanpa Folder',
          'icon': 'inbox',
          'sort_order': -1,
          'created_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e, stack) {
      log('ensureDefaultFolder error: $e\n$stack');
    }
  }

  Future<void> assignToDefaultFolder(String bookId) async {
    await ensureDefaultFolder();
    final ids = await getFolderIdsForBook(bookId);
    if (!ids.contains(defaultFolderId)) {
      await addBookToFolder(defaultFolderId, bookId);
    }
  }

  Future<List<LibraryFolder>> getAllFolders() async {
    try {
      final db = await _sqflite.database;
      final folders = await db.query(
        _foldersTable,
        orderBy: 'sort_order ASC, created_at ASC',
      );

      final result = <LibraryFolder>[];
      for (final f in folders) {
        final count = Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM $_folderBooksTable WHERE folder_id = ?',
            [f['id']],
          ),
        );
        result.add(LibraryFolder.fromMap(f, bookCount: count ?? 0));
      }
      return result;
    } catch (e, stack) {
      log('getAllFolders error: $e\n$stack');
      return [];
    }
  }

  Future<LibraryFolder?> getFolder(String folderId) async {
    try {
      final db = await _sqflite.database;
      final maps = await db.query(
        _foldersTable,
        where: 'id = ?',
        whereArgs: [folderId],
      );
      if (maps.isEmpty) return null;

      final count = Sqflite.firstIntValue(
        await db.rawQuery(
          'SELECT COUNT(*) FROM $_folderBooksTable WHERE folder_id = ?',
          [folderId],
        ),
      );
      return LibraryFolder.fromMap(maps.first, bookCount: count ?? 0);
    } catch (e, stack) {
      log('getFolder error: $e\n$stack');
      return null;
    }
  }

  Future<void> createFolder(LibraryFolder folder) async {
    try {
      final db = await _sqflite.database;
      await db.insert(_foldersTable, folder.toMap());
    } catch (e, stack) {
      log('createFolder error: $e\n$stack');
      rethrow;
    }
  }

  Future<void> renameFolder(String folderId, String newName) async {
    try {
      final db = await _sqflite.database;
      await db.update(
        _foldersTable,
        {'name': newName},
        where: 'id = ?',
        whereArgs: [folderId],
      );
    } catch (e, stack) {
      log('renameFolder error: $e\n$stack');
      rethrow;
    }
  }

  Future<void> deleteFolder(String folderId) async {
    try {
      final db = await _sqflite.database;
      await db.delete(
        _folderBooksTable,
        where: 'folder_id = ?',
        whereArgs: [folderId],
      );
      await db.delete(_foldersTable, where: 'id = ?', whereArgs: [folderId]);
    } catch (e, stack) {
      log('deleteFolder error: $e\n$stack');
      rethrow;
    }
  }

  Future<List<String>> getBookIdsInFolder(String folderId) async {
    try {
      final db = await _sqflite.database;
      final rows = await db.query(
        _folderBooksTable,
        columns: ['book_id'],
        where: 'folder_id = ?',
        whereArgs: [folderId],
        orderBy: 'added_at ASC',
      );
      return rows.map((r) => r['book_id'] as String).toList();
    } catch (e, stack) {
      log('getBookIdsInFolder error: $e\n$stack');
      return [];
    }
  }

  Future<bool> isBookInFolder(String folderId, String bookId) async {
    try {
      final db = await _sqflite.database;
      final count = Sqflite.firstIntValue(
        await db.rawQuery(
          'SELECT COUNT(*) FROM $_folderBooksTable WHERE folder_id = ? AND book_id = ?',
          [folderId, bookId],
        ),
      );
      return (count ?? 0) > 0;
    } catch (e, stack) {
      log('isBookInFolder error: $e\n$stack');
      return false;
    }
  }

  Future<List<String>> getFolderIdsForBook(String bookId) async {
    try {
      final db = await _sqflite.database;
      final rows = await db.query(
        _folderBooksTable,
        columns: ['folder_id'],
        where: 'book_id = ?',
        whereArgs: [bookId],
      );
      return rows.map((r) => r['folder_id'] as String).toList();
    } catch (e, stack) {
      log('getFolderIdsForBook error: $e\n$stack');
      return [];
    }
  }

  Future<void> addBookToFolder(String folderId, String bookId) async {
    try {
      final db = await _sqflite.database;
      await db.insert(_folderBooksTable, {
        'folder_id': folderId,
        'book_id': bookId,
        'added_at': DateTime.now().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e, stack) {
      log('addBookToFolder error: $e\n$stack');
      rethrow;
    }
  }

  Future<void> removeBookFromFolder(String folderId, String bookId) async {
    try {
      final db = await _sqflite.database;
      await db.delete(
        _folderBooksTable,
        where: 'folder_id = ? AND book_id = ?',
        whereArgs: [folderId, bookId],
      );
    } catch (e, stack) {
      log('removeBookFromFolder error: $e\n$stack');
      rethrow;
    }
  }

  Future<List<String>> getAllBookIdsInAnyFolder() async {
    try {
      final db = await _sqflite.database;
      final rows = await db.query(_folderBooksTable, columns: ['book_id']);
      return rows.map((r) => r['book_id'] as String).toList();
    } catch (e, stack) {
      log('getAllBookIdsInAnyFolder error: $e\n$stack');
      return [];
    }
  }
}
