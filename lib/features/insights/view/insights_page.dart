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
        data: (state) => _buildContent(context, state, textTheme, colorScheme),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    InsightsState state,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNarrativeHeader(state, textTheme, colorScheme),
          const SizedBox(height: 20),
          _buildStreakSection(context, state, textTheme, colorScheme),
          if (state.monthlyMinutes.isNotEmpty) ...[
            const SizedBox(height: 20),
            _buildMonthlyChart(state, textTheme, colorScheme),
          ],
          const SizedBox(height: 20),
          _buildYtdSection(state, textTheme, colorScheme),
          if (state.genreDistribution.isNotEmpty) ...[
            const SizedBox(height: 20),
            _buildGenreDistribution(context, state, textTheme, colorScheme),
          ],
          if (state.achievements.any((a) => a.unlocked) ||
              state.totalMinutes >= 5) ...[
            const SizedBox(height: 20),
            _buildAchievements(state, textTheme, colorScheme),
          ],
          if (state.totalMinutes > 0) ...[
            const SizedBox(height: 20),
            _buildAllTimeStats(state, textTheme, colorScheme),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildNarrativeHeader(
    InsightsState state,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    String headline;
    IconData icon;
    Color iconColor;

    if (state.streakStatus == StreakStatus.active) {
      headline =
          '🔥 ${state.currentStreak}-day streak! Keep reading to maintain it.';
      icon = Icons.local_fire_department;
      iconColor = colorScheme.error;
    } else if (state.streakStatus == StreakStatus.atRisk) {
      headline = state.currentStreak == 1
          ? '📖 Read today to build your streak!'
          : '📖 ${state.currentStreak}-day streak — read today to keep it going!';
      icon = Icons.timer_outlined;
      iconColor = colorScheme.tertiary;
    } else if (state.streakStatus == StreakStatus.broken) {
      headline = state.totalMinutes > 0
          ? '✨ Start a new streak today!'
          : '📚 Start reading to track your progress!';
      icon = Icons.auto_stories;
      iconColor = colorScheme.primary;
    } else {
      headline = '📚 Start reading to see your insights!';
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
                    null,
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
    String? unit,
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
        if (unit != null)
          Text(
            unit,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          )
        else
          const SizedBox(height: 14),
      ],
    );
  }

  Widget _buildStreakSection(
    BuildContext context,
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
            _buildStreakStatusIndicator(state, textTheme, colorScheme),
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

  Widget _buildStreakStatusIndicator(
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
                                  _showDayDetail(weeks[w][d], context),
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
    return Row(
      children: [
        for (int i = 0; i < weeks.length; i++) ...[
          if (i > 0) SizedBox(width: gap),
          SizedBox(
            width: cellSize,
            child: i == 0 ||
                    weeks[i].first.date.month !=
                        weeks[i - 1].first.date.month
                ? Text(
                    _monthLabel(weeks[i].first.date.month),
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ],
    );
  }

  Widget _buildLegend(ColorScheme colorScheme) {
    return Row(
      children: [
        Text(
          'Less',
          style: TextStyle(
            fontSize: 10,
            color: colorScheme.onSurfaceVariant,
          ),
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
          style: TextStyle(
            fontSize: 10,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  void _showDayDetail(StreakDay day, BuildContext context) {
    final minutes = (day.durationSeconds / 60).ceil();
    final dateStr = '${_monthLabel(day.date.month)} ${day.date.day}';
    final detail = minutes > 0
        ? '$dateStr — ${_formatDuration(minutes)} read'
        : '$dateStr — No activity';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(detail),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) return '${minutes}m';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m > 0 ? '${h}h ${m}m' : '${h}h';
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
                const targetCellHeight = 82.0;
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
        Stack(
          clipBehavior: Clip.none,
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
            if (!isUnlocked && achievement.progress > 0)
              Positioned(
                bottom: -2,
                left: 0,
                right: 0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: achievement.progress,
                    minHeight: 3,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                  ),
                ),
              ),
          ],
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
    BuildContext context,
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
                child: InkWell(
                  onTap: () => _showGenreBooks(
                    genre.genre,
                    context,
                    textTheme,
                    colorScheme,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              genre.genre,
                              style: textTheme.bodyMedium,
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${genre.bookCount} (${genre.percentage.toStringAsFixed(0)}%)',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.chevron_right,
                                  size: 16,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ],
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
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showGenreBooks(
    String genre,
    BuildContext context,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                genre,
                style: textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Browse your ${genre.toLowerCase()} collection in the Library.',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('Go to Library'),
                ),
              ),
            ],
          ),
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
                    null,
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

