import 'package:book_verse/core/theme/themes_extension.dart';
import 'package:book_verse/features/insights/model/insights_state.dart';
import 'package:book_verse/features/insights/view/sections/narrative_header_section.dart';
import 'package:book_verse/features/insights/view/sections/streak_section.dart';
import 'package:book_verse/features/insights/view/sections/monthly_chart_section.dart';
import 'package:book_verse/features/insights/view/sections/ytd_section.dart';
import 'package:book_verse/features/insights/view/sections/genre_distribution_section.dart';
import 'package:book_verse/features/insights/view/sections/achievements_section.dart';
import 'package:book_verse/features/insights/view/sections/all_time_stats_section.dart';
import 'package:book_verse/features/insights/viewmodel/insights_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InsightsPage extends ConsumerWidget {
  const InsightsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insightsAsync = ref.watch(insightsProvider);
    final textTheme = context.textTheme;
    final colorScheme = context.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Insights')),
      body: insightsAsync.when(
        data: (state) => _buildContent(state, textTheme, colorScheme),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

Widget _buildContent(
  InsightsState state,
  TextTheme textTheme,
  ColorScheme colorScheme,
) {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NarrativeHeaderSection(state, textTheme, colorScheme),
        const SizedBox(height: 20),
        StreakSection(state, textTheme, colorScheme),
        if (state.monthlyMinutes.isNotEmpty) ...[
          const SizedBox(height: 20),
          MonthlyChartSection(state, textTheme, colorScheme),
        ],
        const SizedBox(height: 20),
        YtdSection(state, textTheme, colorScheme),
        if (state.genreDistribution.isNotEmpty) ...[
          const SizedBox(height: 20),
          GenreDistributionSection(state, textTheme, colorScheme),
        ],
        if (state.achievements.any((a) => a.unlocked) ||
            state.totalMinutes >= 5) ...[
          const SizedBox(height: 20),
          AchievementsSection(state, textTheme, colorScheme),
        ],
        if (state.totalMinutes > 0) ...[
          const SizedBox(height: 20),
          AllTimeStatsSection(state, textTheme, colorScheme),
        ],
        const SizedBox(height: 20),
      ],
    ),
  );
}
