import 'package:book_verse/core/utils/clock.dart';
import 'package:book_verse/features/dashboard/viewmodel/dashboard_viewmodel.dart';
import 'package:book_verse/features/reading_tracker/model/reading_progress_model.dart';
import 'package:book_verse/features/reading_tracker/model/reading_session_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/test_providers.dart';

void main() {
  late FakeClock clock;
  late MockReadingTrackerDatasource mockDatasource;
  late MockBookmarkDatasource mockBookmark;
  late MockLibraryFolderDatasource mockFolder;

  final today = DateTime(2026, 6, 10); // Wednesday

  setUp(() {
    clock = FakeClock(today);
    mockDatasource = MockReadingTrackerDatasource();
    mockBookmark = MockBookmarkDatasource();
    mockFolder = MockLibraryFolderDatasource();

    // Default mocks: empty data
    when(
      () => mockDatasource.getAllReadingSessions(),
    ).thenAnswer((_) async => []);
    when(() => mockBookmark.getBookmarkedBooks()).thenAnswer((_) async => []);
    when(
      () => mockDatasource.getAllReadingProgress(),
    ).thenAnswer((_) async => []);
    when(() => mockFolder.getAllFolders()).thenAnswer((_) async => []);
  });

  ProviderContainer createContainer() {
    return createTestContainer(
      clock: clock,
      readingTrackerDatasource: mockDatasource,
      bookmarkDatasource: mockBookmark,
      libraryFolderDatasource: mockFolder,
    );
  }

  group('DashboardViewModel', () {
    test('empty state returns all zeros', () async {
      final container = createContainer();
      final state = await container.read(dashboardProvider.future);

      expect(state.todayMinutes, 0);
      expect(state.todayPages, 0);
      expect(state.yesterdayMinutes, 0);
      expect(state.streak, 0);
      expect(state.currentlyReading, isEmpty);
      expect(state.weeklyReading, hasLength(7));
      for (final day in state.weeklyReading) {
        expect(day.minutes, 0);
        expect(day.pages, 0);
      }
    });

    test('single session today returns correct minutes and pages', () async {
      when(() => mockDatasource.getAllReadingSessions()).thenAnswer(
        (_) async => [
          ReadingSessionModel(
            bookId: 'b1',
            durationInSeconds: 600, // 10 min
            endPage: 15,
            startPage: null,
            timestamp: DateTime(2026, 6, 10, 14, 0),
          ),
        ],
      );

      final container = createContainer();
      final state = await container.read(dashboardProvider.future);

      expect(state.todayMinutes, 10);
      expect(state.todayPages, 15);
      expect(state.yesterdayMinutes, 0);
      expect(state.streak, 1);
    });

    test('yesterday and today sessions', () async {
      when(() => mockDatasource.getAllReadingSessions()).thenAnswer(
        (_) async => [
          ReadingSessionModel(
            bookId: 'b1',
            durationInSeconds: 300, // 5 min
            endPage: 10,
            startPage: null,
            timestamp: DateTime(2026, 6, 10, 10, 0),
          ),
          ReadingSessionModel(
            bookId: 'b1',
            durationInSeconds: 1200, // 20 min
            endPage: 30,
            startPage: null,
            timestamp: DateTime(2026, 6, 9, 15, 0),
          ),
        ],
      );

      final container = createContainer();
      final state = await container.read(dashboardProvider.future);

      expect(state.todayMinutes, 5);
      expect(state.yesterdayMinutes, 20);
      expect(state.streak, 2);
    });

    test('3-day streak is computed correctly', () async {
      when(() => mockDatasource.getAllReadingSessions()).thenAnswer(
        (_) async => [
          ReadingSessionModel(
            bookId: 'b1',
            durationInSeconds: 600,
            endPage: 10,
            timestamp: DateTime(2026, 6, 10, 10, 0),
          ),
          ReadingSessionModel(
            bookId: 'b1',
            durationInSeconds: 600,
            endPage: 10,
            timestamp: DateTime(2026, 6, 9, 10, 0),
          ),
          ReadingSessionModel(
            bookId: 'b1',
            durationInSeconds: 600,
            endPage: 10,
            timestamp: DateTime(2026, 6, 8, 10, 0),
          ),
        ],
      );

      final container = createContainer();
      final state = await container.read(dashboardProvider.future);

      expect(state.streak, 3);
    });

    test('weekly chart has correct labels and values', () async {
      // June 8 (Mon) and June 9 (Tue) have sessions
      when(() => mockDatasource.getAllReadingSessions()).thenAnswer(
        (_) async => [
          ReadingSessionModel(
            bookId: 'b1',
            durationInSeconds: 300, // 5 min, 10 pages
            endPage: 10,
            startPage: null,
            timestamp: DateTime(2026, 6, 8, 10, 0),
          ),
          ReadingSessionModel(
            bookId: 'b1',
            durationInSeconds: 600, // 10 min, 20 pages
            endPage: 20,
            startPage: null,
            timestamp: DateTime(2026, 6, 9, 10, 0),
          ),
        ],
      );

      final container = createContainer();
      final state = await container.read(dashboardProvider.future);

      // June 8 is Monday (index 0), June 9 is Tuesday (index 1)
      expect(state.weeklyReading[0].label, 'Mon');
      expect(state.weeklyReading[0].minutes, 5);
      expect(state.weeklyReading[0].pages, 10);
      expect(state.weeklyReading[1].label, 'Tue');
      expect(state.weeklyReading[1].minutes, 10);
      expect(state.weeklyReading[1].pages, 10); // continues from Mon endPage=10
      // Wednesday is today (index 2)
      expect(state.weeklyReading[2].isToday, true);
    });

    test('currentlyReading limited to 5 books', () async {
      when(
        () => mockDatasource.getAllReadingSessions(),
      ).thenAnswer((_) async => []);
      // Mock LibraryNotifier to return 7 currently reading books
      // by providing bookmark + progress data
      final books = List.generate(
        7,
        (i) => {
          'id': 'b$i',
          'title': 'Book $i',
          'authors': '["Author"]',
          'publisher': '',
          'publishedDate': '',
          'description': '',
          'thumbnail': '',
          'pageCount': 100,
          'categories': '',
        },
      );
      final List<ReadingProgressModel> progressEntries = List.generate(
        7,
        (i) => ReadingProgressModel(bookId: 'b$i', currentPage: 50, book: null),
      );

      when(
        () => mockBookmark.getBookmarkedBooks(),
      ).thenAnswer((_) async => books);
      when(
        () => mockDatasource.getAllReadingProgress(),
      ).thenAnswer((_) async => progressEntries);

      final container = createContainer();
      final state = await container.read(dashboardProvider.future);

      expect(state.currentlyReading.length, lessThanOrEqualTo(5));
    });
  });
}
