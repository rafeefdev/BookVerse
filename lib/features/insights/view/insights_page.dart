import 'package:book_verse/core/shared/themes_extension.dart';
import 'package:book_verse/features/insights/model/insights_state.dart';
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
          _buildAllTimeStats(state, textTheme, colorScheme),
          const SizedBox(height: 20),
          _buildStreakSection(state, textTheme, colorScheme),
          const SizedBox(height: 20),
          _buildAchievements(state, textTheme, colorScheme),
          const SizedBox(height: 20),
          _buildGenreDistribution(state, textTheme, colorScheme),
          const SizedBox(height: 20),
          _buildMonthlyChart(state, textTheme, colorScheme),
          const SizedBox(height: 20),
          _buildYtdSection(state, textTheme, colorScheme),
        ],
      ),
    );
  }

  Widget _buildAllTimeStats(
    InsightsState state,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('All-Time Stats', style: textTheme.titleMedium),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _statCard(
                    Icons.timer_outlined,
                    _formatHours(state.totalMinutes),
                    'hours',
                    colorScheme,
                    textTheme,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _statCard(
                    Icons.menu_book,
                    '${state.totalPages}',
                    'pages',
                    colorScheme,
                    textTheme,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _statCard(
                    Icons.library_books,
                    '${state.totalBooks}',
                    'books',
                    colorScheme,
                    textTheme,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(
    IconData icon,
    String value,
    String unit,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Column(
      children: [
        Icon(icon, color: colorScheme.primary, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          unit,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildStreakSection(
    InsightsState state,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Streak', style: textTheme.titleMedium),
            const SizedBox(height: 12),
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
            _buildHeatmap(state.streakHistory, colorScheme, textTheme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeatmap(
    List<StreakDay> streakHistory,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final weeks = <List<StreakDay>>[];
    for (var i = 0; i < streakHistory.length; i += 7) {
      weeks.add(
        streakHistory.sublist(i, (i + 7).clamp(0, streakHistory.length)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Last 90 days',
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 140.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(weeks.length, (weekIdx) {
              return Padding(
                padding: const EdgeInsets.only(right: 3),
                child: Column(
                  children: weeks[weekIdx].map((day) {
                    return Container(
                      width: 18,
                      height: 18,
                      margin: const EdgeInsets.only(bottom: 2),
                      decoration: BoxDecoration(
                        color: day.hasActivity
                            ? colorScheme.primary
                            : colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  }).toList(),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildAchievements(
    InsightsState state,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Achievements', style: textTheme.titleMedium),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final columnWidth = (constraints.maxWidth - 24) / 4;
                const targetCellHeight = 72.0;
                final ratio = columnWidth / targetCellHeight;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: ratio,
                  ),
                  itemCount: state.achievements.length,
                  itemBuilder: (context, index) {
                    final achievement = state.achievements[index];
                    return _achievementItem(
                      achievement,
                      colorScheme,
                      textTheme,
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _achievementItem(
    Achievement achievement,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final isUnlocked = achievement.unlocked;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isUnlocked
                ? colorScheme.primaryContainer
                : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            achievement.icon,
            color: isUnlocked
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            size: 24,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          achievement.title,
          style: textTheme.labelSmall?.copyWith(
            color: isUnlocked
                ? null
                : colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            fontSize: 10,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildGenreDistribution(
    InsightsState state,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    if (state.genreDistribution.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Genre Distribution', style: textTheme.titleMedium),
            const SizedBox(height: 16),
            ...state.genreDistribution.take(6).map((genre) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(genre.genre, style: textTheme.bodyMedium),
                        Text(
                          '${genre.bookCount} (${genre.percentage.toStringAsFixed(0)}%)',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: genre.percentage / 100,
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyChart(
    InsightsState state,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
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
                            _monthLabel(month.month),
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

  Widget _buildYtdSection(
    InsightsState state,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Year to Date', style: textTheme.titleMedium),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _statCard(
                    Icons.timer_outlined,
                    _formatHours(state.ytdMinutes),
                    'hours',
                    colorScheme,
                    textTheme,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _statCard(
                    Icons.menu_book,
                    '${state.ytdPages}',
                    'pages',
                    colorScheme,
                    textTheme,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatHours(int totalMinutes) {
    final hours = totalMinutes ~/ 60;
    final mins = totalMinutes % 60;
    if (hours > 0) return '${hours}h ${mins}m';
    return '${mins}m';
  }

  String _monthLabel(int month) {
    const labels = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return labels[month];
  }
}
