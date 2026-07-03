import 'package:book_verse/core/utils/clock.dart';
import 'package:book_verse/features/dashboard/viewmodel/weekly_report_provider.dart';
import 'package:book_verse/features/reading_tracker/model/reading_session_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/test_providers.dart';

void main() {
  late FakeClock clock;
  late MockReadingTrackerDatasource mockDatasource;
  late MockBookmarkDatasource mockBookmark;

  final today = DateTime(2026, 6, 10); // Wednesday

  setUp(() {
    clock = FakeClock(today);
    mockDatasource = MockReadingTrackerDatasource();
    mockBookmark = MockBookmarkDatasource();

    when(
      () => mockDatasource.getAllReadingSessions(),
    ).thenAnswer((_) async => []);
    when(() => mockBookmark.getBookmarkedBooks()).thenAnswer((_) async => []);
  });

  group('weeklyReportProvider', () {
    test('empty state returns zeros and correct week range', () async {
      final container = createTestContainer(
        clock: clock,
        readingTrackerDatasource: mockDatasource,
        bookmarkDatasource: mockBookmark,
      );
      final state = await container.read(weeklyReportProvider(0).future);

      expect(state.totalPages, 0);
      expect(state.totalMinutes, 0);
      expect(state.totalSessions, 0);
      expect(state.activeDays, 0);
      expect(state.weeklyReading, hasLength(7));
      expect(state.booksRead, isEmpty);
      expect(state.weekStart, DateTime(2026, 6, 8)); // Monday
    });

    test('aggregates one session into correct day slot', () async {
      when(() => mockDatasource.getAllReadingSessions()).thenAnswer(
        (_) async => [
          ReadingSessionModel(
            bookId: 'b1',
            durationInSeconds: 600,
            endPage: 15,
            startPage: 1,
            timestamp: DateTime(2026, 6, 10, 14, 0), // Wednesday
          ),
        ],
      );

      final container = createTestContainer(
        clock: clock,
        readingTrackerDatasource: mockDatasource,
        bookmarkDatasource: mockBookmark,
      );
      final state = await container.read(weeklyReportProvider(0).future);

      expect(state.totalSessions, 1);
      expect(state.totalMinutes, 10);
      expect(state.totalPages, 14);
      expect(state.activeDays, 1);
      expect(state.weeklyReading[2].minutes, 10); // Wed = index 2
      expect(state.weeklyReading[2].pages, 14);
      expect(state.weeklyReading[2].isToday, true);
    });

    test('only counts sessions within the current week', () async {
      when(() => mockDatasource.getAllReadingSessions()).thenAnswer(
        (_) async => [
          ReadingSessionModel(
            bookId: 'b1',
            durationInSeconds: 600,
            endPage: 15,
            startPage: 1,
            timestamp: DateTime(2026, 6, 10, 14, 0), // this week
          ),
          ReadingSessionModel(
            bookId: 'b2',
            durationInSeconds: 3000,
            endPage: 50,
            startPage: 1,
            timestamp: DateTime(2026, 6, 1, 14, 0), // previous week
          ),
        ],
      );

      final container = createTestContainer(
        clock: clock,
        readingTrackerDatasource: mockDatasource,
        bookmarkDatasource: mockBookmark,
      );
      final state = await container.read(weeklyReportProvider(0).future);

      expect(state.totalSessions, 1);
      expect(state.totalMinutes, 10);
    });

    test('marks today correctly with isToday flag', () async {
      final container = createTestContainer(
        clock: clock,
        readingTrackerDatasource: mockDatasource,
        bookmarkDatasource: mockBookmark,
      );
      final state = await container.read(weeklyReportProvider(0).future);

      expect(state.weeklyReading[2].isToday, true); // Wednesday
      expect(state.weeklyReading[0].isToday, false); // Monday
      expect(state.weeklyReading[4].isToday, false); // Friday
    });

    test('calculates activeDays from days with reading', () async {
      when(() => mockDatasource.getAllReadingSessions()).thenAnswer(
        (_) async => [
          ReadingSessionModel(
            bookId: 'b1',
            durationInSeconds: 600,
            endPage: 15,
            startPage: 1,
            timestamp: DateTime(2026, 6, 8, 10, 0), // Monday
          ),
          ReadingSessionModel(
            bookId: 'b2',
            durationInSeconds: 300,
            endPage: 30,
            startPage: 1,
            timestamp: DateTime(2026, 6, 10, 14, 0), // Wednesday
          ),
        ],
      );

      final container = createTestContainer(
        clock: clock,
        readingTrackerDatasource: mockDatasource,
        bookmarkDatasource: mockBookmark,
      );
      final state = await container.read(weeklyReportProvider(0).future);

      expect(state.activeDays, 2);
    });

    test('weekOffset -1 shifts week to previous Monday', () async {
      when(() => mockDatasource.getAllReadingSessions()).thenAnswer(
        (_) async => [
          ReadingSessionModel(
            bookId: 'b1',
            durationInSeconds: 600,
            endPage: 15,
            startPage: 1,
            timestamp: DateTime(2026, 6, 3, 14, 0), // previous Wed
          ),
        ],
      );

      final container = createTestContainer(
        clock: clock,
        readingTrackerDatasource: mockDatasource,
        bookmarkDatasource: mockBookmark,
      );
      final state = await container.read(weeklyReportProvider(-1).future);

      expect(state.totalSessions, 1);
      expect(state.weekStart, DateTime(2026, 6, 1));
      expect(state.weeklyReading.every((d) => !d.isToday), true);
    });

    test('groups sessions by book for booksRead', () async {
      when(() => mockDatasource.getAllReadingSessions()).thenAnswer(
        (_) async => [
          ReadingSessionModel(
            bookId: 'b1',
            durationInSeconds: 600,
            endPage: 30,
            startPage: 1,
            timestamp: DateTime(2026, 6, 8, 10, 0),
          ),
          ReadingSessionModel(
            bookId: 'b1',
            durationInSeconds: 300,
            endPage: 50,
            startPage: 30,
            timestamp: DateTime(2026, 6, 9, 14, 0),
          ),
        ],
      );

      final container = createTestContainer(
        clock: clock,
        readingTrackerDatasource: mockDatasource,
        bookmarkDatasource: mockBookmark,
      );
      final state = await container.read(weeklyReportProvider(0).future);

      expect(state.booksRead, hasLength(1));
      expect(state.booksRead.first.totalSessions, 2);
      expect(state.booksRead.first.totalDurationSeconds, 900);
      expect(state.booksRead.first.totalPages, 49);
    });

    test('sorts booksRead by totalDurationSeconds descending', () async {
      when(() => mockDatasource.getAllReadingSessions()).thenAnswer(
        (_) async => [
          ReadingSessionModel(
            bookId: 'b1',
            durationInSeconds: 600,
            endPage: 30,
            startPage: 1,
            timestamp: DateTime(2026, 6, 8, 10, 0),
          ),
          ReadingSessionModel(
            bookId: 'b2',
            durationInSeconds: 1200,
            endPage: 50,
            startPage: 1,
            timestamp: DateTime(2026, 6, 9, 14, 0),
          ),
        ],
      );

      final container = createTestContainer(
        clock: clock,
        readingTrackerDatasource: mockDatasource,
        bookmarkDatasource: mockBookmark,
      );
      final state = await container.read(weeklyReportProvider(0).future);

      expect(state.booksRead, hasLength(2));
      expect(state.booksRead[0].totalDurationSeconds, 1200);
      expect(state.booksRead[1].totalDurationSeconds, 600);
    });
  });
}
