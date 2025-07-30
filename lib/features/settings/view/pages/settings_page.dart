import 'package:book_verse/core/providers/thememode_provider.dart';
import 'package:book_verse/core/shared/themes_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode =
        ref.watch(thememodeProviderProvider).value ?? ThemeMode.system;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings Page')),
      body: Column(
        children: [
          ListTile(
            title: const Text('App Theme'),
            subtitle: const Text('Change app theme'),
            leading: CircleAvatar(child: Icon(Icons.format_paint_rounded)),
            trailing: DropdownButtonHideUnderline(
              child: DropdownButton<ThemeMode>(
                value: themeMode,
                elevation: 2,
                style: context.textTheme.bodyMedium,
                items: [
                  customDropdownMenuItem(
                    value: ThemeMode.dark,
                    onTap: () {},
                    icon: Icons.dark_mode_rounded,
                    label: 'dark',
                  ),
                  customDropdownMenuItem(
                    value: ThemeMode.light,
                    onTap: () {},
                    icon: Icons.light_mode_rounded,
                    label: 'light',
                  ),
                  customDropdownMenuItem(
                    value: ThemeMode.system,
                    onTap: () {},
                    icon: Icons.system_security_update_good_rounded,
                    label: 'system',
                  ),
                ],
                onChanged: (value) async {
                  await ref
                      .read(thememodeProviderProvider.notifier)
                      .changeTheme(value!);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  DropdownMenuItem<ThemeMode> customDropdownMenuItem({
    dynamic value,
    required VoidCallback onTap,
    required IconData icon,
    required String label,
  }) {
    return DropdownMenuItem(
      value: value,
      onTap: onTap,
      child: Row(spacing: 8, children: [Icon(icon), Text(label)]),
    );
  }
}
