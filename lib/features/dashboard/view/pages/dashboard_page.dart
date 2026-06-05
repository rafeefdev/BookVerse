import 'package:book_verse/core/shared/components/booklisttile_component.dart';
import 'package:book_verse/core/shared/themes_extension.dart';
import 'package:book_verse/features/dashboard/model/dashboard_state.dart';
import 'package:book_verse/features/dashboard/viewmodel/dashboard_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  bool _showPages = false;

  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(dashboardProvider);
    final textTheme = context.textTheme;
    final colorScheme = context.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: dashboardAsync.when(
          data: (state) => _buildContent(state, textTheme, colorScheme),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }

  Widget _buildContent(
    DashboardState state,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTodaySummary(state, textTheme, colorScheme),
          const SizedBox(height: 16),
          _buildWeeklyChart(state, textTheme, colorScheme),
          const SizedBox(height: 16),
          _buildCurrentlyReading(state, textTheme, colorScheme),
          if (state.todayMinutes > 0 || state.streak > 0)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/insights'),
                  icon: const Icon(Icons.insights),
                  label: const Text('See Insights'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTodaySummary(
    DashboardState state,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Today's Summary", style: textTheme.titleMedium),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _statCard(
                Icons.timer_outlined,
                '${state.todayMinutes}',
                'minutes',
                colorScheme,
                textTheme,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard(
                Icons.menu_book,
                '${state.todayPages}',
                'pages',
                colorScheme,
                textTheme,
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

  Widget _statCard(
    IconData icon,
    String value,
    String unit,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Icon(icon, color: colorScheme.onSurfaceVariant),
            const SizedBox(height: 8),
            Text(
              value,
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              unit,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
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

  Widget _buildWeeklyChart(
    DashboardState state,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    final values = state.weeklyReading
        .map((d) => _showPages ? d.pages : d.minutes)
        .toList();
    const containerHeight = 180.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Weekly Progress', style: textTheme.titleMedium),
            const SizedBox(height: 20),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: containerHeight + 48,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(state.weeklyReading.length, (i) {
                  final day = state.weeklyReading[i];
                  final val = values[i];
                  final refMax = _showPages ? 150.0 : 60.0;
                  final barHeight = (val / refMax) * containerHeight;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (val > 0)
                            Text(
                              '$val',
                              style: textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          const SizedBox(height: 4),
                          Container(
                            height: barHeight.clamp(4.0, containerHeight),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: day.isToday
                                  ? colorScheme.primary
                                  : colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            day.label,
                            style: textTheme.labelSmall?.copyWith(
                              fontWeight: day.isToday ? FontWeight.bold : null,
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
                GestureDetector(
                  onTap: () => setState(() => _showPages = !_showPages),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.swap_horiz,
                        size: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _showPages ? 'pages' : 'duration',
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentlyReading(
    DashboardState state,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    if (state.currentlyReading.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Currently Reading', style: textTheme.titleMedium),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'No books being read yet',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Currently Reading', style: textTheme.titleMedium),
            TextButton(
              onPressed: () => context.go('/library'),
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ...state.currentlyReading.map((progress) {
          final book = progress.book!;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: bookListTile(
              context,
              book,
              readingProgress: progress,
              isWrappedByCard: true,
              onTap: () => context.push('/tracked-book-detail/${book.id}'),
            ),
          );
        }),
      ],
    );
  }
}
