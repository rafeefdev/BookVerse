import 'dart:developer';
import 'package:book_verse/core/models/book_model.dart';
import 'package:book_verse/core/shared/components/bookdetailinfo_component.dart';
import 'package:book_verse/core/shared/components/icontext_horizontal_component.dart';
import 'package:book_verse/core/shared/helpers/helper/book_authors.dart';
import 'package:book_verse/core/shared/helpers/helper/book_categories.dart';
import 'package:book_verse/core/shared/helpers/helper/book_description.dart';
import 'package:book_verse/core/shared/helpers/helper/book_publishdate.dart';
import 'package:book_verse/core/shared/helpers/helper/book_title.dart';
import 'package:book_verse/core/shared/themes_extension.dart';
import 'package:book_verse/features/bookmarks/viewmodel/bookmark_viewmodel.dart';
import 'package:book_verse/features/library/model/library_folder_model.dart';
import 'package:book_verse/features/library/model/library_folder_service.dart';
import 'package:book_verse/features/library/model/library_repo.dart';
import 'package:book_verse/features/library/model/library_repo_di.dart';
import 'package:book_verse/features/library/viewmodel/library_viewmodel.dart';
import 'package:book_verse/features/reading_tracker/model/reading_progress_model.dart';
import 'package:book_verse/features/reading_tracker/viewmodel/reading_tracker_viewmodel.dart';
import 'package:book_verse/features/search/viewmodel/search_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final bookCacheProvider = StateProvider<Map<String, Book>>((ref) => {});

extension IterableExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}

class DetailPage extends ConsumerWidget {
  final String selectedBookId;
  final bool isTemporarySource;

  const DetailPage({
    required this.selectedBookId,
    super.key,
    required this.isTemporarySource,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isTemporarySource) {
      final searchBookResult = ref.watch(searchNotifierProvider).result;
      return _buildDetailPage(
        context,
        books: searchBookResult,
        selectedBookId: selectedBookId,
        ref: ref,
      );
    } else {
      final bookmarkedItems = ref.watch(bookmarkNotifierProvider);
      return bookmarkedItems.when(
        data: (bookProgressList) {
          final ReadingProgressModel? progress = bookProgressList
              .firstWhereOrNull((p) => p.bookId == selectedBookId);
          final Book? book = progress?.book;

          if (book != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref
                  .read(bookCacheProvider.notifier)
                  .update((state) => {...state, book.id: book});
            });
            return _buildDetailPage(
              context,
              book: book,
              selectedBookId: selectedBookId,
              ref: ref,
            );
          }

          final cachedBook = ref.read(bookCacheProvider)[selectedBookId];
          if (cachedBook != null) {
            return _buildDetailPage(
              context,
              book: cachedBook,
              selectedBookId: selectedBookId,
              ref: ref,
            );
          }

          return Scaffold(
            appBar: AppBar(
              title: Text('Detail', style: context.textTheme.titleLarge),
            ),
            body: const Center(child: Text('Book not found')),
          );
        },
        error: (err, stack) => Scaffold(
          appBar: AppBar(
            title: Text('Detail', style: context.textTheme.titleLarge),
          ),
          body: Center(child: Text('Error Occured : $err\n$stack')),
        ),
        loading: () => Scaffold(
          appBar: AppBar(
            title: Text('Detail', style: context.textTheme.titleLarge),
          ),
          body: const Center(child: CircularProgressIndicator()),
        ),
      );
    }
  }

  Widget _buildDetailPage(
    BuildContext context, {
    List<Book>? books,
    Book? book,
    required String selectedBookId,
    required WidgetRef ref,
  }) {
    final scheme = context.colorScheme;
    Book selectedBook;
    if (book != null) {
      selectedBook = book;
    } else {
      if (books == null) {
        return Scaffold(
          appBar: AppBar(title: const Text('Detail')),
          body: const Center(child: Text('Book data not available')),
        );
      }
      int index = books.indexWhere((book) => book.id == selectedBookId);
      if (index == -1) {
        return Scaffold(
          appBar: AppBar(title: const Text('Detail')),
          body: const Center(child: Text('Book not found')),
        );
      }
      selectedBook = books[index];
    }

    log('''
selectedBookId : $selectedBookId\nauthors count : ${selectedBook.authors.length}
\ntitle count : ${selectedBook.title.characters.length},''', level: 2);
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail', style: context.textTheme.titleLarge),
        actions: [
          LibraryActionButton(selectedBook: selectedBook),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: 28,
            right: 28,
            top: 12,
            bottom: 28,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: 216,
                  child: bookThumbnail(selectedBook, scheme),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.start,
                verticalDirection: VerticalDirection.down,
                runSpacing: 8,
                children: [
                  Text(
                    bookTitle(selectedBook.title, 60),
                    softWrap: true,
                    style: context.textTheme.titleLarge,
                  ),
                  Text(
                    (selectedBook.subTitle != null &&
                            selectedBook.subTitle!.isNotEmpty)
                        ? selectedBook.subTitle!
                        : 'Description is not available',
                    style: context.textTheme.titleSmall,
                  ),
                  iconWithTextHorizontal(
                    context,
                    selectedBook,
                    icon: Icons.person_2,
                    text: bookAuthors(selectedBook),
                  ),
                  iconWithTextHorizontal(
                    context,
                    selectedBook,
                    icon: Icons.file_copy_rounded,
                    text: bookCategories(selectedBook),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  bookDetailInfoTile(
                    context,
                    title: 'Published Date',
                    data: bookPublishDate(selectedBook.publishedDate),
                    icon: Icons.calendar_month_rounded,
                  ),
                  bookDetailInfoTile(
                    context,
                    title: 'Page Count',
                    data: selectedBook.pageCount.toString(),
                    icon: Icons.menu_book_rounded,
                  ),
                  bookDetailInfoTile(
                    context,
                    data: selectedBook.publisher,
                    icon: Icons.print_rounded,
                    dataMaxLines: 1,
                    title: 'Publisher',
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _ReadingProgressSection(book: selectedBook),
              const SizedBox(height: 24),
              ..._buildDescription(
                context,
                sanitizeDescription(selectedBook.description),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDescription(BuildContext context, String description) {
    log(
      '[_buildDescription] called with: "${description.length > 100 ? "${description.substring(0, 100)}..." : description}"',
    );
    log('[_buildDescription] length: ${description.length}');

    if (description == "No Description") {
      log('[_buildDescription] → fallback No Description');
      return [
        Text(
          description,
          style: context.textTheme.bodyMedium?.copyWith(
            fontStyle: FontStyle.italic,
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ];
    }

    final paragraphs = description
        .split(RegExp(r'\n\n'))
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();

    log('[_buildDescription] paragraphs count: ${paragraphs.length}');
    for (int i = 0; i < paragraphs.length && i < 3; i++) {
      log(
        '[_buildDescription] paragraph[$i]: "${paragraphs[i].length > 80 ? "${paragraphs[i].substring(0, 80)}..." : paragraphs[i]}"',
      );
    }

    if (paragraphs.isEmpty) {
      log('[_buildDescription] → fallback (empty after split)');
      return [
        Text(
          "No Description",
          style: context.textTheme.bodyMedium?.copyWith(
            fontStyle: FontStyle.italic,
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ];
    }

    final widgets = <Widget>[];
    for (int i = 0; i < paragraphs.length; i++) {
      widgets.add(
        SelectableText(paragraphs[i], style: context.textTheme.bodyMedium),
      );
      if (i < paragraphs.length - 1) {
        widgets.add(const SizedBox(height: 12));
      }
    }
    log('[_buildDescription] → returning ${widgets.length} widgets');
    return widgets;
  }
}

class _ReadingProgressSection extends ConsumerWidget {
  final Book book;

  const _ReadingProgressSection({required this.book});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarkAsync = ref.watch(bookmarkNotifierProvider);
    final readingProgress = bookmarkAsync.valueOrNull?.firstWhereOrNull(
      (p) => p.bookId == book.id,
    );
    final isBookmarked = readingProgress != null;
    final textTheme = context.textTheme;
    final scheme = context.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your Reading Progress', style: textTheme.titleLarge),
        const SizedBox(height: 8),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          crossFadeState: isBookmarked
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: _SaveToLibraryCTA(book: book),
          secondChild: _ProgressContent(
            book: book,
            readingProgress: readingProgress,
            textTheme: textTheme,
            scheme: scheme,
          ),
        ),
      ],
    );
  }
}

class _SaveToLibraryCTA extends ConsumerWidget {
  final Book book;

  const _SaveToLibraryCTA({required this.book});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = context.colorScheme;
    final textTheme = context.textTheme;

    return Card(
      color: scheme.surfaceContainerHighest,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          await ref
              .read(bookmarkNotifierProvider.notifier)
              .toggleBookmark(book);
          ref.invalidate(bookmarkNotifierProvider);
          if (context.mounted) {
            _showSetCurrentPageSheet(context, ref, book);
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Row(
            children: [
              Icon(Icons.library_add_outlined, color: scheme.primary, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Save to My Library',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Track your reading progress',
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: scheme.onSurfaceVariant,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressContent extends StatelessWidget {
  final Book book;
  final ReadingProgressModel? readingProgress;
  final TextTheme textTheme;
  final ColorScheme scheme;

  const _ProgressContent({
    required this.book,
    required this.readingProgress,
    required this.textTheme,
    required this.scheme,
  });

  @override
  Widget build(BuildContext context) {
    final hasStarted = (readingProgress?.currentPage ?? 0) > 0;
    final progressValue = hasStarted && book.pageCount > 0
        ? readingProgress!.currentPage / book.pageCount
        : 0.0;

    return Column(
      children: [
        if (hasStarted) ...[
          LinearProgressIndicator(
            value: progressValue,
            backgroundColor: scheme.surfaceContainerHighest,
            color: scheme.primary,
            minHeight: 10,
            borderRadius: BorderRadius.circular(5),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${readingProgress!.currentPage} / ${book.pageCount} pages',
                style: textTheme.bodyLarge,
              ),
              Text(
                '${(progressValue * 100).toStringAsFixed(1)}%',
                style: textTheme.bodyLarge,
              ),
            ],
          ),
          const SizedBox(height: 16),
        ] else ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'Not started',
                style: textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              context.push('/record-session/${book.id}');
            },
            icon: const Icon(Icons.timer),
            label: const Text('Record New Session'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () => showLibrarySheet(context, book),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Manage in Library',
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: scheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

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
    builder: (sheetContext) {
      var saved = isBookmarked;
      var selectedFolderIds = folderIdsForBook.toSet();
      var currentStep = _SheetStep.list;
      return StatefulBuilder(
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
                LibraryFolderService.defaultFolderId,
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
                      LibraryFolderService.defaultFolderId,
                    )
                    ? FontWeight.bold
                    : null,
              ),
            ),
            subtitle: const Text('Default location'),
            value: selectedFolderIds.contains(
              LibraryFolderService.defaultFolderId,
            ),
            onChanged: (checked) async {
              if (checked == true) {
                await repo.removeBookFromAllFolders(book.id);
                await repo.addBookToFolder(
                  LibraryFolderService.defaultFolderId,
                  book.id,
                );
                onSelectedFolderIdsChanged({
                  LibraryFolderService.defaultFolderId,
                });
              } else {
                await repo.removeBookFromFolder(
                  LibraryFolderService.defaultFolderId,
                  book.id,
                );
                final updated = Set<String>.from(selectedFolderIds)
                  ..remove(LibraryFolderService.defaultFolderId);
                onSelectedFolderIdsChanged(updated);
              }
              container.invalidate(libraryNotifierProvider);
              setSheetState(() {});
            },
          ),
          ...folders
              .where((f) => f.id != LibraryFolderService.defaultFolderId)
              .map(
                (folder) => CheckboxListTile(
                  title: Text(folder.name),
                  subtitle: Text('${folder.bookCount} books'),
                  value: selectedFolderIds.contains(folder.id),
                  onChanged: (checked) async {
                    if (checked == true) {
                      await repo.addBookToFolder(folder.id, book.id);
                      await repo.removeBookFromFolder(
                        LibraryFolderService.defaultFolderId,
                        book.id,
                      );
                      final updated = Set<String>.from(selectedFolderIds)
                        ..remove(LibraryFolderService.defaultFolderId)
                        ..add(folder.id);
                      onSelectedFolderIdsChanged(updated);
                    } else {
                      await repo.removeBookFromFolder(folder.id, book.id);
                      final updated = Set<String>.from(selectedFolderIds)
                        ..remove(folder.id);
                      if (updated.isEmpty) {
                        await repo.addBookToFolder(
                          LibraryFolderService.defaultFolderId,
                          book.id,
                        );
                        updated.add(LibraryFolderService.defaultFolderId);
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

void _showSetCurrentPageSheet(BuildContext context, WidgetRef ref, Book book) {
  final scheme = Theme.of(context).colorScheme;
  final textTheme = Theme.of(context).textTheme;
  final controller = TextEditingController();

  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
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
      );
    },
  ).whenComplete(() => controller.dispose());
}

Widget bookThumbnail(Book selectedBook, ColorScheme colorScheme) {
  return selectedBook.thumbnail.isEmpty
      ? AspectRatio(
          aspectRatio: 3 / 4,
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colorScheme.outlineVariant,
                width: 0.05,
              ),
            ),
            child: const Icon(Icons.print, size: 35),
          ),
        )
      : AspectRatio(
          aspectRatio: 3 / 4,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              border: const Border(
                top: BorderSide(color: Colors.white, width: 0.2),
                bottom: BorderSide(color: Colors.white, width: 0.2),
                left: BorderSide(color: Colors.white, width: 0.2),
                right: BorderSide(color: Colors.white, width: 0.2),
              ),
              image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(selectedBook.thumbnail),
              ),
            ),
          ),
        );
}
