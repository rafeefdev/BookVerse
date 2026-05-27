import 'package:book_verse/core/shared/themes_extension.dart';
import 'package:book_verse/features/library/model/library_folder_model.dart';
import 'package:book_verse/features/library/model/library_state.dart';
import 'package:book_verse/features/library/view/widgets/create_folder_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SavedTab extends StatelessWidget {
  final LibraryState state;
  final void Function(String name) onCreateFolder;

  const SavedTab({
    super.key,
    required this.state,
    required this.onCreateFolder,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Folders', style: context.textTheme.titleMedium),
              IconButton(
                icon: const Icon(Icons.create_new_folder),
                onPressed: () => _showCreateDialog(context),
                tooltip: 'Create folder',
              ),
            ],
          ),
        ),
        if (state.folders.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Text(
              'No folders yet. Tap + to create one.',
              style: TextStyle(color: scheme.outline),
            ),
          )
        else
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: state.folders.length,
              itemBuilder: (context, index) {
                final folder = state.folders[index];
                return _FolderCard(folder: folder);
              },
            ),
          ),
      ],
    );
  }

  void _showCreateDialog(BuildContext context) {
    showDialog<String>(
      context: context,
      builder: (_) => const CreateFolderDialog(),
    ).then((name) {
      if (name != null && name.isNotEmpty) {
        onCreateFolder(name);
      }
    });
  }
}

class _FolderCard extends StatelessWidget {
  final LibraryFolder folder;

  const _FolderCard({required this.folder});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () {
        context.push('/library/folder/${folder.id}');
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder, size: 40, color: scheme.primary),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                folder.name,
                style: context.textTheme.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '${folder.bookCount} books',
              style: context.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
