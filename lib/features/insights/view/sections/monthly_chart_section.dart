import 'package:book_verse/core/shared/components/reading_barchart_component.dart';
import 'package:book_verse/core/utils/page_utils.dart';
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
    final recentMonths = state.monthlyMinutes.take(6).toList();
    if (recentMonths.isEmpty) return const SizedBox.shrink();

    final barData = recentMonths
        .map((m) => ReadingBarData(
              label: monthLabel(m.month),
              value: m.minutes.toDouble(),
            ))
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Monthly Activity', style: textTheme.titleMedium),
            const SizedBox(height: 20),
            ReadingBarChart(
              data: barData,
              containerHeight: 180,
              showPages: false,
              barColor: (_) => colorScheme.primary,
              valueFormatter: (v) => formatMinutes(v.toInt()),
            ),
          ],
        ),
      ),
    );
  }
}
