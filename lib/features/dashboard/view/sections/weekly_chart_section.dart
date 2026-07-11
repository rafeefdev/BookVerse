import 'package:book_verse/core/shared/components/reading_barchart_component.dart';
import 'package:book_verse/core/utils/page_utils.dart';
import 'package:book_verse/features/dashboard/model/dashboard_state.dart';
import 'package:flutter/material.dart';

class WeeklyChartSection extends StatelessWidget {
  final DashboardState state;
  final bool showPages;
  final VoidCallback onToggle;
  final VoidCallback? onTap;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  const WeeklyChartSection({
    required this.state,
    required this.showPages,
    required this.onToggle,
    this.onTap,
    required this.textTheme,
    required this.colorScheme,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final barData = state.weeklyReading
        .map((d) => ReadingBarData(
              label: d.label,
              value: (showPages ? d.pages : d.minutes).toDouble(),
              isHighlighted: d.isToday,
            ))
        .toList();

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Weekly Progress', style: textTheme.titleMedium),
              const SizedBox(height: 20),
              ReadingBarChart(
                data: barData,
                containerHeight: 180,
                showPages: showPages,
                barColor: (isHighlighted) => isHighlighted
                    ? colorScheme.primary
                    : colorScheme.primaryContainer,
                valueFormatter: showPages
                    ? (v) => '${v.toInt()}'
                    : (v) => formatMinutes(v.toInt()),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (state.streak > 0) ...[
                    Icon(
                      Icons.local_fire_department,
                      color: colorScheme.error,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${state.streak}-day streak',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const Spacer(),
                  Material(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: onToggle,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              showPages
                                  ? Icons.menu_book
                                  : Icons.timer_outlined,
                              size: 16,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              showPages ? 'Pages' : 'Duration',
                              style: textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
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
}
