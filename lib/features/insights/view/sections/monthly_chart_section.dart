import 'package:book_verse/features/insights/model/insights_state.dart';
import 'package:book_verse/features/insights/view/components/insights_helpers.dart';
import 'package:flutter/material.dart';

class MonthlyChartSection extends StatelessWidget {
  final InsightsState state;
  final TextTheme textTheme;
  final ColorScheme colorScheme;
  const MonthlyChartSection(
    this.state,
    this.textTheme,
    this.colorScheme, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const containerHeight = 180.0;
    final recentMonths = state.monthlyMinutes.take(6).toList();
    if (recentMonths.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Monthly Activity', style: textTheme.titleMedium),
            const SizedBox(height: 20),
            SizedBox(
              height: containerHeight + 48,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(recentMonths.length, (i) {
                  final month = recentMonths[i];
                  final barHeight = (month.minutes / 60.0) * containerHeight;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (month.minutes > 0)
                            Text(
                              '${month.minutes}m',
                              style: textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          const SizedBox(height: 4),
                          Container(
                            height: barHeight.clamp(4.0, containerHeight),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            monthLabel(month.month),
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
