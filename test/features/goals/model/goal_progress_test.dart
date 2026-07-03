import 'package:book_verse/features/goals/model/goal_progress.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GoalProgress', () {
    group('pagesProgress', () {
      test('returns 0 when targetPages is 0', () {
        final progress = GoalProgress(
          pagesRead: 10,
          minutesRead: 5,
          targetPages: 0,
          targetMinutes: 20,
        );
        expect(progress.pagesProgress, 0.0);
      });

      test('calculates fraction when pagesRead < targetPages', () {
        final progress = GoalProgress(
          pagesRead: 15,
          minutesRead: 10,
          targetPages: 30,
          targetMinutes: 20,
        );
        expect(progress.pagesProgress, closeTo(0.5, 0.001));
      });

      test('returns 1.0 when pagesRead equals targetPages', () {
        final progress = GoalProgress(
          pagesRead: 30,
          minutesRead: 10,
          targetPages: 30,
          targetMinutes: 20,
        );
        expect(progress.pagesProgress, 1.0);
      });

      test('clamps to 1.0 when pagesRead exceeds targetPages', () {
        final progress = GoalProgress(
          pagesRead: 50,
          minutesRead: 10,
          targetPages: 30,
          targetMinutes: 20,
        );
        expect(progress.pagesProgress, 1.0);
      });
    });

    group('minutesProgress', () {
      test('returns 0 when targetMinutes is 0', () {
        final progress = GoalProgress(
          pagesRead: 10,
          minutesRead: 5,
          targetPages: 30,
          targetMinutes: 0,
        );
        expect(progress.minutesProgress, 0.0);
      });

      test('calculates fraction when minutesRead < targetMinutes', () {
        final progress = GoalProgress(
          pagesRead: 10,
          minutesRead: 5,
          targetPages: 30,
          targetMinutes: 20,
        );
        expect(progress.minutesProgress, closeTo(0.25, 0.001));
      });

      test('returns 1.0 when minutesRead equals targetMinutes', () {
        final progress = GoalProgress(
          pagesRead: 10,
          minutesRead: 20,
          targetPages: 30,
          targetMinutes: 20,
        );
        expect(progress.minutesProgress, 1.0);
      });

      test('clamps to 1.0 when minutesRead exceeds targetMinutes', () {
        final progress = GoalProgress(
          pagesRead: 10,
          minutesRead: 40,
          targetPages: 30,
          targetMinutes: 20,
        );
        expect(progress.minutesProgress, 1.0);
      });
    });

    group('isComplete', () {
      test('returns false when both are below target', () {
        final progress = GoalProgress(
          pagesRead: 10,
          minutesRead: 5,
          targetPages: 30,
          targetMinutes: 20,
        );
        expect(progress.isComplete, false);
      });

      test('returns false when only pages meet target', () {
        final progress = GoalProgress(
          pagesRead: 30,
          minutesRead: 5,
          targetPages: 30,
          targetMinutes: 20,
        );
        expect(progress.isComplete, false);
      });

      test('returns false when only minutes meet target', () {
        final progress = GoalProgress(
          pagesRead: 10,
          minutesRead: 20,
          targetPages: 30,
          targetMinutes: 20,
        );
        expect(progress.isComplete, false);
      });

      test('returns true when both meet target', () {
        final progress = GoalProgress(
          pagesRead: 30,
          minutesRead: 20,
          targetPages: 30,
          targetMinutes: 20,
        );
        expect(progress.isComplete, true);
      });

      test('returns true when both exceed target', () {
        final progress = GoalProgress(
          pagesRead: 50,
          minutesRead: 30,
          targetPages: 30,
          targetMinutes: 20,
        );
        expect(progress.isComplete, true);
      });
    });

    group('status', () {
      test('returns noGoal when targetPages and targetMinutes are 0', () {
        final progress = GoalProgress(
          pagesRead: 10,
          minutesRead: 5,
          targetPages: 0,
          targetMinutes: 0,
        );
        expect(progress.status, GoalStatus.noGoal);
      });

      test('returns ahead when isComplete', () {
        final progress = GoalProgress(
          pagesRead: 30,
          minutesRead: 20,
          targetPages: 30,
          targetMinutes: 20,
        );
        expect(progress.status, GoalStatus.ahead);
      });

      test('returns onTrack when both progresses >= 0.8', () {
        final progress = GoalProgress(
          pagesRead: 24,
          minutesRead: 16,
          targetPages: 30,
          targetMinutes: 20,
        );
        expect(progress.status, GoalStatus.onTrack);
      });

      test('returns behind when pages progress < 0.8', () {
        final progress = GoalProgress(
          pagesRead: 15,
          minutesRead: 16,
          targetPages: 30,
          targetMinutes: 20,
        );
        expect(progress.status, GoalStatus.behind);
      });

      test('returns behind when minutes progress < 0.8', () {
        final progress = GoalProgress(
          pagesRead: 24,
          minutesRead: 10,
          targetPages: 30,
          targetMinutes: 20,
        );
        expect(progress.status, GoalStatus.behind);
      });

      test('returns behind when both progresses < 0.8', () {
        final progress = GoalProgress(
          pagesRead: 10,
          minutesRead: 5,
          targetPages: 30,
          targetMinutes: 20,
        );
        expect(progress.status, GoalStatus.behind);
      });

      test('edge: exactly at 0.8 boundary returns onTrack', () {
        final progress = GoalProgress(
          pagesRead: 24,
          minutesRead: 16,
          targetPages: 30,
          targetMinutes: 20,
        );
        expect(progress.status, GoalStatus.onTrack);
      });

      test('edge: just below 0.8 returns behind', () {
        final progress = GoalProgress(
          pagesRead: 23,
          minutesRead: 15,
          targetPages: 30,
          targetMinutes: 20,
        );
        expect(progress.status, GoalStatus.behind);
      });
    });

    group('pagesRemaining', () {
      test('returns diff when pagesRead < targetPages', () {
        final progress = GoalProgress(
          pagesRead: 10,
          minutesRead: 5,
          targetPages: 30,
          targetMinutes: 20,
        );
        expect(progress.pagesRemaining, 20);
      });

      test('returns 0 when pagesRead equals targetPages', () {
        final progress = GoalProgress(
          pagesRead: 30,
          minutesRead: 5,
          targetPages: 30,
          targetMinutes: 20,
        );
        expect(progress.pagesRemaining, 0);
      });

      test('returns 0 when pagesRead exceeds targetPages', () {
        final progress = GoalProgress(
          pagesRead: 50,
          minutesRead: 5,
          targetPages: 30,
          targetMinutes: 20,
        );
        expect(progress.pagesRemaining, 0);
      });

      test('clamps to targetPages when pagesRead is 0', () {
        final progress = GoalProgress(
          pagesRead: 0,
          minutesRead: 0,
          targetPages: 30,
          targetMinutes: 20,
        );
        expect(progress.pagesRemaining, 30);
      });

      test('rounds down fractional remaining', () {
        final progress = GoalProgress(
          pagesRead: 29,
          minutesRead: 0,
          targetPages: 30,
          targetMinutes: 20,
        );
        expect(progress.pagesRemaining, 1);
      });
    });

    group('minutesRemaining', () {
      test('returns diff when minutesRead < targetMinutes', () {
        final progress = GoalProgress(
          pagesRead: 10,
          minutesRead: 5,
          targetPages: 30,
          targetMinutes: 20,
        );
        expect(progress.minutesRemaining, 15);
      });

      test('returns 0 when minutesRead equals targetMinutes', () {
        final progress = GoalProgress(
          pagesRead: 10,
          minutesRead: 20,
          targetPages: 30,
          targetMinutes: 20,
        );
        expect(progress.minutesRemaining, 0);
      });

      test('returns 0 when minutesRead exceeds targetMinutes', () {
        final progress = GoalProgress(
          pagesRead: 10,
          minutesRead: 40,
          targetPages: 30,
          targetMinutes: 20,
        );
        expect(progress.minutesRemaining, 0);
      });
    });
  });
}
