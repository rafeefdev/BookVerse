import 'package:book_verse/features/settings/view/sections/appearance_section.dart';
import 'package:book_verse/features/settings/view/sections/data_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        top: false,
        bottom: true,
        child: ListView(children: [
          _navTile(
            context,
            icon: Icons.flag_outlined,
            title: 'Reading Goal',
            subtitle: 'Set your daily reading targets',
            onTap: () => context.push('/settings/goal'),
          ),
          const Divider(),
          _navTile(
            context,
            icon: Icons.notifications_outlined,
            title: 'Reading Reminders',
            subtitle: 'Configure notification schedule',
            onTap: () => context.push('/settings/reminder'),
          ),
          const Divider(),
          const AppearanceSection(),
          const DataSection(),
        ]),
      ),
    );
  }
}

Widget _navTile(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String subtitle,
  required VoidCallback onTap,
}) {
  final cs = Theme.of(context).colorScheme;
  final textTheme = Theme.of(context).textTheme;

  return InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: cs.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, size: 18, color: cs.onSurfaceVariant),
        ],
      ),
    ),
  );
}
