import 'package:flutter/material.dart';

class DashboardStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String unit;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const DashboardStatCard({
    required this.icon,
    required this.value,
    required this.unit,
    required this.colorScheme,
    required this.textTheme,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
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
}
