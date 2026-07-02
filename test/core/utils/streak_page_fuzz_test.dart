import 'dart:math';
import 'package:book_verse/core/utils/page_utils.dart';
import 'package:book_verse/core/utils/streak_utils.dart';
import 'package:book_verse/features/reading_tracker/model/reading_session_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// Property-based fuzz tests for streak & page computation invariants.
/// Uses pseudo-random values to validate invariants under many inputs.
/// No external dependency (unlike glados/propcheck).

final _rng = Random(42);

ReadingSessionModel _randomSession({
  required String bookId,
  required DateTime day,
  int? startPage,
  int? endPage,
}) {
  return ReadingSessionModel(
    bookId: bookId,
    durationInSeconds: _rng.nextInt(7200),
    endPage: endPage ?? _rng.nextInt(500),
    timestamp: DateTime(
      day.year,
      day.month,
      day.day,
      _rng.nextInt(24),
      _rng.nextInt(60),
    ),
    startPage: startPage,
  );
}

List<ReadingSessionModel> _randomSessions(int count, {int maxDays = 90}) {
  if (count == 0) return [];
  final sessions = <ReadingSessionModel>[];
  final today = DateTime(2026, 6, 10);
  for (var i = 0; i < count; i++) {
    final offset = _rng.nextInt(maxDays);
    final day = today.subtract(Duration(days: offset));
    sessions.add(_randomSession(bookId: 'b${_rng.nextInt(5)}', day: day));
  }
  return sessions;
}

void main() {
  group('Fuzz: computeStreak invariants', () {
    test('always returns >= 0 for any input', () {
      final today = DateTime(2026, 6, 10);
      for (var i = 0; i < 100; i++) {
        final sessions = _randomSessions(_rng.nextInt(50));
        final result = computeStreak(sessions, today);
        expect(
          result,
          greaterThanOrEqualTo(0),
          reason: 'streak must be >= 0 for session count ${sessions.length}',
        );
      }
    });

    test('never exceeds number of unique days', () {
      final today = DateTime(2026, 6, 10);
      for (var i = 0; i < 100; i++) {
        final sessions = _randomSessions(_rng.nextInt(50));
        final uniqueDays = sessions
            .map(
              (s) => DateTime(
                s.timestamp.year,
                s.timestamp.month,
                s.timestamp.day,
              ),
            )
            .toSet()
            .length;
        final result = computeStreak(sessions, today);
        expect(
          result,
          lessThanOrEqualTo(uniqueDays),
          reason:
              'streak $result > unique days $uniqueDays for ${sessions.length} sessions',
        );
      }
    });

    test('multiple sessions same day count as 1 day', () {
      final today = DateTime(2026, 6, 10);
      for (var i = 0; i < 50; i++) {
        final count = _rng.nextInt(10) + 1;
        final sessions = List.generate(
          count,
          (_) => _randomSession(
            bookId: 'b1',
            day: today,
            startPage: _rng.nextInt(100),
            endPage: _rng.nextInt(500) + 100,
          ),
        );
        final result = computeStreak(sessions, today);
        expect(
          result,
          greaterThanOrEqualTo(1),
          reason: 'sessions today should give streak >= 1',
        );
      }
    });

    test('only future sessions does not affect streak', () {
      final today = DateTime(2026, 6, 10);
      for (var i = 0; i < 50; i++) {
        final count = _rng.nextInt(10) + 1;
        final sessions = List.generate(
          count,
          (_) => _randomSession(
            bookId: 'b1',
            day: today.add(Duration(days: _rng.nextInt(30) + 1)),
          ),
        );
        final result = computeStreak(sessions, today);
        expect(result, 0, reason: 'only future sessions should give streak 0');
      }
    });
  });

  group('Fuzz: computeLongestStreak invariants', () {
    test('always returns >= 0 for any input', () {
      for (var i = 0; i < 100; i++) {
        final sessions = _randomSessions(_rng.nextInt(50));
        final result = computeLongestStreak(sessions);
        expect(
          result,
          greaterThanOrEqualTo(0),
          reason: 'longest streak must be >= 0',
        );
      }
    });

    test('longest streak >= current streak', () {
      final today = DateTime(2026, 6, 10);
      for (var i = 0; i < 100; i++) {
        final sessions = _randomSessions(_rng.nextInt(50));
        final current = computeStreak(sessions, today);
        final longest = computeLongestStreak(sessions);
        expect(
          longest,
          greaterThanOrEqualTo(current),
          reason: 'longest $longest < current $current',
        );
      }
    });
  });

  group('Fuzz: computePagesInRange invariants', () {
    test('always returns >= 0 for any input', () {
      for (var i = 0; i < 100; i++) {
        final all = _randomSessions(_rng.nextInt(30));
        final rangeStart = DateTime(
          2026,
          6,
          10,
        ).subtract(Duration(days: _rng.nextInt(90)));
        final range = all
            .where((s) => !s.timestamp.isBefore(rangeStart))
            .toList();
        final result = computePagesInRange(range, all, rangeStart);
        expect(
          result,
          greaterThanOrEqualTo(0),
          reason: 'pages in range must be >= 0',
        );
      }
    });

    test('empty range returns 0', () {
      for (var i = 0; i < 50; i++) {
        final all = _randomSessions(_rng.nextInt(30));
        final futureDate = DateTime(2026, 6, 10).add(Duration(days: 365));
        final result = computePagesInRange([], all, futureDate);
        expect(result, 0);
      }
    });

    test('invariant: range pages <= sum of (endPage) when no startPage', () {
      for (var i = 0; i < 50; i++) {
        final sessions = <ReadingSessionModel>[];
        for (var j = 0; j < _rng.nextInt(20); j++) {
          sessions.add(
            ReadingSessionModel(
              bookId: 'b1',
              durationInSeconds: 0,
              endPage: _rng.nextInt(1000),
              timestamp: DateTime(2026, 6, 10 - j, 10, 0),
            ),
          );
        }
        final allTime = computeAllTimePages(sessions);
        final totalEndPage = sessions.fold<int>(0, (s, e) => s + e.endPage);
        expect(
          allTime,
          lessThanOrEqualTo(totalEndPage),
          reason: 'all-time pages $allTime > total endPage $totalEndPage',
        );
      }
    });
  });

  group('Fuzz: computeAllTimePages invariants', () {
    test('always returns >= 0 for any input', () {
      for (var i = 0; i < 100; i++) {
        final sessions = _randomSessions(_rng.nextInt(30));
        final result = computeAllTimePages(sessions);
        expect(result, greaterThanOrEqualTo(0));
      }
    });

    test('empty list returns 0', () {
      expect(computeAllTimePages([]), 0);
    });
  });

  group('Fuzz: cross-function consistency', () {
    test(
      'computePagesInRange with all sessions matches computeAllTimePages',
      () {
        final today = DateTime(2026, 6, 10);
        for (var i = 0; i < 50; i++) {
          final sessions = _randomSessions(_rng.nextInt(20));
          final weekStart = today.subtract(Duration(days: 365));
          // computePagesInRange from weekStart to forever
          final rangeSessions = sessions
              .where((s) => !s.timestamp.isBefore(weekStart))
              .toList();
          final rangePages = computePagesInRange(
            rangeSessions,
            sessions,
            weekStart,
          );
          final allPages = computeAllTimePages(sessions);
          expect(
            rangePages,
            lessThanOrEqualTo(allPages),
            reason: 'range pages $rangePages > all pages $allPages',
          );
        }
      },
    );

    test(
      'computePagesInRange with single session equals its endPage when startPage=0',
      () {
        final today = DateTime(2026, 6, 10);
        for (var i = 0; i < 50; i++) {
          final endPage = _rng.nextInt(500);
          final session = ReadingSessionModel(
            bookId: 'b1',
            durationInSeconds: 600,
            endPage: endPage,
            startPage: 0,
            timestamp: today,
          );
          final result = computePagesInRange([session], [session], today);
          expect(
            result,
            endPage,
            reason:
                'single session with startPage=0 should give endPage=$endPage, got $result',
          );
        }
      },
    );

    test('computePagesInRange with single session without startPage uses 0', () {
      final today = DateTime(2026, 6, 10);
      for (var i = 0; i < 50; i++) {
        final endPage = _rng.nextInt(500);
        final session = ReadingSessionModel(
          bookId: 'b1',
          durationInSeconds: 600,
          endPage: endPage,
          timestamp: today,
        );
        final result = computePagesInRange([session], [session], today);
        expect(
          result,
          endPage,
          reason:
              'single session without startPage uses 0 fallback, should give endPage=$endPage, got $result',
        );
      }
    });
  });
}
