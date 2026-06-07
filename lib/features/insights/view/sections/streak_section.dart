import 'package:book_verse/core/utils/page_utils.dart';
import 'package:book_verse/features/insights/model/insights_state.dart';
import 'package:flutter/material.dart';

class StreakSection extends StatelessWidget {
  final InsightsState state;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  const StreakSection(this.state, this.textTheme, this.colorScheme, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _streakStatusIndicator(state, textTheme, colorScheme),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        color: colorScheme.error,
                        size: 32,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${state.currentStreak}',
                        style: textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'current',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    children: [
                      Icon(
                        Icons.trending_up,
                        color: colorScheme.primary,
                        size: 32,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${state.longestStreak}',
                        style: textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'longest',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildHeatmap(context, state, textTheme, colorScheme),
            _buildStreakCta(state, textTheme, colorScheme),
          ],
        ),
      ),
    );
  }
}

Widget _streakStatusIndicator(
  InsightsState state,
  TextTheme textTheme,
  ColorScheme colorScheme,
) {
  String label;
  Color color;
  IconData icon;

  switch (state.streakStatus) {
    case StreakStatus.active:
      label = 'Active';
      color = Colors.green;
      icon = Icons.check_circle;
    case StreakStatus.atRisk:
      label = 'At Risk';
      color = Colors.orange;
      icon = Icons.warning_amber_rounded;
    case StreakStatus.broken:
      label = 'Broken';
      color = colorScheme.error;
      icon = Icons.cancel_outlined;
    case StreakStatus.none:
      label = 'No Activity';
      color = colorScheme.onSurfaceVariant;
      icon = Icons.remove_circle_outline;
  }

  return Row(
    children: [
      Text('Streak', style: textTheme.titleMedium),
      const Spacer(),
      Icon(icon, color: color, size: 16),
      const SizedBox(width: 4),
      Text(
        label,
        style: textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}

Widget _buildStreakCta(
  InsightsState state,
  TextTheme textTheme,
  ColorScheme colorScheme,
) {
  if (state.streakStatus == StreakStatus.none) return const SizedBox.shrink();

  String cta;
  if (state.streakStatus == StreakStatus.active ||
      state.streakStatus == StreakStatus.atRisk) {
    cta = 'Read today to keep your streak alive!';
  } else {
    cta = 'Start reading to begin a new streak!';
  }

  return Padding(
    padding: const EdgeInsets.only(top: 12),
    child: Text(
      cta,
      style: textTheme.bodySmall?.copyWith(
        color: colorScheme.onSurfaceVariant,
        fontStyle: FontStyle.italic,
      ),
    ),
  );
}

Widget _buildHeatmap(
  BuildContext context,
  InsightsState state,
  TextTheme textTheme,
  ColorScheme colorScheme,
) {
  const gap = 2.0;

  final weeks = <List<StreakDay>>[];
  for (var i = 0; i < state.streakHistory.length; i += 7) {
    weeks.add(
      state.streakHistory.sublist(
        i,
        (i + 7).clamp(0, state.streakHistory.length),
      ),
    );
  }

  final activeCount =
      state.streakHistory.where((d) => d.hasActivity).length;
  final bestWeek = weeks.fold<int>(
    0,
    (max, w) {
      final count = w.where((d) => d.hasActivity).length;
      return count > max ? count : max;
    },
  );

  return LayoutBuilder(
    builder: (_, constraints) {
      final cellSize = ((constraints.maxWidth - (weeks.length - 1) * gap) /
              weeks.length)
          .floorToDouble();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Last 90 days',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Text(
                'Best week: $bestWeek active days',
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildMonthLabels(weeks, textTheme, colorScheme, cellSize, gap),
          const SizedBox(height: 4),
          SizedBox(
            height: 7 * cellSize + 6 * gap,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int w = 0; w < weeks.length; w++) ...[
                  if (w > 0) SizedBox(width: gap),
                  SizedBox(
                    width: cellSize,
                    child: Column(
                      children: [
                        for (int d = 0; d < weeks[w].length; d++) ...[
                          if (d > 0) SizedBox(height: gap),
                          GestureDetector(
                            onTap: () =>
                                _showDayDetail(weeks[w][d], context, textTheme, colorScheme),
                            child: Container(
                              width: cellSize,
                              height: cellSize,
                              decoration: BoxDecoration(
                                color: _heatmapColor(
                                  weeks[w][d].durationSeconds,
                                  colorScheme,
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          _buildLegend(colorScheme),
          const SizedBox(height: 8),
          Text(
            '$activeCount active days in the last 90 days',
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );
    },
  );
}

Color _heatmapColor(int durationSeconds, ColorScheme colorScheme) {
  final minutes = durationSeconds / 60;
  if (minutes == 0) return colorScheme.surfaceContainerHighest;
  if (minutes <= 15) return colorScheme.primary.withValues(alpha: 0.20);
  if (minutes <= 30) return colorScheme.primary.withValues(alpha: 0.40);
  if (minutes <= 60) return colorScheme.primary.withValues(alpha: 0.60);
  return colorScheme.primary;
}

Widget _buildMonthLabels(
  List<List<StreakDay>> weeks,
  TextTheme textTheme,
  ColorScheme colorScheme,
  double cellSize,
  double gap,
) {
  final spans = <_MonthSpan>[];
  for (int i = 0; i < weeks.length; i++) {
    final month = weeks[i].first.date.month;
    if (spans.isNotEmpty && spans.last.month == month) {
      spans.last.count++;
    } else {
      spans.add(_MonthSpan(month, 1));
    }
  }

  return Row(
    children: spans.map((span) {
      return SizedBox(
        width: span.count * cellSize + (span.count - 1) * gap,
        child: Text(
          monthLabel(span.month),
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontSize: 10,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }).toList(),
  );
}

Widget _buildLegend(ColorScheme colorScheme) {
  return Row(
    children: [
      Text(
        'Less',
        style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant),
      ),
      const SizedBox(width: 4),
      ...[0, 1, 2, 3, 4].map((level) {
        return Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: _heatmapColor(
              level == 0
                  ? 0
                  : level == 1
                      ? 15 * 60
                      : level == 2
                          ? 30 * 60
                          : level == 3
                              ? 60 * 60
                              : 120 * 60,
              colorScheme,
            ),
            borderRadius: BorderRadius.circular(1),
          ),
        );
      }),
      const SizedBox(width: 4),
      Text(
        'More',
        style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant),
      ),
    ],
  );
}

void _showDayDetail(
  StreakDay day,
  BuildContext context,
  TextTheme textTheme,
  ColorScheme colorScheme,
) {
  final minutes = (day.durationSeconds / 60).ceil();
  final dateStr = '${monthLabel(day.date.month)} ${day.date.day}';
  final detail = minutes > 0
      ? '$dateStr — ${formatMinutes(minutes)} read'
      : '$dateStr — No activity';
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(detail),
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

class _MonthSpan {
  final int month;
  int count;
  _MonthSpan(this.month, this.count);
}
