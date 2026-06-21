import 'package:book_verse/features/notifications/model/reminder_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReminderType', () {
    test('has three values', () {
      expect(ReminderType.values, hasLength(4));
      expect(ReminderType.values, containsAll([
        ReminderType.resumeBook,
        ReminderType.streakProtection,
        ReminderType.reengagement,
        ReminderType.goalReminder,
      ]));
    });
  });

  group('ReminderDecision', () {
    test('equality: same fields are equal', () {
      final a = ReminderDecision(
        type: ReminderType.resumeBook,
        title: 'Atomic Habits',
        body: 'Continue from page 147.',
        payload: 'book-1',
      );
      final b = ReminderDecision(
        type: ReminderType.resumeBook,
        title: 'Atomic Habits',
        body: 'Continue from page 147.',
        payload: 'book-1',
      );
      expect(a, equals(b));
    });

    test('equality: different type is not equal', () {
      final a = ReminderDecision(
        type: ReminderType.resumeBook,
        title: 'Atomic Habits',
        body: 'Continue from page 147.',
      );
      final b = ReminderDecision(
        type: ReminderType.streakProtection,
        title: 'Atomic Habits',
        body: 'Continue from page 147.',
      );
      expect(a, isNot(equals(b)));
    });

    test('equality: different title is not equal', () {
      final a = ReminderDecision(
        type: ReminderType.resumeBook,
        title: 'Book A',
        body: 'Continue.',
      );
      final b = ReminderDecision(
        type: ReminderType.resumeBook,
        title: 'Book B',
        body: 'Continue.',
      );
      expect(a, isNot(equals(b)));
    });

    test('equality: different body is not equal', () {
      final a = ReminderDecision(
        type: ReminderType.resumeBook,
        title: 'Test',
        body: 'Body A',
      );
      final b = ReminderDecision(
        type: ReminderType.resumeBook,
        title: 'Test',
        body: 'Body B',
      );
      expect(a, isNot(equals(b)));
    });

    test('payload can be null', () {
      final decision = ReminderDecision(
        type: ReminderType.resumeBook,
        title: 'Test',
        body: 'Test body.',
      );
      expect(decision.payload, isNull);
    });

    test('payload can be non-null', () {
      final decision = ReminderDecision(
        type: ReminderType.resumeBook,
        title: 'Test',
        body: 'Test body.',
        payload: 'book-123',
      );
      expect(decision.payload, equals('book-123'));
    });

    test('all fields are accessible', () {
      final decision = ReminderDecision(
        type: ReminderType.streakProtection,
        title: '🔥 3-day streak',
        body: 'Read 5 more minutes.',
        payload: 'book-1',
      );
      expect(decision.type, ReminderType.streakProtection);
      expect(decision.title, '🔥 3-day streak');
      expect(decision.body, 'Read 5 more minutes.');
      expect(decision.payload, 'book-1');
    });
  });
}
