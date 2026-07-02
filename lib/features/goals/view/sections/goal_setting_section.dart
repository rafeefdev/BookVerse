import 'package:book_verse/core/theme/themes_extension.dart';
import 'package:book_verse/features/goals/model/goal_progress.dart';
import 'package:book_verse/features/goals/model/reading_goal.dart';
import 'package:book_verse/features/goals/providers/goal_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GoalSettingSection extends ConsumerWidget {
  const GoalSettingSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalAsync = ref.watch(dailyGoalProvider);
    final progressAsync = ref.watch(goalProgressProvider);
    final cs = context.colorScheme;
    final textTheme = context.textTheme;

    return goalAsync.when(
      data: (goal) =>
          _buildContent(context, ref, goal, progressAsync, cs, textTheme),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    DailyGoal goal,
    AsyncValue<GoalProgress?> progressAsync,
    ColorScheme cs,
    TextTheme textTheme,
  ) {
    final pagesCtrl = TextEditingController(text: goal.targetPages.toString());
    final minutesCtrl = TextEditingController(
      text: goal.targetMinutes.toString(),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Row(
            children: [
              Icon(Icons.flag_outlined, size: 20, color: cs.onSurfaceVariant),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reading Goal',
                      style: textTheme.titleSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Set your daily reading targets',
                      style: textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Daily Reading Target', style: textTheme.titleMedium),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: pagesCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Pages per day',
                      border: OutlineInputBorder(),
                      suffixText: 'pages',
                    ),
                    onChanged: (v) {
                      final pages = int.tryParse(v);
                      if (pages != null && pages > 0) {
                        ref
                            .read(dailyGoalProvider.notifier)
                            .updateTargetPages(pages);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: minutesCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Minutes per day',
                      border: OutlineInputBorder(),
                      suffixText: 'min',
                    ),
                    onChanged: (v) {
                      final minutes = int.tryParse(v);
                      if (minutes != null && minutes > 0) {
                        ref
                            .read(dailyGoalProvider.notifier)
                            .updateTargetMinutes(minutes);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Enable Daily Goal'),
                    subtitle: Text(
                      'Read ${goal.targetPages} pages or ${goal.targetMinutes} minutes each day',
                      style: textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    value: goal.enabled,
                    onChanged: (_) {
                      ref.read(dailyGoalProvider.notifier).toggleEnabled();
                    },
                  ),
                  if (goal.enabled)
                    progressAsync.when(
                      data: (progress) {
                        if (progress == null) return const SizedBox.shrink();
                        return _buildProgressPreview(progress, cs, textTheme);
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                ],
              ),
            ),
          ),
        ),
        const Divider(),
      ],
    );
  }

  Widget _buildProgressPreview(
    GoalProgress progress,
    ColorScheme cs,
    TextTheme textTheme,
  ) {
    final statusColor = switch (progress.status) {
      GoalStatus.ahead => Colors.green,
      GoalStatus.onTrack => Colors.green,
      GoalStatus.behind => cs.error,
      GoalStatus.noGoal => cs.onSurfaceVariant,
    };
    final statusText = switch (progress.status) {
      GoalStatus.ahead => 'Goal complete!',
      GoalStatus.onTrack => 'On track',
      GoalStatus.behind => 'Behind by ${progress.pagesRemaining} pages',
      GoalStatus.noGoal => '',
    };

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Today's Progress", style: textTheme.titleSmall),
          const SizedBox(height: 12),
          _progressRow(
            Icons.menu_book,
            'Pages',
            progress.pagesRead,
            progress.targetPages,
            progress.pagesProgress,
            cs,
            textTheme,
          ),
          const SizedBox(height: 8),
          _progressRow(
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
            children: [
              Icon(
                statusText.isNotEmpty ? Icons.circle : null,
                size: 10,
                color: statusColor,
              ),
              if (statusText.isNotEmpty) ...[
                const SizedBox(width: 6),
                Text(
                  statusText,
                  style: textTheme.bodySmall?.copyWith(color: statusColor),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _progressRow(
    IconData icon,
    String label,
    int current,
    int target,
    double progress,
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
              '${(progress * 100).toStringAsFixed(0)}%',
              style: textTheme.labelSmall,
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: cs.surfaceContainerHighest,
          ),
        ),
      ],
    );
  }
}
