import 'package:book_verse/core/utils/clock.dart';
import 'package:book_verse/features/goals/data/goals_datasource.dart';
import 'package:book_verse/features/goals/model/goal_progress.dart';
import 'package:book_verse/features/goals/model/reading_goal.dart';
import 'package:book_verse/features/goals/providers/goal_providers.dart';
import 'package:book_verse/features/reading_tracker/data/reading_tracker_datasource.dart';
import 'package:book_verse/features/reading_tracker/model/reading_session_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGoalsDatasource extends Mock implements GoalsDatasource {}

class MockReadingTracker extends Mock implements ReadingTrackerDatasource {}

void main() {
  late FakeClock clock;
  late MockReadingTracker mockTracker;
  late MockGoalsDatasource mockGoals;

  final today = DateTime(2026, 6, 10);
  final enabledGoal = DailyGoal(
    targetPages: 30,
    targetMinutes: 20,
    enabled: true,
    createdAt: today,
    updatedAt: today,
  );

  setUp(() {
    clock = FakeClock(today);
    mockTracker = MockReadingTracker();
    mockGoals = MockGoalsDatasource();

    when(() => mockTracker.getAllReadingSessions()).thenAnswer((_) async => []);
    when(() => mockGoals.getGoal()).thenAnswer((_) async => enabledGoal);
  });

  group('goalProgressProvider', () {
    ProviderContainer createContainer() {
      return ProviderContainer(
        overrides: [
          goalsDatasourceProvider.overrideWithValue(mockGoals),
          clockProvider.overrideWithValue(clock),
          readingTrackerDatasourceProvider.overrideWithValue(mockTracker),
        ],
      );
    }

    test('returns null when goal is disabled', () async {
      when(() => mockGoals.getGoal()).thenAnswer(
        (_) async => enabledGoal.copyWith(enabled: false),
      );

      final container = createContainer();
      container.read(dailyGoalProvider.notifier);
      await Future<void>.delayed(Duration.zero);

      final result = await container.read(goalProgressProvider.future);
      expect(result, isNull);
    });

    test('returns GoalProgress with zeros when no sessions today', () async {
      final container = createContainer();
      container.read(dailyGoalProvider.notifier);
      await Future<void>.delayed(Duration.zero);

      final result = await container.read(goalProgressProvider.future) as GoalProgress;
      expect(result.pagesRead, 0);
      expect(result.minutesRead, 0);
      expect(result.targetPages, 30);
      expect(result.targetMinutes, 20);
    });

    test('aggregates today sessions into pagesRead and minutesRead', () async {
      when(() => mockTracker.getAllReadingSessions()).thenAnswer(
        (_) async => [
          ReadingSessionModel(
            bookId: 'b1',
            durationInSeconds: 600,
            endPage: 15,
            startPage: 1,
            timestamp: DateTime(2026, 6, 10, 10, 0),
          ),
          ReadingSessionModel(
            bookId: 'b2',
            durationInSeconds: 300,
            endPage: 30,
            startPage: 15,
            timestamp: DateTime(2026, 6, 10, 14, 0),
          ),
        ],
      );

      final container = createContainer();
      container.read(dailyGoalProvider.notifier);
      await Future<void>.delayed(Duration.zero);

      final result = await container.read(goalProgressProvider.future) as GoalProgress;
      expect(result.pagesRead, 29);
      expect(result.minutesRead, 15);
    });

    test('only counts sessions from today, ignores past sessions', () async {
      when(() => mockTracker.getAllReadingSessions()).thenAnswer(
        (_) async => [
          ReadingSessionModel(
            bookId: 'b1',
            durationInSeconds: 600,
            endPage: 15,
            startPage: 1,
            timestamp: DateTime(2026, 6, 10, 10, 0),
          ),
          ReadingSessionModel(
            bookId: 'b2',
            durationInSeconds: 3000,
            endPage: 50,
            startPage: 1,
            timestamp: DateTime(2026, 5, 10, 14, 0),
          ),
        ],
      );

      final container = createContainer();
      container.read(dailyGoalProvider.notifier);
      await Future<void>.delayed(Duration.zero);

      final result = await container.read(goalProgressProvider.future) as GoalProgress;
      expect(result.pagesRead, 14);
      expect(result.minutesRead, 10);
    });

    test('handles null startPage by not counting pages', () async {
      when(() => mockTracker.getAllReadingSessions()).thenAnswer(
        (_) async => [
          ReadingSessionModel(
            bookId: 'b1',
            durationInSeconds: 600,
            endPage: 15,
            timestamp: DateTime(2026, 6, 10, 10, 0),
          ),
        ],
      );

      final container = createContainer();
      container.read(dailyGoalProvider.notifier);
      await Future<void>.delayed(Duration.zero);

      final result = await container.read(goalProgressProvider.future) as GoalProgress;
      expect(result.pagesRead, 0);
    });

    test('uses ceil for minutes conversion from seconds', () async {
      when(() => mockTracker.getAllReadingSessions()).thenAnswer(
        (_) async => [
          ReadingSessionModel(
            bookId: 'b1',
            durationInSeconds: 61,
            endPage: 5,
            startPage: 0,
            timestamp: DateTime(2026, 6, 10, 10, 0),
          ),
        ],
      );

      final container = createContainer();
      container.read(dailyGoalProvider.notifier);
      await Future<void>.delayed(Duration.zero);

      final result = await container.read(goalProgressProvider.future) as GoalProgress;
      expect(result.minutesRead, 2);
    });

    test('does not count pages when endPage <= startPage', () async {
      when(() => mockTracker.getAllReadingSessions()).thenAnswer(
        (_) async => [
          ReadingSessionModel(
            bookId: 'b1',
            durationInSeconds: 600,
            endPage: 5,
            startPage: 10,
            timestamp: DateTime(2026, 6, 10, 10, 0),
          ),
        ],
      );

      final container = createContainer();
      container.read(dailyGoalProvider.notifier);
      await Future<void>.delayed(Duration.zero);

      final result = await container.read(goalProgressProvider.future) as GoalProgress;
      expect(result.pagesRead, 0);
      expect(result.minutesRead, 10);
    });
  });
}
