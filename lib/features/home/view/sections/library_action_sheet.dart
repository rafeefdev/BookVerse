import 'package:book_verse/core/models/book_model.dart';
import 'package:book_verse/features/bookmarks/viewmodel/bookmark_viewmodel.dart';
import 'package:book_verse/features/library/model/library_folder_model.dart';
import 'package:book_verse/core/database/database_constants.dart';
import 'package:book_verse/features/library/model/library_repo.dart';
import 'package:book_verse/features/library/model/library_repo_di.dart';
import 'package:book_verse/features/library/viewmodel/library_viewmodel.dart';
import 'package:book_verse/features/reading_tracker/viewmodel/reading_tracker_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LibraryActionButton extends ConsumerWidget {
  const LibraryActionButton({super.key, required this.selectedBook});

  final Book selectedBook;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.library_add_outlined),
      tooltip: 'Library actions',
      onPressed: () => showLibrarySheet(context, selectedBook),
    );
  }
}

enum _SheetStep { list, create }
enum _LibMutation { save, remove }

Future<void> _coordinateLibraryMutation({
  required ProviderContainer container,
  required LibraryRepo repo,
  required Book book,
  required _LibMutation type,
}) async {
  switch (type) {
    case _LibMutation.save:
      await repo.saveBook(book);
      break;
    case _LibMutation.remove:
      await repo.removeBookmark(book.id);
      await repo.removeBookFromAllFolders(book.id);
      break;
  }
  container.invalidate(libraryNotifierProvider);
  container.invalidate(bookmarkNotifierProvider);
}

Future<void> showLibrarySheet(BuildContext context, Book book) async {
  final container = ProviderScope.containerOf(context);
  final bookmarkNotifier = container.read(bookmarkNotifierProvider.notifier);
  final isBookmarked = bookmarkNotifier.isBookmarked(book.id);
  final repo = container.read(libraryRepoProvider);
  var folders = await repo.getAllFolders();
  final folderIdsForBook = await repo.getFolderIdsForBook(book.id);

  if (!context.mounted) return;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) {
      var saved = isBookmarked;
      var selectedFolderIds = folderIdsForBook.toSet();
      var currentStep = _SheetStep.list;
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              switch (currentStep) {
                case _SheetStep.list:
                  return _SheetListView(
                saved: saved,
                selectedFolderIds: selectedFolderIds,
                folders: folders,
                book: book,
                repo: repo,
                container: container,
                onSavedChanged: (v) => saved = v,
                onSelectedFolderIdsChanged: (v) => selectedFolderIds = v,
                onFoldersChanged: (v) => folders = v,
                onNavigateToCreate: () {
                  setSheetState(() => currentStep = _SheetStep.create);
                },
                setSheetState: setSheetState,
              );
            case _SheetStep.create:
              return _CreateFolderView(
                book: book,
                repo: repo,
                container: container,
                onCreated: (updatedFolders) {
                  folders = updatedFolders;
                  currentStep = _SheetStep.list;
                },
                onCancel: () {
                  currentStep = _SheetStep.list;
                },
                setSheetState: setSheetState,
              );
          }
        },
      ),
        ),
      );
    },
  );
}

class _SheetListView extends StatelessWidget {
  final bool saved;
  final Set<String> selectedFolderIds;
  final List<LibraryFolder> folders;
  final Book book;
  final LibraryRepo repo;
  final ProviderContainer container;
  final ValueChanged<bool> onSavedChanged;
  final ValueChanged<Set<String>> onSelectedFolderIdsChanged;
  final ValueChanged<List<LibraryFolder>> onFoldersChanged;
  final VoidCallback onNavigateToCreate;
  final void Function(VoidCallback) setSheetState;

  const _SheetListView({
    required this.saved,
    required this.selectedFolderIds,
    required this.folders,
    required this.book,
    required this.repo,
    required this.container,
    required this.onSavedChanged,
    required this.onSelectedFolderIdsChanged,
    required this.onFoldersChanged,
    required this.onNavigateToCreate,
    required this.setSheetState,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(
            children: [
              Icon(
                Icons.library_add_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text('Library', style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
        SwitchListTile(
          title: const Text('Save to Library'),
          subtitle: Text(saved ? 'Saved' : 'Not saved'),
          value: saved,
          onChanged: (value) async {
            if (value == false) {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Remove from Library?'),
                  content: Text(
                    'Your reading progress and session history for '
                    '"${book.title}" will be deleted.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                      child: const Text('Remove'),
                    ),
                  ],
                ),
              );
              if (confirmed != true) return;
            }
            if (value && selectedFolderIds.isEmpty) {
              onSelectedFolderIdsChanged({
                ...selectedFolderIds,
                defaultFolderId,
              });
            }
            await _coordinateLibraryMutation(
              container: container,
              repo: repo,
              book: book,
              type: value ? _LibMutation.save : _LibMutation.remove,
            );
            onSavedChanged(value);
            setSheetState(() {});
          },
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                'Move to Folder',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.create_new_folder_outlined, size: 20),
                tooltip: 'Create new folder',
                onPressed: onNavigateToCreate,
              ),
            ],
          ),
        ),
        if (saved) ...[
          CheckboxListTile(
            title: Text(
              'Tanpa Folder',
              style: TextStyle(
                fontWeight:
                    selectedFolderIds.contains(
                      defaultFolderId,
                    )
                    ? FontWeight.bold
                    : null,
              ),
            ),
            subtitle: const Text('Default location'),
            value: selectedFolderIds.contains(
              defaultFolderId,
            ),
            onChanged: (checked) async {
              if (checked == true) {
                await repo.removeBookFromAllFolders(book.id);
                await repo.addBookToFolder(
                  defaultFolderId,
                  book.id,
                );
                onSelectedFolderIdsChanged({
                  defaultFolderId,
                });
              } else {
                await repo.removeBookFromFolder(
                  defaultFolderId,
                  book.id,
                );
                final updated = Set<String>.from(selectedFolderIds)
                  ..remove(defaultFolderId);
                onSelectedFolderIdsChanged(updated);
              }
              container.invalidate(libraryNotifierProvider);
              setSheetState(() {});
            },
          ),
          ...folders
              .where((f) => f.id != defaultFolderId)
              .map(
                (folder) => CheckboxListTile(
                  title: Text(folder.name),
                  subtitle: Text('${folder.bookCount} books'),
                  value: selectedFolderIds.contains(folder.id),
                  onChanged: (checked) async {
                    if (checked == true) {
                      await repo.addBookToFolder(folder.id, book.id);
                      await repo.removeBookFromFolder(
                        defaultFolderId,
                        book.id,
                      );
                      final updated = Set<String>.from(selectedFolderIds)
                        ..remove(defaultFolderId)
                        ..add(folder.id);
                      onSelectedFolderIdsChanged(updated);
                    } else {
                      await repo.removeBookFromFolder(folder.id, book.id);
                      final updated = Set<String>.from(selectedFolderIds)
                        ..remove(folder.id);
                      if (updated.isEmpty) {
                        await repo.addBookToFolder(
                          defaultFolderId,
                          book.id,
                        );
                        updated.add(defaultFolderId);
                      }
                      onSelectedFolderIdsChanged(updated);
                    }
                    container.invalidate(libraryNotifierProvider);
                    setSheetState(() {});
                  },
                ),
              ),
        ] else
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Save the book to library first to organize into folders.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _CreateFolderView extends StatefulWidget {
  final Book book;
  final LibraryRepo repo;
  final ProviderContainer container;
  final void Function(List<LibraryFolder>) onCreated;
  final VoidCallback onCancel;
  final void Function(VoidCallback) setSheetState;

  const _CreateFolderView({
    required this.book,
    required this.repo,
    required this.container,
    required this.onCreated,
    required this.onCancel,
    required this.setSheetState,
  });

  @override
  State<_CreateFolderView> createState() => _CreateFolderViewState();
}

class _CreateFolderViewState extends State<_CreateFolderView> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _create() async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    try {
      final newFolder = LibraryFolder(
        id: LibraryFolder.generateId(),
        name: name,
        createdAt: DateTime.now(),
      );
      await widget.repo.createFolder(newFolder);
      final updatedFolders = await widget.repo.getAllFolders();
      widget.container.invalidate(libraryNotifierProvider);
      widget.setSheetState(() => widget.onCreated(updatedFolders));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to create folder: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => widget.setSheetState(widget.onCancel),
              ),
              const SizedBox(width: 8),
              Text(
                'New Folder',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: TextField(
            controller: _controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              hintText: 'Folder name',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => _create(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => widget.setSheetState(widget.onCancel),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 12),
              FilledButton(onPressed: _create, child: const Text('Create')),
            ],
          ),
        ),
      ],
    );
  }
}

void showSetCurrentPageSheet(BuildContext context, WidgetRef ref, Book book) {
  final scheme = Theme.of(context).colorScheme;
  final textTheme = Theme.of(context).textTheme;
  final controller = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 12,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Icon(Icons.info_outline, color: scheme.primary, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('Book Saved!', style: textTheme.titleLarge),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Have you already started reading this book? '
                'Enter the page you\'re on.',
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Current page (optional)',
                  border: const OutlineInputBorder(),
                  suffixText: 'pages',
                  suffixStyle: TextStyle(color: scheme.onSurfaceVariant),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    final text = controller.text.trim();
                    final page = int.tryParse(text);
                    if (text.isNotEmpty && (page == null || page < 1)) {
                      ScaffoldMessenger.of(sheetContext).showSnackBar(
                        SnackBar(
                          content: const Text('Please enter a valid page number'),
                          backgroundColor: scheme.error,
                        ),
                      );
                      return;
                    }
                    if (page != null && page > 0) {
                      final tracker = ref.read(
                        readingTrackerNotifierProvider(book.id).notifier,
                      );
                      await ref.read(
                        readingTrackerNotifierProvider(book.id).future,
                      );
                      await tracker.updateReadingProgress(page);
                    }
                    if (sheetContext.mounted) {
                      Navigator.of(sheetContext).pop();
                    }
                  },
                  child: const Text('Done'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  child: const Text('Skip'),
                ),
              ),
            ],
          ),
        ),
      );
    },
  ).whenComplete(() => controller.dispose());
}
