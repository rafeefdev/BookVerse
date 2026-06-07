import 'package:book_verse/features/settings/view/sections/appearance_section.dart';
import 'package:book_verse/features/settings/view/sections/data_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: const [
          AppearanceSection(),
          DataSection(),
        ],
      ),
    );
  }
}
