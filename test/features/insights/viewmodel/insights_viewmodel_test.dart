import 'package:book_verse/core/models/book_model.dart';
import 'package:book_verse/core/utils/clock.dart';
import 'package:book_verse/features/insights/model/insights_state.dart';
import 'package:book_verse/features/insights/viewmodel/insights_viewmodel.dart';
import 'package:book_verse/features/library/model/library_repo_di.dart';
import 'package:book_verse/features/reading_tracker/data/reading_tracker_datasource.dart';
import 'package:book_verse/features/reading_tracker/model/reading_progress_model.dart';
import 'package:book_verse/features/reading_tracker/model/reading_session_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/test_providers.dart';

void main() {
  late FakeClock clock;
  late MockReadingTrackerDatasource mockDatasource;
  late MockLibraryRepo mockRepo;

  final today = DateTime(2026, 6, 10); // Wednesday

  setUp(() {
    clock = FakeClock(today);
    mockDatasource = MockReadingTrackerDatasource();
    mockRepo = MockLibraryRepo();

    when(() => mockDatasource.getAllReadingSessions())
        .thenAnswer((_) async => []);
    when(() => mockRepo.getAllProgressWithBooks())
        .thenAnswer((_) async => []);
  });

  group('InsightsViewModel', () {
    test('empty state returns all zeros', () async {
      final container = ProviderContainer(
        overrides: [
          clockProvider.overrideWithValue(clock),
          readingTrackerDatasourceProvider.overrideWithValue(mockDatasource),
          libraryRepoProvider.overrideWithValue(mockRepo),
        ],
      );
      final state = await container.read(insightsProvider.future);

      expect(state.totalMinutes, 0);
      expect(state.totalPages, 0);
      expect(state.totalBooks, 0);
      expect(state.currentStreak, 0);
      expect(state.longestStreak, 0);
      expect(state.streakStatus, StreakStatus.none);
      expect(state.achievements, hasLength(8));
      expect(state.genreDistribution, isEmpty);
      expect(state.monthlyMinutes, isEmpty);
      expect(state.ytdMinutes, 0);
      expect(state.ytdPages, 0);
    });

    test('all-time stats with multiple sessions across books', () async {
      when(() => mockDatasource.getAllReadingSessions()).thenAnswer(
        (_) async => [
          ReadingSessionModel(
            bookId: 'b1',
            durationInSeconds: 3600, // 60 min
            endPage: 30,
            startPage: 0,
            timestamp: DateTime(2026, 6, 10, 10, 0),
          ),
          ReadingSessionModel(
            bookId: 'b1',
            durationInSeconds: 1800, // 30 min
            endPage: 60,
            startPage: 30,
            timestamp: DateTime(2026, 6, 9, 10, 0),
          ),
          ReadingSessionModel(
            bookId: 'b2',
            durationInSeconds: 600, // 10 min
            endPage: 20,
            startPage: null,
            timestamp: DateTime(2026, 6, 8, 10, 0),
          ),
        ],
      );

      final container = ProviderContainer(
        overrides: [
          clockProvider.overrideWithValue(clock),
          readingTrackerDatasourceProvider.overrideWithValue(mockDatasource),
          libraryRepoProvider.overrideWithValue(mockRepo),
        ],
      );
      final state = await container.read(insightsProvider.future);

      expect(state.totalMinutes, 100); // 60 + 30 + 10
      expect(state.totalPages, 80); // 30 + 30 + 20
      expect(state.totalBooks, 2);
      expect(state.currentStreak, 3); // June 8, 9, 10
      expect(state.longestStreak, 3);
    });

    test('streakStatus: broken when currentStreak == 0 with books', () async {
      // b1 has sessions but none on June 9 or 10
      when(() => mockDatasource.getAllReadingSessions()).thenAnswer(
        (_) async => [
          ReadingSessionModel(
            bookId: 'b1',
            durationInSeconds: 600,
            endPage: 10,
            timestamp: DateTime(2026, 6, 7, 10, 0),
          ),
        ],
      );
      when(() => mockRepo.getAllProgressWithBooks()).thenAnswer(
        (_) async => [
          ReadingProgressModel(bookId: 'b1', currentPage: 10),
        ],
      );

      final container = ProviderContainer(
        overrides: [
          clockProvider.overrideWithValue(clock),
          readingTrackerDatasourceProvider.overrideWithValue(mockDatasource),
          libraryRepoProvider.overrideWithValue(mockRepo),
        ],
      );
      final state = await container.read(insightsProvider.future);

      expect(state.currentStreak, 0);
      expect(state.streakStatus, StreakStatus.broken);
    });

    test('streakStatus: atRisk when currentStreak 1-2', () async {
      when(() => mockDatasource.getAllReadingSessions()).thenAnswer(
        (_) async => [
          ReadingSessionModel(
            bookId: 'b1',
            durationInSeconds: 600,
            endPage: 10,
            timestamp: DateTime(2026, 6, 10, 10, 0),
          ),
        ],
      );
      when(() => mockRepo.getAllProgressWithBooks()).thenAnswer(
        (_) async => [
          ReadingProgressModel(bookId: 'b1', currentPage: 10),
        ],
      );

      final container = ProviderContainer(
        overrides: [
          clockProvider.overrideWithValue(clock),
          readingTrackerDatasourceProvider.overrideWithValue(mockDatasource),
          libraryRepoProvider.overrideWithValue(mockRepo),
        ],
      );
      final state = await container.read(insightsProvider.future);

      expect(state.currentStreak, 1);
      expect(state.streakStatus, StreakStatus.atRisk);
    });

    test('streakStatus: active when currentStreak >= 3', () async {
      when(() => mockDatasource.getAllReadingSessions()).thenAnswer(
        (_) async => List.generate(3, (i) {
          return ReadingSessionModel(
            bookId: 'b1',
            durationInSeconds: 600,
            endPage: 10 + i * 10,
            startPage: i * 10,
            timestamp: DateTime(2026, 6, 8 + i, 10, 0),
          );
        }),
      );
      when(() => mockRepo.getAllProgressWithBooks()).thenAnswer(
        (_) async => [
          ReadingProgressModel(bookId: 'b1', currentPage: 30),
        ],
      );

      final container = ProviderContainer(
        overrides: [
          clockProvider.overrideWithValue(clock),
          readingTrackerDatasourceProvider.overrideWithValue(mockDatasource),
          libraryRepoProvider.overrideWithValue(mockRepo),
        ],
      );
      final state = await container.read(insightsProvider.future);

      expect(state.currentStreak, 3);
      expect(state.streakStatus, StreakStatus.active);
    });

    test('streakHistory covers 90 days', () async {
      final container = ProviderContainer(
        overrides: [
          clockProvider.overrideWithValue(clock),
          readingTrackerDatasourceProvider.overrideWithValue(mockDatasource),
          libraryRepoProvider.overrideWithValue(mockRepo),
        ],
      );
      final state = await container.read(insightsProvider.future);

      expect(state.streakHistory, hasLength(90));
    });

    test('genre distribution with categorized books', () async {
      final book1 = Book(
        id: 'b1',
        title: 'Book 1',
        subTitle: '',
        authors: [],
        publisher: '',
        publishedDate: '',
        description: '',
        thumbnail: '',
        pageCount: 100,
        categories: ['Fiction'],
      );
      final book2 = Book(
        id: 'b2',
        title: 'Book 2',
        subTitle: '',
        authors: [],
        publisher: '',
        publishedDate: '',
        description: '',
        thumbnail: '',
        pageCount: 200,
        categories: ['Fiction'],
      );
      final book3 = Book(
        id: 'b3',
        title: 'Book 3',
        subTitle: '',
        authors: [],
        publisher: '',
        publishedDate: '',
        description: '',
        thumbnail: '',
        pageCount: 150,
        categories: ['Science'],
      );

      when(() => mockDatasource.getAllReadingSessions()).thenAnswer(
        (_) async => [],
      );
      when(() => mockRepo.getAllProgressWithBooks()).thenAnswer(
        (_) async => [
          ReadingProgressModel(bookId: 'b1', currentPage: 10, book: book1),
          ReadingProgressModel(bookId: 'b2', currentPage: 20, book: book2),
          ReadingProgressModel(bookId: 'b3', currentPage: 30, book: book3),
        ],
      );

      final container = ProviderContainer(
        overrides: [
          clockProvider.overrideWithValue(clock),
          readingTrackerDatasourceProvider.overrideWithValue(mockDatasource),
          libraryRepoProvider.overrideWithValue(mockRepo),
        ],
      );
      final state = await container.read(insightsProvider.future);

      expect(state.genreDistribution, hasLength(2));
      // Fiction: 2 books (66.67%), Science: 1 book (33.33%)
      final fiction = state.genreDistribution.firstWhere((g) => g.genre == 'Fiction');
      expect(fiction.bookCount, 2);
      expect(fiction.percentage, closeTo(66.67, 0.1));
    });

    test('achievements: bookworm unlocked at 100+ pages', () async {
      when(() => mockDatasource.getAllReadingSessions()).thenAnswer(
        (_) async => [
          ReadingSessionModel(
            bookId: 'b1',
            durationInSeconds: 600,
            endPage: 100,
            startPage: 0,
            timestamp: DateTime(2026, 6, 10, 10, 0),
          ),
        ],
      );

      final container = ProviderContainer(
        overrides: [
          clockProvider.overrideWithValue(clock),
          readingTrackerDatasourceProvider.overrideWithValue(mockDatasource),
          libraryRepoProvider.overrideWithValue(mockRepo),
        ],
      );
      final state = await container.read(insightsProvider.future);

      final bookworm = state.achievements.firstWhere((a) => a.id == 'bookworm');
      expect(bookworm.unlocked, true);
    });

    test('achievements: bookworm locked under 100 pages', () async {
      when(() => mockDatasource.getAllReadingSessions()).thenAnswer(
        (_) async => [
          ReadingSessionModel(
            bookId: 'b1',
            durationInSeconds: 600,
            endPage: 50,
            startPage: 0,
            timestamp: DateTime(2026, 6, 10, 10, 0),
          ),
        ],
      );

      final container = ProviderContainer(
        overrides: [
          clockProvider.overrideWithValue(clock),
          readingTrackerDatasourceProvider.overrideWithValue(mockDatasource),
          libraryRepoProvider.overrideWithValue(mockRepo),
        ],
      );
      final state = await container.read(insightsProvider.future);

      final bookworm = state.achievements.firstWhere((a) => a.id == 'bookworm');
      expect(bookworm.unlocked, false);
    });

    test('monthly minutes grouped by year and month', () async {
      final sessions = [
        ReadingSessionModel(
          bookId: 'b1',
          durationInSeconds: 3600,
          endPage: 30,
          startPage: 0,
          timestamp: DateTime(2026, 5, 15, 10, 0), // May
        ),
        ReadingSessionModel(
          bookId: 'b1',
          durationInSeconds: 1800,
          endPage: 60,
          startPage: 30,
          timestamp: DateTime(2026, 6, 10, 10, 0), // June
        ),
      ];

      when(() => mockDatasource.getAllReadingSessions())
          .thenAnswer((_) async => sessions);

      final container = ProviderContainer(
        overrides: [
          clockProvider.overrideWithValue(clock),
          readingTrackerDatasourceProvider.overrideWithValue(mockDatasource),
          libraryRepoProvider.overrideWithValue(mockRepo),
        ],
      );
      final state = await container.read(insightsProvider.future);

      expect(state.monthlyMinutes, hasLength(2));
      expect(state.monthlyMinutes[0].month, 5);
      expect(state.monthlyMinutes[0].minutes, 60);
      expect(state.monthlyMinutes[0].year, 2026);
      expect(state.monthlyMinutes[1].month, 6);
      expect(state.monthlyMinutes[1].minutes, 30);
      expect(state.monthlyMinutes[1].year, 2026);
    });

    test('Night Owl achievement requires sessions between 0-5 AM', () async {
      // Session at 3 AM should unlock Night Owl
      when(() => mockDatasource.getAllReadingSessions()).thenAnswer(
        (_) async => [
          ReadingSessionModel(
            bookId: 'b1',
            durationInSeconds: 600,
            endPage: 10,
            startPage: 0,
            timestamp: DateTime(2026, 6, 10, 3, 0), // 3 AM
          ),
        ],
      );

      final container = ProviderContainer(
        overrides: [
          clockProvider.overrideWithValue(clock),
          readingTrackerDatasourceProvider.overrideWithValue(mockDatasource),
          libraryRepoProvider.overrideWithValue(mockRepo),
        ],
      );
      final state = await container.read(insightsProvider.future);

      final nightOwl = state.achievements.firstWhere((a) => a.id == 'night_owl');
      expect(nightOwl.unlocked, true);
    });

    test('Night Owl locked when all sessions during daytime', () async {
      when(() => mockDatasource.getAllReadingSessions()).thenAnswer(
        (_) async => [
          ReadingSessionModel(
            bookId: 'b1',
            durationInSeconds: 600,
            endPage: 10,
            startPage: 0,
            timestamp: DateTime(2026, 6, 10, 14, 0), // 2 PM
          ),
        ],
      );

      final container = ProviderContainer(
        overrides: [
          clockProvider.overrideWithValue(clock),
          readingTrackerDatasourceProvider.overrideWithValue(mockDatasource),
          libraryRepoProvider.overrideWithValue(mockRepo),
        ],
      );
      final state = await container.read(insightsProvider.future);

      final nightOwl = state.achievements.firstWhere((a) => a.id == 'night_owl');
      expect(nightOwl.unlocked, false);
    });

    test('genre distribution handles null book gracefully', () async {
      when(() => mockDatasource.getAllReadingSessions()).thenAnswer(
        (_) async => [],
      );
      when(() => mockRepo.getAllProgressWithBooks()).thenAnswer(
        (_) async => [
          ReadingProgressModel(bookId: 'b1', currentPage: 10, book: null),
        ],
      );

      final container = ProviderContainer(
        overrides: [
          clockProvider.overrideWithValue(clock),
          readingTrackerDatasourceProvider.overrideWithValue(mockDatasource),
          libraryRepoProvider.overrideWithValue(mockRepo),
        ],
      );
      final state = await container.read(insightsProvider.future);

      // null book is skipped in genre distribution
      expect(state.genreDistribution, isEmpty);
    });

    test('genre distribution handles book with null categories', () async {
      final book = Book(
        id: 'b1',
        title: 'Test',
        subTitle: '',
        authors: [],
        publisher: '',
        publishedDate: '',
        description: '',
        thumbnail: '',
        pageCount: 100,
        categories: null,
      );

      when(() => mockDatasource.getAllReadingSessions()).thenAnswer(
        (_) async => [],
      );
      when(() => mockRepo.getAllProgressWithBooks()).thenAnswer(
        (_) async => [
          ReadingProgressModel(bookId: 'b1', currentPage: 10, book: book),
        ],
      );

      final container = ProviderContainer(
        overrides: [
          clockProvider.overrideWithValue(clock),
          readingTrackerDatasourceProvider.overrideWithValue(mockDatasource),
          libraryRepoProvider.overrideWithValue(mockRepo),
        ],
      );
      final state = await container.read(insightsProvider.future);

      // null categories → Uncategorized
      expect(state.genreDistribution, hasLength(1));
      expect(state.genreDistribution.first.genre, 'Uncategorized');
    });

    test('streakStatus returns none only when no sessions at all', () async {
      when(() => mockDatasource.getAllReadingSessions())
          .thenAnswer((_) async => []);
      when(() => mockRepo.getAllProgressWithBooks())
          .thenAnswer((_) async => []);

      final container = ProviderContainer(
        overrides: [
          clockProvider.overrideWithValue(clock),
          readingTrackerDatasourceProvider.overrideWithValue(mockDatasource),
          libraryRepoProvider.overrideWithValue(mockRepo),
        ],
      );
      final state = await container.read(insightsProvider.future);

      expect(state.totalBooks, 0);
      expect(state.streakStatus, StreakStatus.none);
    });

    test('no sessions today with books in progress returns broken', () async {
      when(() => mockDatasource.getAllReadingSessions()).thenAnswer(
        (_) async => [
          ReadingSessionModel(
            bookId: 'b1',
            durationInSeconds: 600,
            endPage: 10,
            timestamp: DateTime(2026, 6, 7, 10, 0), // 3 days ago
          ),
        ],
      );
      when(() => mockRepo.getAllProgressWithBooks()).thenAnswer(
        (_) async => [
          ReadingProgressModel(bookId: 'b1', currentPage: 10),
        ],
      );

      final container = ProviderContainer(
        overrides: [
          clockProvider.overrideWithValue(clock),
          readingTrackerDatasourceProvider.overrideWithValue(mockDatasource),
          libraryRepoProvider.overrideWithValue(mockRepo),
        ],
      );
      final state = await container.read(insightsProvider.future);

      expect(state.currentStreak, 0);
      expect(state.totalBooks, 1);
      expect(state.streakStatus, StreakStatus.broken);
    });

    test('YTD stats for current year', () async {
      final sessions = [
        // Jan session (within YTD)
        ReadingSessionModel(
          bookId: 'b1',
          durationInSeconds: 3600,
          endPage: 50,
          startPage: 0,
          timestamp: DateTime(2026, 1, 15, 10, 0),
        ),
        // June session (within YTD)
        ReadingSessionModel(
          bookId: 'b1',
          durationInSeconds: 1800,
          endPage: 80,
          startPage: 50,
          timestamp: DateTime(2026, 6, 10, 10, 0),
        ),
      ];

      when(() => mockDatasource.getAllReadingSessions())
          .thenAnswer((_) async => sessions);

      final container = ProviderContainer(
        overrides: [
          clockProvider.overrideWithValue(clock),
          readingTrackerDatasourceProvider.overrideWithValue(mockDatasource),
          libraryRepoProvider.overrideWithValue(mockRepo),
        ],
      );
      final state = await container.read(insightsProvider.future);

      expect(state.ytdMinutes, 90); // 60 + 30
      expect(state.ytdPages, 80); // 50 + 30
    });
  });
}
