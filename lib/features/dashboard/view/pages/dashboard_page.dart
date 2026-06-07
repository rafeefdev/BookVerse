import 'package:book_verse/core/theme/themes_extension.dart';
import 'package:book_verse/features/dashboard/view/sections/today_summary_section.dart';
import 'package:book_verse/features/dashboard/view/sections/weekly_chart_section.dart';
import 'package:book_verse/features/dashboard/view/sections/currently_reading_section.dart';
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
          data: (state) => SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TodaySummarySection(state, textTheme, colorScheme),
                const SizedBox(height: 16),
                WeeklyChartSection(
                  state: state,
                  showPages: _showPages,
                  onToggle: () => setState(() => _showPages = !_showPages),
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
      ),
    );
  }
}
