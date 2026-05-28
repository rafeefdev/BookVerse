import 'dart:developer';
import 'package:book_verse/core/models/book_model.dart';
import 'package:book_verse/core/shared/components/bookdetailinfo_component.dart';
import 'package:book_verse/core/shared/components/icontext_horizontal_component.dart';
import 'package:book_verse/core/shared/helpers/helper/book_authors.dart';
import 'package:book_verse/core/shared/helpers/helper/book_categories.dart';
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
import 'package:book_verse/features/search/viewmodel/search_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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

          if (book == null) {
            return Scaffold(
              appBar: AppBar(
                title: Text('Detail', style: context.textTheme.titleLarge),
              ),
              body: const Center(child: Text('Book not found')),
            );
          }

          return _buildDetailPage(
            context,
            book: book,
            selectedBookId: selectedBookId,
            ref: ref,
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
              Text(
                selectedBook.description,
                style: context.textTheme.bodyMedium,
                textAlign: TextAlign.justify,
              ),
            ],
          ),
        ),
      ),
    );
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
      var folderName = '';
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
                  folderName = '';
                  setSheetState(() => currentStep = _SheetStep.create);
                },
                setSheetState: setSheetState,
              );
            case _SheetStep.create:
              return _CreateFolderView(
                folderName: folderName,
                onFolderNameChanged: (v) => folderName = v,
                book: book,
                repo: repo,
                container: container,
                onCreated: (updatedFolders) {
                  folders = updatedFolders;
                  currentStep = _SheetStep.list;
                  folderName = '';
                },
                onCancel: () {
                  currentStep = _SheetStep.list;
                  folderName = '';
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

class _CreateFolderView extends StatelessWidget {
  final String folderName;
  final ValueChanged<String> onFolderNameChanged;
  final Book book;
  final LibraryRepo repo;
  final ProviderContainer container;
  final void Function(List<LibraryFolder>) onCreated;
  final VoidCallback onCancel;
  final void Function(VoidCallback) setSheetState;

  const _CreateFolderView({
    required this.folderName,
    required this.onFolderNameChanged,
    required this.book,
    required this.repo,
    required this.container,
    required this.onCreated,
    required this.onCancel,
    required this.setSheetState,
  });

  void _create(BuildContext context) async {
    final name = folderName.trim();
    if (name.isEmpty) return;
    try {
      final newFolder = LibraryFolder(
        id: LibraryFolder.generateId(),
        name: name,
        createdAt: DateTime.now(),
      );
      await repo.createFolder(newFolder);
      final updatedFolders = await repo.getAllFolders();
      container.invalidate(libraryNotifierProvider);
      setSheetState(() => onCreated(updatedFolders));
    } catch (e) {
      if (context.mounted) {
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
                onPressed: () => setSheetState(onCancel),
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
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              hintText: 'Folder name',
              border: OutlineInputBorder(),
            ),
            onChanged: onFolderNameChanged,
            onSubmitted: (_) => _create(context),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => setSheetState(onCancel),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 12),
              FilledButton(
                onPressed: () => _create(context),
                child: const Text('Create'),
              ),
            ],
          ),
        ),
      ],
    );
  }
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
