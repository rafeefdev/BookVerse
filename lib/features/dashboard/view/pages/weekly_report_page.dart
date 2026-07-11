import 'package:book_verse/core/shared/components/reading_barchart_component.dart';
import 'package:book_verse/core/shared/helpers/book_authors.dart';
import 'package:book_verse/core/theme/themes_extension.dart';
import 'package:book_verse/core/utils/page_utils.dart';
import 'package:book_verse/features/dashboard/model/weekly_report_state.dart';
import 'package:book_verse/features/dashboard/viewmodel/weekly_report_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class WeeklyReportPage extends ConsumerStatefulWidget {
  const WeeklyReportPage({super.key});

  @override
  ConsumerState<WeeklyReportPage> createState() => _WeeklyReportPageState();
}

class _WeeklyReportPageState extends ConsumerState<WeeklyReportPage> {
  int _weekOffset = 0;
  bool _showPages = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final colorScheme = context.colorScheme;
    final reportAsync = ref.watch(weeklyReportProvider(_weekOffset));

    return Scaffold(
      appBar: AppBar(title: const Text('Weekly Report')),
      body: SafeArea(
        child: reportAsync.when(
          data: (state) => _buildContent(state, textTheme, colorScheme),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }

  Widget _buildContent(
    dynamic state,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    final reportState = state as WeeklyReportState;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWeekNavigation(reportState, textTheme, colorScheme),
          const SizedBox(height: 20),
          _buildChart(reportState, textTheme, colorScheme),
          const SizedBox(height: 16),
          Center(
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: false,
                  label: Text('Duration'),
                  icon: Icon(Icons.timer_outlined, size: 16),
                ),
                ButtonSegment(
                  value: true,
                  label: Text('Pages'),
                  icon: Icon(Icons.menu_book, size: 16),
                ),
              ],
              selected: {_showPages},
              onSelectionChanged: (selected) =>
                  setState(() => _showPages = selected.first),
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                textStyle: WidgetStatePropertyAll(textTheme.labelSmall),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildInsightCards(reportState, textTheme, colorScheme),
          if (reportState.booksRead.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text('Books Read This Week', style: textTheme.titleMedium),
            const SizedBox(height: 8),
            ...reportState.booksRead.map((summary) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _bookRow(summary, textTheme, colorScheme),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _bookRow(
    dynamic summary,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    final book = summary.book as dynamic;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/tracked-book-detail/${book.id}'),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: book.thumbnail.isNotEmpty
                    ? Image.network(
                        book.thumbnail,
                        width: 40,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _placeholderIcon(colorScheme),
                      )
                    : _placeholderIcon(colorScheme),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      bookAuthors(book),
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
            '${summary.totalSessions} sessions  •  '
            '${formatMinutes(summary.totalDurationSeconds ~/ 60)}  •  '
                      '${summary.totalPages} pages',
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholderIcon(ColorScheme colorScheme) {
    return Container(
      width: 40,
      height: 56,
      color: colorScheme.surfaceContainerHighest,
      child: Icon(Icons.book, size: 20, color: colorScheme.onSurfaceVariant),
    );
  }

  Widget _buildWeekNavigation(
    WeeklyReportState state,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    final weekStart = state.weekStart;
    final weekEnd = state.weekEnd.subtract(const Duration(days: 1));
    final months = [
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

    String weekLabel;
    if (weekStart.month == weekEnd.month) {
      weekLabel =
          '${weekStart.day} - ${weekEnd.day} ${months[weekEnd.month]} ${weekEnd.year}';
    } else if (weekStart.year == weekEnd.year) {
      weekLabel =
          '${weekStart.day} ${months[weekStart.month]} - ${weekEnd.day} ${months[weekEnd.month]} ${weekEnd.year}';
    } else {
      weekLabel =
          '${weekStart.day} ${months[weekStart.month]} ${weekStart.year} - '
          '${weekEnd.day} ${months[weekEnd.month]} ${weekEnd.year}';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => setState(() => _weekOffset--),
          tooltip: 'Previous week',
        ),
        const SizedBox(width: 8),
        Text(
          weekLabel,
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: _weekOffset < 0
              ? () => setState(() => _weekOffset++)
              : null,
          tooltip: 'Next week',
        ),
      ],
    );
  }

  Widget _buildChart(
    WeeklyReportState state,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    final barData = state.weeklyReading
        .map((d) => ReadingBarData(
              label: d.label,
              value: (_showPages ? d.pages : d.minutes).toDouble(),
              isHighlighted: d.isToday,
            ))
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ReadingBarChart(
          data: barData,
          containerHeight: 200,
          showPages: _showPages,
          barColor: (isHighlighted) => isHighlighted
              ? colorScheme.primary
              : colorScheme.primaryContainer,
          valueFormatter: _showPages
              ? (v) => '${v.toInt()}'
              : (v) => formatMinutes(v.toInt()),
        ),
      ),
    );
  }

  Widget _buildInsightCards(
    WeeklyReportState state,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Row(
      children: [
        Expanded(
          child: _insightCard(
            Icons.menu_book,
            '${state.totalPages}',
            'Pages',
            colorScheme,
            textTheme,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: _insightCard(
            Icons.timer_outlined,
            formatMinutes(state.totalMinutes),
            'Duration',
            colorScheme,
            textTheme,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: _insightCard(
            Icons.read_more,
            '${state.totalSessions}',
            'Sessions',
            colorScheme,
            textTheme,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: _insightCard(
            Icons.local_fire_department,
            '${state.activeDays}',
            'Active days',
            colorScheme,
            textTheme,
          ),
        ),
      ],
    );
  }

  Widget _insightCard(
    IconData icon,
    String value,
    String label,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
