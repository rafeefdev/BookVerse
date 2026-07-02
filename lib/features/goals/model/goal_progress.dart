enum GoalStatus { ahead, onTrack, behind, noGoal }

class GoalProgress {
  final int pagesRead;
  final int minutesRead;
  final int targetPages;
  final int targetMinutes;

  const GoalProgress({
    required this.pagesRead,
    required this.minutesRead,
    required this.targetPages,
    required this.targetMinutes,
  });

  double get pagesProgress =>
      targetPages > 0 ? (pagesRead / targetPages).clamp(0.0, 1.0) : 0.0;

  double get minutesProgress =>
      targetMinutes > 0 ? (minutesRead / targetMinutes).clamp(0.0, 1.0) : 0.0;

  bool get isComplete =>
      pagesRead >= targetPages && minutesRead >= targetMinutes;

  GoalStatus get status {
    if (targetPages == 0 && targetMinutes == 0) return GoalStatus.noGoal;
    if (isComplete) return GoalStatus.ahead;
    if (pagesProgress >= 0.8 && minutesProgress >= 0.8) {
      return GoalStatus.onTrack;
    }
    return GoalStatus.behind;
  }

  int get pagesRemaining => (targetPages - pagesRead).clamp(0, targetPages);
  int get minutesRemaining =>
      (targetMinutes - minutesRead).clamp(0, targetMinutes);
}
