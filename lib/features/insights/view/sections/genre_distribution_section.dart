import 'package:book_verse/features/insights/model/insights_state.dart';
import 'package:flutter/material.dart';

class GenreDistributionSection extends StatelessWidget {
  final InsightsState state;
  final TextTheme textTheme;
  final ColorScheme colorScheme;
  const GenreDistributionSection(this.state, this.textTheme, this.colorScheme, {super.key});

  @override
  Widget build(BuildContext context) {
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
                  onTap: () => _showGenreBooks(genre.genre, context, textTheme, colorScheme),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(genre.genre, style: textTheme.bodyMedium),
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
                                Icon(Icons.chevron_right, size: 16, color: colorScheme.onSurfaceVariant),
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

  void _showGenreBooks(String genre, BuildContext context, TextTheme textTheme, ColorScheme colorScheme) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(genre, style: textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                'Browse your ${genre.toLowerCase()} collection in the Library.',
                style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Go to Library'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
