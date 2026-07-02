import 'package:book_verse/core/theme/themes_extension.dart';
import 'package:book_verse/features/dashboard/model/dashboard_state.dart';
import 'package:book_verse/features/dashboard/view/sections/today_summary_section.dart';
import 'package:book_verse/features/dashboard/view/sections/weekly_chart_section.dart';
import 'package:book_verse/features/dashboard/view/sections/currently_reading_section.dart';
import 'package:book_verse/features/dashboard/viewmodel/dashboard_viewmodel.dart';
import 'package:book_verse/features/goals/model/goal_progress.dart';
import 'package:book_verse/features/goals/providers/goal_providers.dart';
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
  final Set<String> _dismissedBanners = {};

  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(dashboardProvider);
    final textTheme = context.textTheme;
    final colorScheme = context.colorScheme;
    final goalProgressAsync = ref.watch(goalProgressProvider);

    return Scaffold(
      body: dashboardAsync.when(
        data: (state) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_buildBanner(
                    state,
                    goalProgressAsync.valueOrNull,
                    colorScheme,
                  )
                  case final banner?)
                banner,
              TodaySummarySection(
                state,
                goalProgressAsync.valueOrNull,
                textTheme,
                colorScheme,
              ),
              const SizedBox(height: 16),
              WeeklyChartSection(
                state: state,
                showPages: _showPages,
                onToggle: () => setState(() => _showPages = !_showPages),
                onTap: () => context.push('/dashboard/weekly-report'),
                textTheme: textTheme,
                colorScheme: colorScheme,
              ),
              const SizedBox(height: 16),
              CurrentlyReadingSection(state, textTheme, colorScheme),
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
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget? _buildBanner(
    DashboardState state,
    GoalProgress? goalProgress,
    ColorScheme colorScheme,
  ) {
    if (_dismissedBanners.contains('streak') &&
        _dismissedBanners.contains('goal')) {
      return null;
    }

    if (state.streak >= 1 &&
        state.streak < 3 &&
        state.todayMinutes == 0 &&
        !_dismissedBanners.contains('streak')) {
      return _Banner(
        icon: Icons.local_fire_department,
        color: Colors.orange,
        message:
            '${state.streak}-day streak at risk! '
            'Read just 5 min today to keep it alive.',
        actionLabel: 'Start Reading',
        onAction: () {
          if (state.currentlyReading.isNotEmpty) {
            context.push(
              '/tracked-book-detail/${state.currentlyReading.first.bookId}',
            );
          } else {
            context.push('/library');
          }
        },
        onDismiss: () => setState(() => _dismissedBanners.add('streak')),
      );
    }

    if (goalProgress != null &&
        goalProgress.status == GoalStatus.behind &&
        !_dismissedBanners.contains('goal')) {
      return _Banner(
        icon: Icons.library_books,
        color: colorScheme.error,
        message:
            '${goalProgress.pagesRemaining} pages behind today\'s goal. '
            'Just 5 minutes to catch up.',
        actionLabel: 'Read Now',
        onAction: () {
          if (state.currentlyReading.isNotEmpty) {
            context.push(
              '/tracked-book-detail/${state.currentlyReading.first.bookId}',
            );
          } else {
            context.push('/library');
          }
        },
        onDismiss: () => setState(() => _dismissedBanners.add('goal')),
      );
    }

    return null;
  }
}

class _Banner extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;
  final VoidCallback onDismiss;

  const _Banner({
    required this.icon,
    required this.color,
    required this.message,
    required this.actionLabel,
    required this.onAction,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: cs.onSurface),
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: onAction,
                style: TextButton.styleFrom(foregroundColor: color),
                child: Text(actionLabel),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: onDismiss,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
