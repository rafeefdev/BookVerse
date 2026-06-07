import 'package:book_verse/features/insights/model/insights_state.dart';
import 'package:flutter/material.dart';

class NarrativeHeaderSection extends StatelessWidget {
  final InsightsState state;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  const NarrativeHeaderSection(
    this.state,
    this.textTheme,
    this.colorScheme, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    String headline;
    IconData icon;
    Color iconColor;

    if (state.streakStatus == StreakStatus.active) {
      headline =
          ' ${state.currentStreak}-day streak! Keep reading to maintain it.';
      icon = Icons.local_fire_department;
      iconColor = colorScheme.error;
    } else if (state.streakStatus == StreakStatus.atRisk) {
      headline = state.currentStreak == 1
          ? 'Read today to build your streak!'
          : '${state.currentStreak}-day streak — read today to keep it going!';
      icon = Icons.timer_outlined;
      iconColor = colorScheme.tertiary;
    } else if (state.streakStatus == StreakStatus.broken) {
      headline = state.totalMinutes > 0
          ? 'Start a new streak today!'
          : 'Start reading to track your progress!';
      icon = Icons.auto_stories;
      iconColor = colorScheme.primary;
    } else {
      headline = 'Start reading to see your insights!';
      icon = Icons.auto_stories;
      iconColor = colorScheme.primary;
    }

    return Card(
      color: colorScheme.primaryContainer.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                headline,
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
