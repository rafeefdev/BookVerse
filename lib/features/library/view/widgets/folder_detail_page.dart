import 'package:book_verse/core/shared/components/booklisttile_component.dart';
import 'package:book_verse/core/theme/themes_extension.dart';
import 'package:book_verse/features/library/model/library_folder_model.dart';
import 'package:book_verse/features/library/view/widgets/create_folder_dialog.dart';
import 'package:book_verse/features/library/viewmodel/library_viewmodel.dart';
import 'package:book_verse/features/reading_tracker/model/reading_progress_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FolderDetailPage extends ConsumerWidget {
  final String folderId;

  const FolderDetailPage({super.key, required this.folderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libraryAsync = ref.watch(libraryNotifierProvider);

    return libraryAsync.when(
      data: (state) {
        final folder = state.folders.firstWhere(
          (f) => f.id == folderId,
          orElse: () =>
              LibraryFolder(id: '', name: 'Unknown', createdAt: DateTime.now()),
        );

        return Scaffold(
          appBar: AppBar(
            title: Text(folder.name, style: context.textTheme.titleLarge),
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'rename') {
                    final newName = await showDialog<String>(
                      context: context,
                      builder: (_) =>
                          CreateFolderDialog(initialName: folder.name),
                    );
                    if (newName != null && newName.isNotEmpty) {
                      ref
                          .read(libraryNotifierProvider.notifier)
                          .renameFolder(folderId, newName);
                    }
                  } else if (value == 'delete') {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: const Text('Delete Folder'),
                        content: Text(
                          'Delete "${folder.name}"? Books inside will not be deleted.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(dialogContext, false),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(dialogContext, true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      try {
                        await ref
                            .read(libraryNotifierProvider.notifier)
                            .deleteFolder(folderId);
                        if (context.mounted) context.pop();
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to delete folder: $e'),
                            ),
                          );
                        }
                      }
                    }
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'rename', child: Text('Rename')),
                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
          ),
          body: SafeArea(
            top: false,
            bottom: true,
            child: _buildBookList(ref, folderId),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Folder')),
        body: const SafeArea(
          top: false,
          bottom: true,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (err, _) => Scaffold(
        appBar: AppBar(title: const Text('Folder')),
        body: SafeArea(
          top: false,
          bottom: true,
          child: Center(child: Text('Error: $err')),
        ),
      ),
    );
  }

  Widget _buildBookList(WidgetRef ref, String folderId) {
    return FutureBuilder<List>(
      future: ref
          .read(libraryNotifierProvider.notifier)
          .getBooksInFolder(folderId),
      builder: (context, snapshot) {
        final scheme = Theme.of(context).colorScheme;
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final books = snapshot.data ?? [];
        if (books.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_open, size: 64, color: scheme.outlineVariant),
                const SizedBox(height: 16),
                Text(
                  'Folder is empty',
                  style: TextStyle(
                    fontSize: 16,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }
        return _BookListWithProgress(books: books);
      },
    );
  }
}

class _BookListWithProgress extends ConsumerWidget {
  final List books;

  const _BookListWithProgress({required this.books});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(libraryNotifierProvider);
    return progressAsync.when(
      data: (state) {
        final allProgress = [...state.currentlyReading, ...state.finished];
        final progressMap = <String, ReadingProgressModel>{};
        for (final p in allProgress) {
          progressMap[p.bookId] = p;
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: books.length,
          itemBuilder: (context, index) {
            final book = books[index];
            final progress = progressMap[book.id];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: bookListTile(
                context,
                book,
                isWrappedByCard: true,
                isTemporarySource: false,
                readingProgress: progress,
                onTap: () {
                  context.push('/detail/${book.id}');
                },
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
    );
  }
}
