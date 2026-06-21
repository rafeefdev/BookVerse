import 'package:book_verse/core/auth/providers/auth_provider.dart';
import 'package:book_verse/core/theme/themes_extension.dart';
import 'package:book_verse/core/theme/providers/thememode_provider.dart';
import 'package:book_verse/features/insights/viewmodel/insights_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ShellScaffold extends ConsumerWidget {
  const ShellScaffold({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initials = ref.watch(userInitialsProvider);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => _showUserProfileSheet(context, ref),
              child: CircleAvatar(child: Text(initials)),
            ),
            const SizedBox(width: 12),
            Text(
              [
                'Dashboard',
                'Explore',
                'My Library',
              ][navigationShell.currentIndex],
              style: context.textTheme.titleLarge,
            ),
          ],
        ),
        automaticallyImplyLeading: false,
        actionsPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        actions: [
          IconButton.filledTonal(
            onPressed: () {
              context.push('/settings');
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: SafeArea(top: false, bottom: true, child: navigationShell),
      bottomNavigationBar: SafeArea(
        top: false,
        child: BottomNavigationBar(
          currentIndex: navigationShell.currentIndex,
          onTap: (index) {
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore),
              label: 'Explore',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.library_books),
              label: 'My Library',
            ),
          ],
        ),
      ),
    );
  }

  void _showUserProfileSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _UserProfileSheet(),
    );
  }
}

class _UserProfileSheet extends ConsumerWidget {
  const _UserProfileSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final name = user?.userMetadata?['full_name'] as String? ?? 'User';
    final email = user?.email ?? '';
    final initials = ref.watch(userInitialsProvider);
    final currentTheme =
        ref.watch(thememodeProviderProvider).value ?? ThemeMode.system;
    final isDark =
        currentTheme == ThemeMode.dark ||
        (currentTheme == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    child: Text(initials, style: const TextStyle(fontSize: 20)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: context.textTheme.titleMedium),
                        if (email.isNotEmpty)
                          Text(email, style: context.textTheme.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _AchievementsSection(),
              const SizedBox(height: 8),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  final router = GoRouter.of(context);
                  Navigator.of(context).pop();
                  router.push('/settings');
                },
              ),
              ListTile(
                leading: const Icon(Icons.dark_mode),
                title: const Text('Dark Mode'),
                trailing: Switch(
                  value: isDark,
                  onChanged: (v) {
                    ref
                        .read(thememodeProviderProvider.notifier)
                        .changeTheme(v ? ThemeMode.dark : ThemeMode.light);
                  },
                ),
              ),
              const SizedBox(height: 8),
              const Divider(),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonalIcon(
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Keluar'),
                        content: const Text('Apakah kamu yakin ingin keluar?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: const Text('Batal'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: const Text('Keluar'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true && context.mounted) {
                      Navigator.of(context).pop();
                      await ref.read(authServiceProvider).signOut();
                    }
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Keluar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AchievementsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insightsAsync = ref.watch(insightsProvider);
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return insightsAsync.when(
      data: (state) {
        final unlocked = state.achievements.where((a) => a.unlocked).toList();
        if (unlocked.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('Achievements', style: textTheme.titleSmall),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 60,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: unlocked.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final a = unlocked[index];
                  return Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          a.icon,
                          color: colorScheme.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        a.title,
                        style: textTheme.labelSmall?.copyWith(fontSize: 9),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
