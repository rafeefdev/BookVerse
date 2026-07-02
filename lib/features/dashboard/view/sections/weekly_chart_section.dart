import 'package:book_verse/features/dashboard/model/dashboard_state.dart';
import 'package:flutter/material.dart';

class WeeklyChartSection extends StatelessWidget {
  final DashboardState state;
  final bool showPages;
  final VoidCallback onToggle;
  final VoidCallback? onTap;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  const WeeklyChartSection({
    required this.state,
    required this.showPages,
    required this.onToggle,
    this.onTap,
    required this.textTheme,
    required this.colorScheme,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final values = state.weeklyReading
        .map((d) => showPages ? d.pages : d.minutes)
        .toList();
    const containerHeight = 180.0;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
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
                    final refMax = showPages ? 150.0 : 60.0;
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
                                fontWeight: day.isToday
                                    ? FontWeight.bold
                                    : null,
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
                  Material(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: onToggle,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              showPages
                                  ? Icons.menu_book
                                  : Icons.timer_outlined,
                              size: 16,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              showPages ? 'Pages' : 'Duration',
                              style: textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
