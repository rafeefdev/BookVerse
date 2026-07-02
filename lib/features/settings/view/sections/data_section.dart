import 'package:book_verse/core/services/backup_service.dart';
import 'package:book_verse/features/home/providers/detail_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DataSection extends ConsumerWidget {
  const DataSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Row(
            children: [
              Icon(Icons.backup_outlined, size: 20, color: cs.onSurfaceVariant),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Data',
                      style: textTheme.titleSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Manage data and backups',
                      style: textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
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
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.backup, color: cs.onSurfaceVariant),
                  title: const Text('Backup Progress'),
                  onTap: () => _handleBackup(context, cs, textTheme),
                ),
                ListTile(
                  leading: Icon(Icons.restore, color: cs.onSurfaceVariant),
                  title: const Text('Restore Backup'),
                  onTap: () => _handleRestore(context, cs, textTheme),
                ),
                ListTile(
                  leading: Icon(
                    Icons.cleaning_services_outlined,
                    color: cs.onSurfaceVariant,
                  ),
                  title: const Text('Clear Cache'),
                  subtitle: Text(
                    'Clear cached book covers and temporary data',
                    style: textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  onTap: () => _handleClearCache(context, ref),
                ),
                const Divider(indent: 16, endIndent: 16, thickness: 0.5),
                ListTile(
                  leading: Icon(Icons.info_outline, color: cs.onSurfaceVariant),
                  title: const Text('About BookVerse'),
                  onTap: () => _handleAbout(context, cs, textTheme),
                ),
              ],
            ),
          ),
        ),
        const Divider(),
      ],
    );
  }

  Future<void> _handleClearCache(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text(
          'This will clear cached book covers and temporary data. '
          'Your reading progress will not be affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    ref.read(bookCacheProvider.notifier).state = {};
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cache cleared'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleAbout(
    BuildContext context,
    ColorScheme cs,
    TextTheme textTheme,
  ) async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.auto_stories, color: cs.primary, size: 28),
            const SizedBox(width: 12),
            const Text('BookVerse'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Version 1.0.0',
              style: textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            const Text('Track your reading journey.'),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {},
              child: Text(
                'GitHub Repository',
                style: textTheme.bodyMedium?.copyWith(
                  color: cs.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
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

  Future<void> _handleBackup(
    BuildContext context,
    ColorScheme cs,
    TextTheme textTheme,
  ) async {
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
    if (confirmed != true || !context.mounted) return;

    try {
      final path = await BackupService.instance.backupProgress();
      if (!context.mounted) return;
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 28),
              const SizedBox(width: 12),
              const Expanded(child: Text('Backup Complete')),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Your reading progress has been exported.'),
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
                  style: textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
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
                  const SnackBar(content: Text('Path copied to clipboard')),
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
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Backup failed: $e')));
      }
    }
  }

  Future<void> _handleRestore(
    BuildContext context,
    ColorScheme cs,
    TextTheme textTheme,
  ) async {
    final exists = await BackupService.instance.hasBackup();
    if (!exists && context.mounted) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('No Backup'),
          content: const Text('No backup file found. Create a backup first.'),
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
    if (confirmed != true || !context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final result = await BackupService.instance.restoreProgress();
      if (!context.mounted) return;
      Navigator.of(context).pop();
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
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
              Text('Previous data saved to:', style: textTheme.bodySmall),
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
                  style: textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: result.snapshotPath));
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Snapshot path copied to clipboard'),
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
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        final code = e is RestoreException ? e.code : RestoreErrorCode.unknown;
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
                    Text(detail, style: TextStyle(color: cs.onSurfaceVariant)),
                  ],
                  const SizedBox(height: 12),
                  ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    title: Text('How to fix this', style: textTheme.titleSmall),
                    children: [
                      for (final tip in _tipsFor(code))
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('• ', style: TextStyle(color: cs.primary)),
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
}

List<String> _tipsFor(RestoreErrorCode code) {
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
