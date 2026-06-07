import 'package:book_verse/features/insights/model/insights_state.dart';
import 'package:flutter/material.dart';

class AchievementsSection extends StatelessWidget {
  final InsightsState state;
  final TextTheme textTheme;
  final ColorScheme colorScheme;
  const AchievementsSection(this.state, this.textTheme, this.colorScheme, {super.key});

  @override
  Widget build(BuildContext context) {
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
                    return _achievementItem(achievement, colorScheme, textTheme);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _achievementItem(Achievement achievement, ColorScheme colorScheme, TextTheme textTheme) {
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
}
