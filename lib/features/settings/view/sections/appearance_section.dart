import 'package:book_verse/core/theme/themes_extension.dart';
import 'package:book_verse/core/theme/providers/thememode_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppearanceSection extends ConsumerWidget {
  const AppearanceSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode =
        ref.watch(thememodeProviderProvider).value ?? ThemeMode.system;
    final cs = context.colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text(
            'Appearance',
            style: context.textTheme.titleSmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ),
        ListTile(
          title: const Text('App Theme'),
          subtitle: const Text('Change app theme'),
          leading: Icon(Icons.format_paint_rounded, color: cs.onSurfaceVariant),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            width: double.infinity,
            child: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                  value: ThemeMode.light,
                  icon: Icon(Icons.light_mode),
                  label: Text('Light'),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  icon: Icon(Icons.dark_mode),
                  label: Text('Dark'),
                ),
                ButtonSegment(
                  value: ThemeMode.system,
                  icon: Icon(Icons.settings_suggest),
                  label: Text('System'),
                ),
              ],
              selected: {themeMode},
              onSelectionChanged: (value) {
                ref
                    .read(thememodeProviderProvider.notifier)
                    .changeTheme(value.first);
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Divider(),
      ],
    );
  }
}
