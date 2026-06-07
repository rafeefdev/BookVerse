import 'package:book_verse/features/insights/model/insights_state.dart';
import 'package:book_verse/features/insights/view/components/stat_card.dart';
import 'package:book_verse/features/insights/view/components/insights_helpers.dart';
import 'package:flutter/material.dart';

class YtdSection extends StatelessWidget {
  final InsightsState state;
  final TextTheme textTheme;
  final ColorScheme colorScheme;
  const YtdSection(this.state, this.textTheme, this.colorScheme, {super.key});

  @override
  Widget build(BuildContext context) {
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
                  child: StatCard(
                    icon: Icons.timer_outlined,
                    value: formatHours(state.ytdMinutes),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    icon: Icons.menu_book,
                    value: '${state.ytdPages}',
                    unit: 'pages',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
