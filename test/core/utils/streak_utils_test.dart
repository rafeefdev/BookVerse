import 'package:book_verse/core/utils/streak_utils.dart';
import 'package:book_verse/features/reading_tracker/model/reading_session_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/factories.dart';

void main() {
  group('computeStreak', () {
    test('empty sessions returns 0', () {
      final result = computeStreak([], DateTime(2026, 6, 7));
      expect(result, 0);
    });

    test('single session today returns 1', () {
      final sessions = [
        createSession(bookId: 'b1', timestamp: DateTime(2026, 6, 7, 10, 0)),
      ];
      final result = computeStreak(sessions, DateTime(2026, 6, 7));
      expect(result, 1);
    });

    test('three consecutive days returns 3', () {
      final sessions = [
        createSession(bookId: 'b1', timestamp: DateTime(2026, 6, 7, 10, 0)),
        createSession(bookId: 'b1', timestamp: DateTime(2026, 6, 6, 10, 0)),
        createSession(bookId: 'b1', timestamp: DateTime(2026, 6, 5, 10, 0)),
      ];
      final result = computeStreak(sessions, DateTime(2026, 6, 7));
      expect(result, 3);
    });

    test('broken streak stops at gap', () {
      final sessions = [
        createSession(bookId: 'b1', timestamp: DateTime(2026, 6, 7, 10, 0)),
        createSession(bookId: 'b1', timestamp: DateTime(2026, 6, 6, 10, 0)),
        createSession(bookId: 'b1', timestamp: DateTime(2026, 6, 4, 10, 0)),
      ];
      final result = computeStreak(sessions, DateTime(2026, 6, 7));
      expect(result, 2);
    });

    test('session yesterday but not today returns 0 (streak is today-anchored)', () {
      final sessions = [
        createSession(bookId: 'b1', timestamp: DateTime(2026, 6, 6, 10, 0)),
      ];
      final result = computeStreak(sessions, DateTime(2026, 6, 7));
      expect(result, 0);
    });

    test('only old session with gap returns 0', () {
      final sessions = [
        createSession(bookId: 'b1', timestamp: DateTime(2026, 6, 4, 10, 0)),
      ];
      final result = computeStreak(sessions, DateTime(2026, 6, 7));
      expect(result, 0);
    });

    test('30 consecutive days returns 30', () {
      final sessions = List.generate(30, (i) {
        return createSession(
          bookId: 'b1',
          timestamp: DateTime(2026, 6, 7).subtract(Duration(days: i)),
        );
      });
      final result = computeStreak(sessions, DateTime(2026, 6, 7));
      expect(result, 30);
    });

    test('leap year feb 28-29 counts as 2 days streak', () {
      final sessions = [
        createSession(bookId: 'b1', timestamp: DateTime(2024, 2, 29, 10, 0)),
        createSession(bookId: 'b1', timestamp: DateTime(2024, 2, 28, 10, 0)),
        createSession(bookId: 'b1', timestamp: DateTime(2024, 2, 27, 10, 0)),
      ];
      final result = computeStreak(sessions, DateTime(2024, 2, 29));
      expect(result, 3);
    });

    test('year boundary retains streak', () {
      final sessions = [
        createSession(bookId: 'b1', timestamp: DateTime(2026, 1, 1, 10, 0)),
        createSession(bookId: 'b1', timestamp: DateTime(2025, 12, 31, 10, 0)),
        createSession(bookId: 'b1', timestamp: DateTime(2025, 12, 30, 10, 0)),
      ];
      final result = computeStreak(sessions, DateTime(2026, 1, 1));
      expect(result, 3);
    });

    test('multiple sessions same day count as 1', () {
      final sessions = [
        createSession(bookId: 'b1', timestamp: DateTime(2026, 6, 7, 10, 0)),
        createSession(bookId: 'b1', timestamp: DateTime(2026, 6, 7, 14, 0)),
        createSession(bookId: 'b1', timestamp: DateTime(2026, 6, 7, 20, 0)),
      ];
      final result = computeStreak(sessions, DateTime(2026, 6, 7));
      expect(result, 1);
    });

    test('invariant: result is always >= 0', () {
      final sessions = <ReadingSessionModel>[];
      final result = computeStreak(sessions, DateTime(2026, 6, 7));
      expect(result, greaterThanOrEqualTo(0));
    });
  });

  group('computeLongestStreak', () {
    test('empty sessions returns 0', () {
      expect(computeLongestStreak([]), 0);
    });

    test('single session returns 1', () {
      final sessions = [
        createSession(bookId: 'b1', timestamp: DateTime(2026, 6, 7)),
      ];
      expect(computeLongestStreak(sessions), 1);
    });

    test('consecutive days returns correct length', () {
      final sessions = List.generate(5, (i) {
        return createSession(
          bookId: 'b1',
          timestamp: DateTime(2026, 6, 7).subtract(Duration(days: i)),
        );
      });
      expect(computeLongestStreak(sessions), 5);
    });

    test('with gap picks longest segment', () {
      final sessions = [
        createSession(bookId: 'b1', timestamp: DateTime(2026, 6, 7)),
        createSession(bookId: 'b1', timestamp: DateTime(2026, 6, 6)),
        createSession(bookId: 'b1', timestamp: DateTime(2026, 6, 5)),
        createSession(bookId: 'b1', timestamp: DateTime(2026, 6, 3)),
        createSession(bookId: 'b1', timestamp: DateTime(2026, 6, 2)),
      ];
      expect(computeLongestStreak(sessions), 3);
    });

    test('unsorted input still works', () {
      final sessions = [
        createSession(bookId: 'b1', timestamp: DateTime(2026, 6, 1)),
        createSession(bookId: 'b1', timestamp: DateTime(2026, 6, 10)),
        createSession(bookId: 'b1', timestamp: DateTime(2026, 6, 9)),
        createSession(bookId: 'b1', timestamp: DateTime(2026, 6, 8)),
      ];
      expect(computeLongestStreak(sessions), 3);
    });
  });
}
