import 'package:book_verse/core/theme/themes_extension.dart';
import 'package:book_verse/features/goals/model/goal_progress.dart';
import 'package:flutter/material.dart';

class GoalProgressCard extends StatelessWidget {
  final GoalProgress progress;
  final VoidCallback? onTap;

  const GoalProgressCard({super.key, required this.progress, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    final textTheme = context.textTheme;

    final statusColor = switch (progress.status) {
      GoalStatus.ahead => Colors.green,
      GoalStatus.onTrack => Colors.green,
      GoalStatus.behind => cs.error,
      GoalStatus.noGoal => cs.onSurfaceVariant,
    };
    final statusIcon = switch (progress.status) {
      GoalStatus.ahead => Icons.check_circle,
      GoalStatus.onTrack => Icons.check_circle_outline,
      GoalStatus.behind => Icons.warning_amber_rounded,
      GoalStatus.noGoal => Icons.remove_circle_outline,
    };
    final statusLabel = switch (progress.status) {
      GoalStatus.ahead => 'Goal complete!',
      GoalStatus.onTrack => 'On track',
      GoalStatus.behind => 'Behind by ${progress.pagesRemaining} pages',
      GoalStatus.noGoal => '',
    };

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text("Today's Goal", style: textTheme.titleMedium),
                  const Spacer(),
                  Icon(statusIcon, color: statusColor, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    statusLabel,
                    style: textTheme.labelSmall?.copyWith(color: statusColor),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _miniRow(
                Icons.menu_book,
                'Pages',
                progress.pagesRead,
                progress.targetPages,
                progress.pagesProgress,
                cs,
                textTheme,
              ),
              const SizedBox(height: 8),
              _miniRow(
                Icons.timer_outlined,
                'Minutes',
                progress.minutesRead,
                progress.targetMinutes,
                progress.minutesProgress,
                cs,
                textTheme,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Tap to adjust goal  ›',
                    style: textTheme.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniRow(
    IconData icon,
    String label,
    int current,
    int target,
    double pct,
    ColorScheme cs,
    TextTheme textTheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: cs.onSurfaceVariant),
                const SizedBox(width: 6),
                Text('$label: $current / $target', style: textTheme.bodySmall),
              ],
            ),
            Text(
              '${(pct * 100).toStringAsFixed(0)}%',
              style: textTheme.labelSmall,
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 8,
            backgroundColor: cs.surfaceContainerHighest,
          ),
        ),
      ],
    );
  }
}
