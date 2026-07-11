import 'package:book_verse/core/theme/themes_extension.dart';
import 'package:book_verse/core/utils/page_utils.dart';
import 'package:flutter/material.dart';

class ReadingBarData {
  final String label;
  final double value;
  final bool isHighlighted;

  const ReadingBarData({
    required this.label,
    required this.value,
    this.isHighlighted = false,
  });
}

class ReadingBarChart extends StatelessWidget {
  final List<ReadingBarData> data;
  final double containerHeight;
  final bool showPages;
  final Color Function(bool isHighlighted) barColor;
  final String Function(double value) valueFormatter;

  const ReadingBarChart({
    required this.data,
    required this.containerHeight,
    required this.showPages,
    required this.barColor,
    required this.valueFormatter,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();

    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    final maxValue = data.map((d) => d.value).reduce(
          (a, b) => a > b ? a : b,
        );
    final refMax = computeNiceCeiling(maxValue);
    final gridLines = computeGridLines(refMax);
    final labelColor =
        colorScheme.onSurfaceVariant.withValues(alpha: 0.5);
    final gridColor =
        colorScheme.outlineVariant.withValues(alpha: 0.3);

    return SizedBox(
      height: containerHeight + 48,
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Column(
              children: [
                Text(
                  valueFormatter(refMax),
                  style: textTheme.labelSmall?.copyWith(
                    fontSize: 9,
                    color: labelColor,
                  ),
                ),
                const Spacer(),
                for (int i = gridLines.length - 1; i >= 0; i--)
                  Text(
                    valueFormatter(gridLines[i]),
                    style: textTheme.labelSmall?.copyWith(
                      fontSize: 9,
                      color: labelColor,
                    ),
                  ),
                const Spacer(),
                Text(
                  '0',
                  style: textTheme.labelSmall?.copyWith(
                    fontSize: 9,
                    color: labelColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: SizedBox(
              height: containerHeight + 48,
              child: Stack(
                children: [
                  for (final line in gridLines)
                    Positioned(
                      top: containerHeight -
                          (line / refMax * containerHeight),
                      left: 0,
                      right: 0,
                      child: Container(height: 1, color: gridColor),
                    ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(height: 1, color: gridColor),
                  ),
                  Positioned(
                    top: containerHeight,
                    left: 0,
                    right: 0,
                    child: Container(height: 1, color: gridColor),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      height: containerHeight + 48,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: data.map((day) {
                          final barHeight =
                              (day.value / refMax) * containerHeight;
                          final showLabel = barHeight >= 20;
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.end,
                                children: [
                                  if (showLabel && day.value > 0)
                                    Text(
                                      valueFormatter(day.value),
                                      style: textTheme.labelSmall
                                          ?.copyWith(
                                        fontSize: 9,
                                        color: colorScheme
                                            .onSurfaceVariant,
                                      ),
                                    ),
                                  if (!showLabel)
                                    const SizedBox(height: 12),
                                  const SizedBox(height: 4),
                                  Container(
                                    height: barHeight.clamp(
                                        4.0, containerHeight),
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color:
                                          barColor(day.isHighlighted),
                                      borderRadius:
                                          BorderRadius.circular(6),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    day.label,
                                    style: textTheme.labelSmall
                                        ?.copyWith(
                                      fontWeight: day.isHighlighted
                                          ? FontWeight.bold
                                          : null,
                                      color: colorScheme
                                          .onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
