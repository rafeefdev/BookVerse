import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:book_verse/features/reading_tracker/data/reading_tracker_datasource.dart';
import 'package:book_verse/features/reading_tracker/model/reading_progress_model.dart';
import 'package:book_verse/features/reading_tracker/model/reading_session_model.dart';
import '../../../helpers/test_db.dart';

void main() {
  late Database db;
  late ReadingTrackerDatasource datasource;

  setUp(() async {
    db = await openTestDb();
    datasource = ReadingTrackerDatasource(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('ReadingProgress', () {
    final progress = ReadingProgressModel(
      bookId: 'b1',
      currentPage: 42,
      totalReadingTimeInSeconds: 3600,
      lastRead: DateTime(2025, 1, 15),
    );

    test('save and read', () async {
      await datasource.saveReadingProgress(progress);
      final result = await datasource.getReadingProgress('b1');
      expect(result, equals(progress));
    });

    test('returns null for missing book', () async {
      final result = await datasource.getReadingProgress('nonexistent');
      expect(result, isNull);
    });

    test('lists all progress', () async {
      await datasource.saveReadingProgress(progress);
      await datasource.saveReadingProgress(
        progress.copyWith(bookId: 'b2', currentPage: 10),
      );
      final all = await datasource.getAllReadingProgress();
      expect(all.length, 2);
    });

    test('delete progress', () async {
      await datasource.saveReadingProgress(progress);
      await datasource.deleteReadingProgress('b1');
      final result = await datasource.getReadingProgress('b1');
      expect(result, isNull);
    });

    test('update user page count', () async {
      await datasource.saveReadingProgress(progress);
      await datasource.updateUserPageCount('b1', 300);
      final result = await datasource.getReadingProgress('b1');
      expect(result?.userPageCount, 300);
    });
  });

  group('ReadingSessions', () {
    final session = ReadingSessionModel(
      bookId: 'b1',
      durationInSeconds: 600,
      endPage: 30,
      timestamp: DateTime(2025, 1, 15),
    );

    test('save and get sessions', () async {
      await datasource.saveReadingSession(session);
      final sessions = await datasource.getReadingSessions('b1');
      expect(sessions.length, 1);
      expect(sessions.first, equals(session));
    });

    test('get all sessions across books', () async {
      final s2 = ReadingSessionModel(
        bookId: 'b2',
        durationInSeconds: 300,
        endPage: 15,
        timestamp: DateTime(2025, 1, 16),
      );
      await datasource.saveReadingSession(session);
      await datasource.saveReadingSession(s2);
      final all = await datasource.getAllReadingSessions();
      expect(all.length, 2);
    });

    test('delete sessions', () async {
      await datasource.saveReadingSession(session);
      await datasource.deleteReadingSessions('b1');
      final sessions = await datasource.getReadingSessions('b1');
      expect(sessions, isEmpty);
    });

    test('replaceAll', () async {
      await datasource.saveReadingProgress(
        ReadingProgressModel(bookId: 'old', currentPage: 5),
      );
      await datasource.saveReadingSession(session);

      final newProgress = [
        ReadingProgressModel(bookId: 'new', currentPage: 10),
      ];
      final newSessions = [
        ReadingSessionModel(
          bookId: 'new',
          durationInSeconds: 100,
          endPage: 5,
          timestamp: DateTime(2025, 1, 17),
        ),
      ];

      await datasource.replaceAll(newProgress, newSessions);

      expect(await datasource.getReadingProgress('old'), isNull);
      expect(await datasource.getReadingSessions('b1'), isEmpty);
      expect(await datasource.getReadingProgress('new'), isNotNull);
      expect(await datasource.getReadingSessions('new'), hasLength(1));
    });
  });
}
