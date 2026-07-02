import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:book_verse/features/library/data/library_folder_datasource.dart';
import 'package:book_verse/features/library/model/library_folder_model.dart';
import '../../../helpers/test_db.dart';

void main() {
  late Database db;
  late LibraryFolderDatasource datasource;

  setUp(() async {
    db = await openTestDb();
    datasource = LibraryFolderDatasource(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('LibraryFolderDatasource', () {
    test('ensureDefaultFolder creates default folder', () async {
      await datasource.ensureDefaultFolder();
      final folders = await datasource.getAllFolders();
      expect(folders.any((f) => f.id == '__default__'), isTrue);
    });

    test('createFolder and getAllFolders', () async {
      final folder = LibraryFolder(
        id: 'f1',
        name: 'Fiction',
        icon: 'book',
        sortOrder: 0,
        createdAt: DateTime.now(),
      );
      await datasource.createFolder(folder);
      final folders = await datasource.getAllFolders();
      expect(folders.any((f) => f.id == 'f1'), isTrue);
    });

    test('renameFolder', () async {
      await datasource.createFolder(
        LibraryFolder(
          id: 'f1',
          name: 'Old',
          icon: 'folder',
          sortOrder: 0,
          createdAt: DateTime.now(),
        ),
      );
      await datasource.renameFolder('f1', 'New Name');
      final folder = await datasource.getFolder('f1');
      expect(folder?.name, 'New Name');
    });

    test('deleteFolder', () async {
      await datasource.createFolder(
        LibraryFolder(
          id: 'f1',
          name: 'Temp',
          icon: 'folder',
          sortOrder: 0,
          createdAt: DateTime.now(),
        ),
      );
      await datasource.deleteFolder('f1');
      final folder = await datasource.getFolder('f1');
      expect(folder, isNull);
    });

    test('addBookToFolder and getBookIdsInFolder', () async {
      await datasource.createFolder(
        LibraryFolder(
          id: 'f1',
          name: 'Test',
          icon: 'folder',
          sortOrder: 0,
          createdAt: DateTime.now(),
        ),
      );
      await datasource.addBookToFolder('f1', 'b1');
      final ids = await datasource.getBookIdsInFolder('f1');
      expect(ids, ['b1']);
    });

    test('removeBookFromFolder', () async {
      await datasource.createFolder(
        LibraryFolder(
          id: 'f1',
          name: 'Test',
          icon: 'folder',
          sortOrder: 0,
          createdAt: DateTime.now(),
        ),
      );
      await datasource.addBookToFolder('f1', 'b1');
      await datasource.removeBookFromFolder('f1', 'b1');
      final ids = await datasource.getBookIdsInFolder('f1');
      expect(ids, isEmpty);
    });

    test('isBookInFolder', () async {
      await datasource.createFolder(
        LibraryFolder(
          id: 'f1',
          name: 'Test',
          icon: 'folder',
          sortOrder: 0,
          createdAt: DateTime.now(),
        ),
      );
      await datasource.addBookToFolder('f1', 'b1');
      expect(await datasource.isBookInFolder('f1', 'b1'), isTrue);
      expect(await datasource.isBookInFolder('f1', 'b2'), isFalse);
    });

    test('assignToDefaultFolder', () async {
      await datasource.assignToDefaultFolder('b1');
      final ids = await datasource.getBookIdsInFolder('__default__');
      expect(ids, ['b1']);
    });
  });
}
