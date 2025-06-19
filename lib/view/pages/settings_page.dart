import 'package:book_verse/provider/thememode_provider.dart';
import 'package:book_verse/view/components/settingsswitch_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsPage extends ConsumerWidget {
  SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode =
        ref.watch(thememodeProviderProvider).value ?? ThemeMode.system;
    bool isDarkMode = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings Page')),
      body: Column(
        children: [
          ListTile(
            title: const Text('Dark Theme'),
            subtitle: const Text('Change app theme to dark'),
            leading: CircleAvatar(child: Icon(Icons.format_paint_rounded)),
            trailing: SettingsSwitch(
              settingsItem: isDarkMode,
              onChanged: (value) {
                final newMode = value ? ThemeMode.dark : ThemeMode.light;
                ref.read(thememodeProviderProvider.notifier).changeTheme(newMode);
              },
            ),
          ),
        ],
      ),
    );
  }
}
