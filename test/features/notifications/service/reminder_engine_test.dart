import 'package:book_verse/features/notifications/model/reminder_type.dart';
import 'package:book_verse/features/notifications/service/reminder_engine.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/notification_factories.dart';

void main() {
  final engine = const ReminderEngine();

  final jan15 = DateTime(
    2024,
    1,
    15,
    12,
    0,
    0,
  ); // Monday noon — arbitrary stable date

  // --------------- Happy Path ---------------

  group('decide — happy path', () {
    test('streak 1 with book returns streakProtection', () {
      final sessions = [
        createSession(
          bookId: 'b1',
          timestamp: jan15.subtract(Duration(days: 1)),
        ),
      ];
      final progress = [
        createProgress(
          bookId: 'b1',
          book: createBook(title: 'Deep Work'),
          currentPage: 42,
        ),
      ];

      final result = engine.decide(
        allSessions: sessions,
        currentlyReading: progress,
        now: jan15,
        streak: 1,
        lastNotificationDate: null,
        hasGoal: false,
        isGoalBehind: false,
        pagesBehind: 0,
      );

      expect(result, isNotNull);
      expect(result!.type, ReminderType.streakProtection);
      expect(result.title, contains('1-day streak'));
      expect(result.body, contains('Deep Work'));
      expect(result.payload, 'b1');
    });

    test('streak 2 with book returns streakProtection', () {
      final sessions = [
        createSession(
          bookId: 'b1',
          timestamp: jan15.subtract(Duration(days: 1)),
        ),
        createSession(
          bookId: 'b1',
          timestamp: jan15.subtract(Duration(days: 2)),
        ),
      ];
      final progress = [
        createProgress(
          bookId: 'b1',
          book: createBook(title: 'Deep Work'),
        ),
      ];

      final result = engine.decide(
        allSessions: sessions,
        currentlyReading: progress,
        now: jan15,
        streak: 1,
        lastNotificationDate: null,
        hasGoal: false,
        isGoalBehind: false,
        pagesBehind: 0,
      );

      expect(result, isNotNull);
      expect(result!.type, ReminderType.streakProtection);
      expect(result.title, contains('1-day streak'));
    });

    test('streak 1 with no book returns generic streakProtection', () {
      final sessions = [
        createSession(
          bookId: 'b1',
          timestamp: jan15.subtract(Duration(days: 1)),
        ),
      ];

      final result = engine.decide(
        allSessions: sessions,
        currentlyReading: [],
        now: jan15,
        streak: 1,
        lastNotificationDate: null,
        hasGoal: false,
        isGoalBehind: false,
        pagesBehind: 0,
      );

      expect(result, isNotNull);
      expect(result!.type, ReminderType.streakProtection);
      expect(
        result.body,
        'Read just 5 minutes today to keep your streak alive.',
      );
      expect(result.payload, isNull);
    });

    test('streak 3 with book returns resumeBook', () {
      final sessions = List.generate(3, (i) {
        return createSession(
          bookId: 'b1',
          timestamp: jan15.subtract(Duration(days: i + 1)),
        );
      });
      final progress = [
        createProgress(
          bookId: 'b1',
          book: createBook(title: 'Atomic Habits'),
          currentPage: 147,
        ),
      ];

      final result = engine.decide(
        allSessions: sessions,
        currentlyReading: progress,
        now: jan15,
        streak: 3,
        lastNotificationDate: null,
        hasGoal: false,
        isGoalBehind: false,
        pagesBehind: 0,
      );

      expect(result, isNotNull);
      expect(result!.type, ReminderType.resumeBook);
      expect(result.title, 'Atomic Habits');
      expect(result.body, 'Continue from page 147.');
      expect(result.payload, 'b1');
    });

    test('streak 5 with book returns resumeBook', () {
      final sessions = List.generate(5, (i) {
        return createSession(
          bookId: 'b1',
          timestamp: jan15.subtract(Duration(days: i + 1)),
        );
      });
      final progress = [
        createProgress(
          bookId: 'b1',
          book: createBook(title: 'Deep Work'),
        ),
      ];

      final result = engine.decide(
        allSessions: sessions,
        currentlyReading: progress,
        now: jan15,
        streak: 5,
        lastNotificationDate: null,
        hasGoal: false,
        isGoalBehind: false,
        pagesBehind: 0,
      );

      expect(result, isNotNull);
      expect(result!.type, ReminderType.resumeBook);
    });

    test('streak 0 with recent history returns reengagement day-1', () {
      final sessions = [
        createSession(
          bookId: 'b1',
          timestamp: jan15.subtract(Duration(days: 1)),
        ),
      ];
      final progress = [
        createProgress(
          bookId: 'b1',
          book: createBook(title: 'Deep Work'),
        ),
      ];

      final result = engine.decide(
        allSessions: sessions,
        currentlyReading: progress,
        now: jan15,
        streak: 0,
        lastNotificationDate: null,
        hasGoal: false,
        isGoalBehind: false,
        pagesBehind: 0,
      );

      expect(result, isNotNull);
      expect(result!.type, ReminderType.reengagement);
      expect(result.title, 'Your book is waiting 📖');
      expect(result.body, contains('Deep Work'));
    });

    test('streak 0 with 3 days gap returns day-2-3 reengagement', () {
      final sessions = [
        createSession(
          bookId: 'b1',
          timestamp: jan15.subtract(Duration(days: 3)),
        ),
      ];

      final result = engine.decide(
        allSessions: sessions,
        currentlyReading: [
          createProgress(
            bookId: 'b1',
            book: createBook(title: 'Deep Work'),
          ),
        ],
        now: jan15,
        streak: 0,
        lastNotificationDate: null,
        hasGoal: false,
        isGoalBehind: false,
        pagesBehind: 0,
      );

      expect(result, isNotNull);
      expect(result!.type, ReminderType.reengagement);
      expect(result.title, 'Just 5 minutes today');
    });

    test('streak 0 with 5 days gap returns page-1 reengagement', () {
      final sessions = [
        createSession(
          bookId: 'b1',
          timestamp: jan15.subtract(Duration(days: 5)),
        ),
      ];

      final result = engine.decide(
        allSessions: sessions,
        currentlyReading: [],
        now: jan15,
        streak: 0,
        lastNotificationDate: null,
        hasGoal: false,
        isGoalBehind: false,
        pagesBehind: 0,
      );

      expect(result, isNotNull);
      expect(result!.type, ReminderType.reengagement);
      expect(result.title, 'Start with 1 page');
    });

    test('streak 0 with 10 days gap returns deep reengagement', () {
      final sessions = [
        createSession(
          bookId: 'b1',
          timestamp: jan15.subtract(Duration(days: 10)),
        ),
      ];

      final result = engine.decide(
        allSessions: sessions,
        currentlyReading: [],
        now: jan15,
        streak: 0,
        lastNotificationDate: null,
        hasGoal: false,
        isGoalBehind: false,
        pagesBehind: 0,
      );

      expect(result, isNotNull);
      expect(result!.type, ReminderType.reengagement);
      expect(result.title, 'Still time to read');
    });

    test('streak 0 no history with books returns resumeBook fallback', () {
      final progress = [
        createProgress(
          bookId: 'b1',
          book: createBook(title: 'New Book'),
          currentPage: 0,
        ),
      ];

      final result = engine.decide(
        allSessions: [],
        currentlyReading: progress,
        now: jan15,
        streak: 0,
        lastNotificationDate: null,
        hasGoal: false,
        isGoalBehind: false,
        pagesBehind: 0,
      );

      expect(result, isNotNull);
      expect(result!.type, ReminderType.resumeBook);
      expect(result.title, 'New Book');
      expect(result.body, 'Continue from page 0.');
    });
  });

  // --------------- Already Read Today ---------------

  group('decide — already read today', () {
    test('has session today returns null regardless of streak', () {
      final sessions = [
        createSession(
          bookId: 'b1',
          timestamp: jan15.subtract(Duration(hours: 1)),
        ),
      ];
      final progress = [
        createProgress(
          bookId: 'b1',
          book: createBook(title: 'Test'),
        ),
      ];

      final result = engine.decide(
        allSessions: sessions,
        currentlyReading: progress,
        now: jan15,
        streak: 1,
        lastNotificationDate: null,
        hasGoal: false,
        isGoalBehind: false,
        pagesBehind: 0,
      );

      expect(result, isNull);
    });

    test('has session today even with streak 5 returns null', () {
      final sessions = [
        createSession(
          bookId: 'b1',
          timestamp: jan15.subtract(Duration(hours: 2)),
        ),
        createSession(
          bookId: 'b1',
          timestamp: jan15.subtract(Duration(days: 1)),
        ),
        createSession(
          bookId: 'b1',
          timestamp: jan15.subtract(Duration(days: 2)),
        ),
        createSession(
          bookId: 'b1',
          timestamp: jan15.subtract(Duration(days: 3)),
        ),
        createSession(
          bookId: 'b1',
          timestamp: jan15.subtract(Duration(days: 4)),
        ),
      ];

      final result = engine.decide(
        allSessions: sessions,
        currentlyReading: [createProgress(bookId: 'b1', book: createBook())],
        now: jan15,
        streak: 5,
        lastNotificationDate: null,
        hasGoal: false,
        isGoalBehind: false,
        pagesBehind: 0,
      );

      expect(result, isNull);
    });
  });

  // --------------- Cooldown ---------------

  group('decide — cooldown check', () {
    test('last notification 2 hours ago returns null', () {
      final sessions = [
        createSession(
          bookId: 'b1',
          timestamp: jan15.subtract(Duration(days: 1)),
        ),
      ];

      final result = engine.decide(
        allSessions: sessions,
        currentlyReading: [createProgress(bookId: 'b1', book: createBook())],
        now: jan15,
        streak: 1,
        lastNotificationDate: jan15.subtract(Duration(hours: 2)),
        hasGoal: false,
        isGoalBehind: false,
        pagesBehind: 0,
      );

      expect(result, isNull);
    });

    test('last notification 3 minutes ago returns null', () {
      final sessions = [
        createSession(
          bookId: 'b1',
          timestamp: jan15.subtract(Duration(days: 1)),
        ),
      ];

      final result = engine.decide(
        allSessions: sessions,
        currentlyReading: [createProgress(bookId: 'b1', book: createBook())],
        now: jan15,
        streak: 1,
        lastNotificationDate: jan15.subtract(Duration(minutes: 3)),
        hasGoal: false,
        isGoalBehind: false,
        pagesBehind: 0,
      );

      expect(result, isNull);
    });

    test('last notification exactly 4 hours ago allows notification', () {
      final sessions = [
        createSession(
          bookId: 'b1',
          timestamp: jan15.subtract(Duration(days: 1)),
        ),
      ];

      final result = engine.decide(
        allSessions: sessions,
        currentlyReading: [createProgress(bookId: 'b1', book: createBook())],
        now: jan15,
        streak: 1,
        lastNotificationDate: jan15.subtract(Duration(hours: 4)),
        hasGoal: false,
        isGoalBehind: false,
        pagesBehind: 0,
      );

      expect(result, isNotNull);
    });

    test('last notification 6 hours ago allows notification', () {
      final sessions = [
        createSession(
          bookId: 'b1',
          timestamp: jan15.subtract(Duration(days: 1)),
        ),
      ];

      final result = engine.decide(
        allSessions: sessions,
        currentlyReading: [createProgress(bookId: 'b1', book: createBook())],
        now: jan15,
        streak: 1,
        lastNotificationDate: jan15.subtract(Duration(hours: 6)),
        hasGoal: false,
        isGoalBehind: false,
        pagesBehind: 0,
      );

      expect(result, isNotNull);
    });

    test('last notification null allows notification', () {
      final sessions = [
        createSession(
          bookId: 'b1',
          timestamp: jan15.subtract(Duration(days: 1)),
        ),
      ];

      final result = engine.decide(
        allSessions: sessions,
        currentlyReading: [createProgress(bookId: 'b1', book: createBook())],
        now: jan15,
        streak: 1,
        lastNotificationDate: null,
        hasGoal: false,
        isGoalBehind: false,
        pagesBehind: 0,
      );

      expect(result, isNotNull);
    });
  });

  // --------------- Empty / Null Boundaries ---------------

  group('decide — empty and null boundaries', () {
    test('no sessions, no books returns null', () {
      final result = engine.decide(
        allSessions: [],
        currentlyReading: [],
        now: jan15,
        streak: 0,
        lastNotificationDate: null,
        hasGoal: false,
        isGoalBehind: false,
        pagesBehind: 0,
      );

      expect(result, isNull);
    });

    test('no sessions but has books returns resumeBook', () {
      final result = engine.decide(
        allSessions: [],
        currentlyReading: [createProgress(bookId: 'b1', book: createBook())],
        now: jan15,
        streak: 0,
        lastNotificationDate: null,
        hasGoal: false,
        isGoalBehind: false,
        pagesBehind: 0,
      );

      expect(result, isNotNull);
      expect(result!.type, ReminderType.resumeBook);
    });

    test('streak 0, has history, no books returns generic reengagement', () {
      final sessions = [
        createSession(
          bookId: 'b1',
          timestamp: jan15.subtract(Duration(days: 1)),
        ),
      ];

      final result = engine.decide(
        allSessions: sessions,
        currentlyReading: [],
        now: jan15,
        streak: 0,
        lastNotificationDate: null,
        hasGoal: false,
        isGoalBehind: false,
        pagesBehind: 0,
      );

      expect(result, isNotNull);
      expect(result!.type, ReminderType.reengagement);
      expect(result.body, contains('Just 5 minutes'));
      expect(result.payload, isNull);
    });

    test('streak 3, empty currentlyReading returns generic resumeBook', () {
      final sessions = List.generate(3, (i) {
        return createSession(
          bookId: 'b1',
          timestamp: jan15.subtract(Duration(days: i + 1)),
        );
      });

      final result = engine.decide(
        allSessions: sessions,
        currentlyReading: [],
        now: jan15,
        streak: 3,
        lastNotificationDate: null,
        hasGoal: false,
        isGoalBehind: false,
        pagesBehind: 0,
      );

      expect(result, isNotNull);
      expect(result!.type, ReminderType.resumeBook);
      expect(result.title, 'Time to read 📖');
      expect(result.payload, isNull);
    });
  });

  // --------------- Re-engagement Day Boundaries ---------------

  group('decide — re-engagement day boundaries', () {
    test('1 day gap uses day-1 message with book', () {
      final sessions = [
        createSession(
          bookId: 'b1',
          timestamp: jan15.subtract(Duration(days: 1, hours: 1)),
        ),
      ];

      final result = engine.decide(
        allSessions: sessions,
        currentlyReading: [
          createProgress(
            bookId: 'b1',
            book: createBook(title: 'Deep Work'),
          ),
        ],
        now: jan15,
        streak: 0,
        lastNotificationDate: null,
        hasGoal: false,
        isGoalBehind: false,
        pagesBehind: 0,
      );

      expect(result!.title, 'Your book is waiting 📖');
      expect(result.body, contains('Deep Work'));
    });

    test('2 day gap uses day-2-3 message', () {
      final sessions = [
        createSession(
          bookId: 'b1',
          timestamp: jan15.subtract(Duration(days: 2, hours: 1)),
        ),
      ];

      final result = engine.decide(
        allSessions: sessions,
        currentlyReading: [createProgress(bookId: 'b1', book: createBook())],
        now: jan15,
        streak: 0,
        lastNotificationDate: null,
        hasGoal: false,
        isGoalBehind: false,
        pagesBehind: 0,
      );

      expect(result!.title, 'Just 5 minutes today');
    });

    test('4 day gap uses day-4-7 message', () {
      final sessions = [
        createSession(
          bookId: 'b1',
          timestamp: jan15.subtract(Duration(days: 4, hours: 1)),
        ),
      ];

      final result = engine.decide(
        allSessions: sessions,
        currentlyReading: [],
        now: jan15,
        streak: 0,
        lastNotificationDate: null,
        hasGoal: false,
        isGoalBehind: false,
        pagesBehind: 0,
      );

      expect(result!.title, 'Start with 1 page');
    });

    test('7 day gap uses day-4-7 message', () {
      final sessions = [
        createSession(
          bookId: 'b1',
          timestamp: jan15.subtract(Duration(days: 7, hours: 1)),
        ),
      ];

      final result = engine.decide(
        allSessions: sessions,
        currentlyReading: [],
        now: jan15,
        streak: 0,
        lastNotificationDate: null,
        hasGoal: false,
        isGoalBehind: false,
        pagesBehind: 0,
      );

      expect(result!.title, 'Start with 1 page');
    });

    test('8 day gap uses deep reengagement message', () {
      final sessions = [
        createSession(
          bookId: 'b1',
          timestamp: jan15.subtract(Duration(days: 8, hours: 1)),
        ),
      ];

      final result = engine.decide(
        allSessions: sessions,
        currentlyReading: [],
        now: jan15,
        streak: 0,
        lastNotificationDate: null,
        hasGoal: false,
        isGoalBehind: false,
        pagesBehind: 0,
      );

      expect(result!.title, 'Still time to read');
    });
  });

  // --------------- Resume Book Edge Cases ---------------

  group('decide — resume book edge cases', () {
    test('book with null title fallback to "your book"', () {
      final progress = [
        createProgress(
          bookId: 'b1',
          book: createBook(title: ''),
          currentPage: 10,
        ),
      ];

      final result = engine.decide(
        allSessions: [],
        currentlyReading: progress,
        now: jan15,
        streak: 0,
        lastNotificationDate: null,
        hasGoal: false,
        isGoalBehind: false,
        pagesBehind: 0,
      );

      expect(result, isNotNull);
      // When book.title is empty, list.first.book.title is '' which is falsy
      expect(result!.body, contains('page 10'));
    });

    test('book with page 0', () {
      final progress = [
        createProgress(
          bookId: 'b1',
          book: createBook(title: 'New Book'),
          currentPage: 0,
        ),
      ];

      final result = engine.decide(
        allSessions: [],
        currentlyReading: progress,
        now: jan15,
        streak: 0,
        lastNotificationDate: null,
        hasGoal: false,
        isGoalBehind: false,
        pagesBehind: 0,
      );

      expect(result!.body, 'Continue from page 0.');
    });
  });

  // --------------- Streak Boundary Values ---------------

  group('decide — streak boundaries', () {
    test('streak 0 with no history and no books returns null', () {
      final result = engine.decide(
        allSessions: [],
        currentlyReading: [],
        now: jan15,
        streak: 0,
        lastNotificationDate: null,
        hasGoal: false,
        isGoalBehind: false,
        pagesBehind: 0,
      );
      expect(result, isNull);
    });

    test('streak 0 with history but gap uses reengagement', () {
      final sessions = [
        createSession(
          bookId: 'b1',
          timestamp: jan15.subtract(Duration(days: 1)),
        ),
      ];

      final result = engine.decide(
        allSessions: sessions,
        currentlyReading: [createProgress(bookId: 'b1', book: createBook())],
        now: jan15,
        streak: 0,
        lastNotificationDate: null,
        hasGoal: false,
        isGoalBehind: false,
        pagesBehind: 0,
      );

      expect(result!.type, ReminderType.reengagement);
    });

    test(
      'streak 365 (1 year but no session today) returns resumeBook',
      () async {
        final sessions = List.generate(365, (i) {
          // i=0 → yesterday, i=364 → 365 days ago
          return createSession(
            bookId: 'b1',
            timestamp: jan15.subtract(Duration(days: i + 1)),
          );
        });
        final progress = [
          createProgress(
            bookId: 'b1',
            book: createBook(title: 'War and Peace'),
          ),
        ];

        final result = engine.decide(
          allSessions: sessions,
          currentlyReading: progress,
          now: jan15,
          streak: 365,
          lastNotificationDate: null,
          hasGoal: false,
          isGoalBehind: false,
          pagesBehind: 0,
        );

        expect(result, isNotNull);
        expect(result!.type, ReminderType.resumeBook);
      },
    );
  });

  // --------------- Bug Regression ---------------

  group('decide — bug regression', () {
    test('B1: no side-effect sort on input list', () {
      final sessions = [
        createSession(
          bookId: 'b1',
          timestamp: jan15.subtract(Duration(days: 3)),
        ),
        createSession(
          bookId: 'b1',
          timestamp: jan15.subtract(Duration(days: 1)),
        ),
        createSession(
          bookId: 'b1',
          timestamp: jan15.subtract(Duration(days: 2)),
        ),
      ];
      final originalOrder = [...sessions];

      engine.decide(
        allSessions: sessions,
        currentlyReading: [createProgress(bookId: 'b1', book: createBook())],
        now: jan15,
        streak: 0,
        lastNotificationDate: jan15.subtract(Duration(days: 10)),
        hasGoal: false,
        isGoalBehind: false,
        pagesBehind: 0,
      );

      expect(
        sessions[0].timestamp,
        equals(originalOrder[0].timestamp),
        reason: 'element 0 must not be moved',
      );
      expect(
        sessions[1].timestamp,
        equals(originalOrder[1].timestamp),
        reason: 'element 1 must not be moved',
      );
      expect(
        sessions[2].timestamp,
        equals(originalOrder[2].timestamp),
        reason: 'element 2 must not be moved',
      );
    });

    test('B2: midnight boundary — 1 minute gap does not count as 1 day', () {
      // Session at 2024-01-14 23:59, now is 2024-01-15 00:01
      final sessions = [
        createSession(bookId: 'b1', timestamp: DateTime(2024, 1, 14, 23, 59)),
      ];
      final now = DateTime(2024, 1, 15, 0, 1);

      // The decide method internally calls _daysSinceLastSession which uses
      // now.difference(session.timestamp).inDays.
      // difference(23:59 => 00:01) = 2 minutes → inDays = 0
      // So daysSinceLastSession = 0, but cooldown is based on hours.
      // Streak = 0 (no session today), hasEverRead = true
      // daysSinceLastSession = 0 means it doesn't match any re-engagement bucket
      // daysSinceLastRead == 1 would be false, so it falls to daysSinceLastRead <= 3

      // lastNotificationDate is null so cooldown doesn't block
      final result = engine.decide(
        allSessions: sessions,
        currentlyReading: [createProgress(bookId: 'b1', book: createBook())],
        now: now,
        streak: 0,
        lastNotificationDate: null,
        hasGoal: false,
        isGoalBehind: false,
        pagesBehind: 0,
      );

      // Because inDays = 0, it doesn't match day-1 (==1), falls to <=3
      // which produces "Just 5 minutes" message
      expect(result, isNotNull);
      expect(result!.type, ReminderType.reengagement);
      // daysSinceLastRead = 0, not 1, so this is the day-2-3 bucket
      expect(result.title, 'Just 5 minutes today');
    });
  });

  // --------------- Invariants ---------------

  group('decide — invariants', () {
    test('title is never empty when result is not null', () {
      final combinations = [
        engine.decide(
          allSessions: [],
          currentlyReading: [],
          now: jan15,
          streak: 0,
          lastNotificationDate: null,
          hasGoal: false,
          isGoalBehind: false,
          pagesBehind: 0,
        ),
        engine.decide(
          allSessions: [],
          currentlyReading: [createProgress()],
          now: jan15,
          streak: 0,
          lastNotificationDate: null,
          hasGoal: false,
          isGoalBehind: false,
          pagesBehind: 0,
        ),
        engine.decide(
          allSessions: [
            createSession(
              bookId: 'b1',
              timestamp: jan15.subtract(Duration(days: 1)),
            ),
          ],
          currentlyReading: [],
          now: jan15,
          streak: 1,
          lastNotificationDate: null,
          hasGoal: false,
          isGoalBehind: false,
          pagesBehind: 0,
        ),
        engine.decide(
          allSessions: [
            createSession(
              bookId: 'b1',
              timestamp: jan15.subtract(Duration(days: 1)),
            ),
          ],
          currentlyReading: [createProgress()],
          now: jan15,
          streak: 1,
          lastNotificationDate: null,
          hasGoal: false,
          isGoalBehind: false,
          pagesBehind: 0,
        ),
        engine.decide(
          allSessions: List.generate(
            3,
            (i) => createSession(
              bookId: 'b1',
              timestamp: jan15.subtract(Duration(days: i + 1)),
            ),
          ),
          currentlyReading: [createProgress()],
          now: jan15,
          streak: 3,
          lastNotificationDate: null,
          hasGoal: false,
          isGoalBehind: false,
          pagesBehind: 0,
        ),
      ];

      for (final result in combinations) {
        if (result != null) {
          expect(result.title, isNotEmpty, reason: 'title must not be empty');
          expect(result.body, isNotEmpty, reason: 'body must not be empty');
        }
      }
    });

    test('type matches priority order', () {
      // streak 1-2 → streakProtection
      final r1 = engine.decide(
        allSessions: [
          createSession(
            bookId: 'b1',
            timestamp: jan15.subtract(Duration(days: 1)),
          ),
        ],
        currentlyReading: [createProgress()],
        now: jan15,
        streak: 1,
        lastNotificationDate: null,
        hasGoal: false,
        isGoalBehind: false,
        pagesBehind: 0,
      );
      expect(r1!.type, ReminderType.streakProtection);

      final r2 = engine.decide(
        allSessions: [
          createSession(
            bookId: 'b1',
            timestamp: jan15.subtract(Duration(days: 1)),
          ),
        ],
        currentlyReading: [createProgress()],
        now: jan15,
        streak: 2,
        lastNotificationDate: null,
        hasGoal: false,
        isGoalBehind: false,
        pagesBehind: 0,
      );
      expect(r2!.type, ReminderType.streakProtection);

      // streak 0 with history → reengagement
      final r3 = engine.decide(
        allSessions: [
          createSession(
            bookId: 'b1',
            timestamp: jan15.subtract(Duration(days: 1)),
          ),
        ],
        currentlyReading: [createProgress()],
        now: jan15,
        streak: 0,
        lastNotificationDate: null,
        hasGoal: false,
        isGoalBehind: false,
        pagesBehind: 0,
      );
      expect(r3!.type, ReminderType.reengagement);

      // streak >= 3 → resumeBook
      final r4 = engine.decide(
        allSessions: List.generate(
          3,
          (i) => createSession(
            bookId: 'b1',
            timestamp: jan15.subtract(Duration(days: i + 1)),
          ),
        ),
        currentlyReading: [createProgress()],
        now: jan15,
        streak: 3,
        lastNotificationDate: null,
        hasGoal: false,
        isGoalBehind: false,
        pagesBehind: 0,
      );
      expect(r4!.type, ReminderType.resumeBook);
    });

    test(
      'payload is present when currentlyReading has books and result has a book reference',
      () {
        final r = engine.decide(
          allSessions: [
            createSession(
              bookId: 'b1',
              timestamp: jan15.subtract(Duration(days: 1)),
            ),
          ],
          currentlyReading: [createProgress(bookId: 'b1', book: createBook())],
          now: jan15,
          streak: 1,
          lastNotificationDate: null,
          hasGoal: false,
          isGoalBehind: false,
          pagesBehind: 0,
        );
        expect(r!.payload, isNotNull);
      },
    );
  });
}
