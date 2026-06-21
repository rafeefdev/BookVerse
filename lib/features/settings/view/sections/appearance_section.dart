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
    final textTheme = context.textTheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Row(
            children: [
              Icon(Icons.palette_outlined, size: 20, color: cs.onSurfaceVariant),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Appearance',
                      style: textTheme.titleSmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Customize app appearance',
                      style: textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                children: [
                  SizedBox(
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
                ],
              ),
            ),
          ),
        ),
        const Divider(),
      ],
    );
  }
}
