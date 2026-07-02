import 'package:book_verse/core/utils/clock.dart';
import 'package:book_verse/features/goals/data/goals_datasource.dart';
import 'package:book_verse/features/goals/model/goal_progress.dart';
import 'package:book_verse/features/goals/model/reading_goal.dart';
import 'package:book_verse/features/reading_tracker/data/reading_tracker_datasource.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dailyGoalProvider =
    StateNotifierProvider<DailyGoalNotifier, AsyncValue<DailyGoal>>((ref) {
      return DailyGoalNotifier(ref);
    });

class DailyGoalNotifier extends StateNotifier<AsyncValue<DailyGoal>> {
  final Ref _ref;

  DailyGoalNotifier(this._ref) : super(const AsyncLoading()) {
    _load();
  }

  Future<void> _load() async {
    final datasource = _ref.read(goalsDatasourceProvider);
    final goal = await datasource.getGoal();
    state = AsyncData(goal ?? DailyGoal.defaults());
  }

  Future<void> saveGoal(DailyGoal goal) async {
    final datasource = _ref.read(goalsDatasourceProvider);
    await datasource.saveGoal(goal);
    state = AsyncData(goal);
  }

  Future<void> updateTargetPages(int pages) async {
    final current = state.valueOrNull ?? DailyGoal.defaults();
    await saveGoal(current.copyWith(targetPages: pages));
  }

  Future<void> updateTargetMinutes(int minutes) async {
    final current = state.valueOrNull ?? DailyGoal.defaults();
    await saveGoal(current.copyWith(targetMinutes: minutes));
  }

  Future<void> toggleEnabled() async {
    final current = state.valueOrNull ?? DailyGoal.defaults();
    await saveGoal(current.copyWith(enabled: !current.enabled));
  }
}

final goalProgressProvider = FutureProvider<GoalProgress?>((ref) async {
  final goalAsync = ref.watch(dailyGoalProvider);
  final goal = goalAsync.valueOrNull;
  if (goal == null || !goal.enabled) return null;

  final datasource = ref.watch(readingTrackerDatasourceProvider);
  final clock = ref.watch(clockProvider);
  final now = clock.now();
  final todayStart = DateTime(now.year, now.month, now.day);

  final sessions = await datasource.getAllReadingSessions();
  final todaySessions = sessions.where(
    (s) => !s.timestamp.isBefore(todayStart),
  );

  int pagesRead = 0;
  int minutesRead = 0;
  for (final s in todaySessions) {
    minutesRead += (s.durationInSeconds / 60).ceil();
    if (s.startPage != null && s.endPage > s.startPage!) {
      pagesRead += s.endPage - s.startPage!;
    }
  }

  return GoalProgress(
    pagesRead: pagesRead,
    minutesRead: minutesRead,
    targetPages: goal.targetPages,
    targetMinutes: goal.targetMinutes,
  );
});
