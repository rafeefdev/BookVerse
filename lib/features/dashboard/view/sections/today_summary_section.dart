import 'package:book_verse/features/dashboard/model/dashboard_state.dart';
import 'package:book_verse/features/dashboard/view/components/dashboard_stat_card.dart';
import 'package:flutter/material.dart';

class TodaySummarySection extends StatelessWidget {
  final DashboardState state;
  final TextTheme textTheme;
  final ColorScheme colorScheme;
  const TodaySummarySection(
    this.state,
    this.textTheme,
    this.colorScheme, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Today's Summary", style: textTheme.titleMedium),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DashboardStatCard(
                icon: Icons.timer_outlined,
                value: '${state.todayMinutes}',
                unit: 'minutes',
                colorScheme: colorScheme,
                textTheme: textTheme,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DashboardStatCard(
                icon: Icons.menu_book,
                value: '${state.todayPages}',
                unit: 'pages',
                colorScheme: colorScheme,
                textTheme: textTheme,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          _comparisonText(state.todayMinutes, state.yesterdayMinutes),
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  String _comparisonText(int todayMin, int yesterdayMin) {
    if (todayMin == 0 && yesterdayMin == 0) {
      return 'No reading activity yet';
    }
    if (todayMin == 0 && yesterdayMin > 0) {
      return "Haven't read today";
    }
    if (todayMin > 0 && yesterdayMin == 0) {
      return 'Started reading today! (+$todayMin minutes)';
    }
    if (todayMin == yesterdayMin) {
      return 'Same as yesterday ($yesterdayMin minutes)';
    }
    if (todayMin > yesterdayMin) {
      final pct = (((todayMin - yesterdayMin) / yesterdayMin) * 100).round();
      return '↑ $pct% more than yesterday';
    }
    final pct = (((yesterdayMin - todayMin) / yesterdayMin) * 100).round();
    return '↓ $pct% less than yesterday';
  }
}
