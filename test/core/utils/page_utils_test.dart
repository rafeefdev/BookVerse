import 'package:book_verse/core/utils/page_utils.dart';
import 'package:book_verse/features/reading_tracker/model/reading_session_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/factories.dart';

void main() {
  group('computePagesInRange', () {
    test('empty range returns 0', () {
      expect(
        computePagesInRange([], [], DateTime(2026, 6, 7)),
        0,
      );
    });

    test('single session with startPage computes diff', () {
      final sessions = [
        createSession(
          bookId: 'b1',
          timestamp: DateTime(2026, 6, 7, 10, 0),
          startPage: 10,
          endPage: 30,
        ),
      ];
      expect(
        computePagesInRange(sessions, sessions, DateTime(2026, 6, 7)),
        20,
      );
    });

    test('single session without startPage uses 0', () {
      final sessions = [
        createSession(
          bookId: 'b1',
          timestamp: DateTime(2026, 6, 7, 10, 0),
          endPage: 30,
        ),
      ];
      expect(
        computePagesInRange(sessions, sessions, DateTime(2026, 6, 7)),
        30,
      );
    });

    test('multiple books accumulate correctly', () {
      final allSessions = [
        createSession(
          bookId: 'b1',
          timestamp: DateTime(2026, 6, 7, 10, 0),
          startPage: 10,
          endPage: 30,
        ),
        createSession(
          bookId: 'b2',
          timestamp: DateTime(2026, 6, 7, 14, 0),
          startPage: 5,
          endPage: 15,
        ),
      ];
      expect(
        computePagesInRange(allSessions, allSessions, DateTime(2026, 6, 7)),
        30,
      );
    });

    test('with previous sessions looks backward for start', () {
      final before = [
        createSession(
          bookId: 'b1',
          timestamp: DateTime(2026, 6, 6, 10, 0),
          endPage: 50,
        ),
      ];
      final range = [
        createSession(
          bookId: 'b1',
          timestamp: DateTime(2026, 6, 7, 10, 0),
          endPage: 70,
        ),
      ];
      final all = [...before, ...range];
      expect(computePagesInRange(range, all, DateTime(2026, 6, 7)), 20);
    });

    test('endPage < startPage clamps to 0', () {
      final sessions = [
        ReadingSessionModel(
          bookId: 'b1',
          durationInSeconds: 600,
          endPage: 20,
          timestamp: DateTime(2026, 6, 7, 10, 0),
          startPage: 30,
        ),
      ];
      expect(
        computePagesInRange(sessions, sessions, DateTime(2026, 6, 7)),
        0,
      );
    });

    test('multiple sessions same book sequential', () {
      final range = [
        createSession(
          bookId: 'b1',
          timestamp: DateTime(2026, 6, 7, 10, 0),
          startPage: 10,
          endPage: 30,
        ),
        createSession(
          bookId: 'b1',
          timestamp: DateTime(2026, 6, 7, 14, 0),
          endPage: 50,
        ),
      ];
      expect(
        computePagesInRange(range, range, DateTime(2026, 6, 7)),
        40,
      );
    });

    test('gap in history uses last known endPage regardless of gap', () {
      final before = [
        createSession(
          bookId: 'b1',
          timestamp: DateTime(2026, 6, 5, 10, 0),
          endPage: 50,
        ),
      ];
      final range = [
        createSession(
          bookId: 'b1',
          timestamp: DateTime(2026, 6, 7, 10, 0),
          endPage: 70,
        ),
      ];
      final all = [...before, ...range];
      // looks back at ALL previous sessions (any gap), prevEndPage=50
      expect(computePagesInRange(range, all, DateTime(2026, 6, 7)), 20);
    });

    test('invariant: result is always >= 0', () {
      expect(
        computePagesInRange([], [], DateTime(2026, 6, 7)),
        greaterThanOrEqualTo(0),
      );
    });
  });

  group('computeAllTimePages', () {
    test('empty returns 0', () {
      expect(computeAllTimePages([]), 0);
    });

    test('single session without startPage uses 0', () {
      final sessions = [
        createSession(
          bookId: 'b1',
          timestamp: DateTime(2026, 6, 7),
          endPage: 30,
        ),
      ];
      expect(computeAllTimePages(sessions), 30);
    });

    test('multiple sequential sessions same book accumulate', () {
      final sessions = [
        createSession(
          bookId: 'b1',
          timestamp: DateTime(2026, 6, 7, 10, 0),
          startPage: 10,
          endPage: 30,
        ),
        createSession(
          bookId: 'b1',
          timestamp: DateTime(2026, 6, 7, 14, 0),
          endPage: 50,
        ),
      ];
      expect(computeAllTimePages(sessions), 40);
    });

    test('multiple books accumulate', () {
      final sessions = [
        createSession(
          bookId: 'b1',
          timestamp: DateTime(2026, 6, 7, 10, 0),
          endPage: 30,
        ),
        createSession(
          bookId: 'b2',
          timestamp: DateTime(2026, 6, 7, 14, 0),
          endPage: 20,
        ),
      ];
      expect(computeAllTimePages(sessions), 50);
    });
  });

  group('formatMinutes', () {
    test('0m returns "0m"', () => expect(formatMinutes(0), '0m'));
    test('30m returns "30m"', () => expect(formatMinutes(30), '30m'));
    test('60m returns "1h"', () => expect(formatMinutes(60), '1h'));
    test('90m returns "1h 30m"', () => expect(formatMinutes(90), '1h 30m'));
    test('120m returns "2h"', () => expect(formatMinutes(120), '2h'));
  });

  group('formatHours', () {
    test('0 returns "0m"', () => expect(formatHours(0), '0m'));
    test('30 returns "30m"', () => expect(formatHours(30), '30m'));
    test('60 returns "1h 0m"', () => expect(formatHours(60), '1h 0m'));
    test('90 returns "1h 30m"', () => expect(formatHours(90), '1h 30m'));
  });

  group('monthLabel', () {
    test('returns correct labels', () {
      expect(monthLabel(1), 'Jan');
      expect(monthLabel(6), 'Jun');
      expect(monthLabel(12), 'Dec');
    });
  });
}
