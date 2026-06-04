import 'package:book_verse/core/services/backup_service.dart';
import 'package:book_verse/core/shared/themes_extension.dart';
import 'package:book_verse/core/theme/providers/thememode_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode =
        ref.watch(thememodeProviderProvider).value ?? ThemeMode.system;
    final cs = context.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
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
            leading: Icon(
              Icons.format_paint_rounded,
              color: cs.onSurfaceVariant,
            ),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              'Data',
              style: context.textTheme.titleSmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.backup, color: cs.onSurfaceVariant),
            title: const Text('Backup Progress'),
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Backup'),
                  content: const Text(
                    'Export your reading progress and sessions to a JSON file?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text('Backup'),
                    ),
                  ],
                ),
              );
              if (confirmed == true && context.mounted) {
                try {
                  final path = await BackupService.instance.backupProgress();
                  if (context.mounted) {
                    await showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        title: Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            const Expanded(child: Text('Backup Complete')),
                          ],
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Your reading progress has been exported.',
                            ),
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: cs.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: SelectableText(
                                path,
                                style: context.textTheme.bodySmall?.copyWith(
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: path));
                              Navigator.of(ctx).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Path copied to clipboard'),
                                ),
                              );
                            },
                            child: const Text('Copy Path'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Backup failed: $e')),
                    );
                  }
                }
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.restore, color: cs.onSurfaceVariant),
            title: const Text('Restore Backup'),
            onTap: () async {
              final exists = await BackupService.instance.hasBackup();
              if (!exists && context.mounted) {
                await showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('No Backup'),
                    content: const Text(
                      'No backup file found. Create a backup first.',
                    ),
                    actions: [
                      FilledButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
                return;
              }
              if (!context.mounted) return;
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Restore Backup'),
                  content: const Text(
                    'All current reading progress will be replaced '
                    'with the backup. Current data will be auto-backed '
                    'up before restore. Continue?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text('Restore'),
                    ),
                  ],
                ),
              );
              if (confirmed == true && context.mounted) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (ctx) =>
                      const Center(child: CircularProgressIndicator()),
                );
                try {
                  final result = await BackupService.instance.restoreProgress();
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    await showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        title: const Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 28,
                            ),
                            SizedBox(width: 12),
                            Expanded(child: Text('Restore Complete')),
                          ],
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${result.progressCount} reading progress '
                              'records and ${result.sessionsCount} '
                              'sessions restored.',
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Previous data saved to:',
                              style: TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: cs.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: SelectableText(
                                result.snapshotPath,
                                style: context.textTheme.bodySmall?.copyWith(
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: result.snapshotPath),
                              );
                              Navigator.of(ctx).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Snapshot path copied to clipboard',
                                  ),
                                ),
                              );
                            },
                            child: const Text('Copy Path'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    final code = e is RestoreException
                        ? e.code
                        : RestoreErrorCode.unknown;
                    final message = e is RestoreException
                        ? e.message
                        : 'Unexpected error occurred.';
                    final detail = e is RestoreException ? e.detail : '';
                    await showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Row(
                          children: [
                            Icon(Icons.error, color: Colors.red, size: 28),
                            SizedBox(width: 12),
                            Expanded(child: Text('Restore Failed')),
                          ],
                        ),
                        content: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(message),
                              if (detail.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  detail,
                                  style: TextStyle(color: cs.onSurfaceVariant),
                                ),
                              ],
                              const SizedBox(height: 12),
                              ExpansionTile(
                                tilePadding: EdgeInsets.zero,
                                title: const Text(
                                  'How to fix this',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                children: [
                                  for (final tip in _tipsFor(code))
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '• ',
                                            style: TextStyle(color: cs.primary),
                                          ),
                                          Expanded(child: Text(tip)),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          FilledButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  }
                }
              }
            },
          ),
        ],
      ),
    );
  }

  static List<String> _tipsFor(RestoreErrorCode code) {
    switch (code) {
      case RestoreErrorCode.fileNotFound:
        return ['Create a backup first in Settings > Data > Backup Progress.'];
      case RestoreErrorCode.invalidJson:
        return [
          'Create a new backup from Settings > Data > Backup Progress.',
          'Do not edit the backup file manually.',
        ];
      case RestoreErrorCode.versionMismatch:
        return [
          'Update the app to the latest version.',
          'Create a fresh backup with the current app version.',
        ];
      case RestoreErrorCode.missingData:
        return [
          'Create a new backup from Settings > Data > Backup Progress.',
          'Avoid editing the backup file manually.',
        ];
      case RestoreErrorCode.databaseError:
        return [
          'Restart the app and try again.',
          'Free up storage space on your device.',
        ];
      case RestoreErrorCode.unknown:
        return [
          'Restart the app and try again.',
          'Create a new backup and attempt restore again.',
        ];
    }
  }
}
