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
import 'package:book_verse/features/library/model/library_folder_service.dart';
import 'package:book_verse/features/library/model/library_repo_di.dart';
import 'package:book_verse/features/reading_tracker/model/reading_progress_model.dart';
import 'package:book_verse/features/search/viewmodel/search_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Extension to provide firstWhereOrNull functionality
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
    final searchBookResult = ref.watch(searchNotifierProvider).result;
    final bookmarkedItems = ref.watch(bookmarkNotifierProvider);

    if (isTemporarySource) {
      // For temporary source, we don't have reading progress, just display book details
      return _buildDetailPage(
        context,
        books: searchBookResult,
        selectedBookId: selectedBookId,
        ref: ref,
      );
    } else {
      // For bookmarked items, we have reading progress
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
            readingProgress: progress,
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
    List<Book>? books, // Only used for isTemporarySource
    Book? book, // Directly passed for non-temporary sources
    required String selectedBookId,
    required WidgetRef ref,
    ReadingProgressModel? readingProgress, // Passed for non-temporary sources
  }) {
    Book selectedBook;
    if (book != null) {
      selectedBook = book;
    } else {
      // Logic for isTemporarySource
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

    log(
      '''selectedBookId : $selectedBookId\nauthors count : ${selectedBook.authors.length}
      \ntitle count : ${selectedBook.title.characters.length},''',
      level: 2,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail', style: context.textTheme.titleLarge),
        actions: [
          LibraryActionButton(selectedBook: selectedBook),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
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
              child: SizedBox(width: 216, child: bookThumbnail(selectedBook)),
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
            if (readingProgress != null && !isTemporarySource) ...[
              Text(
                'Your Reading Progress',
                style: context.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: selectedBook.pageCount > 0
                    ? readingProgress.currentPage / selectedBook.pageCount
                    : 0.0,
                backgroundColor: Colors.grey[300],
                color: context.colorScheme.primary,
                minHeight: 10,
                borderRadius: BorderRadius.circular(5),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${readingProgress.currentPage} / ${selectedBook.pageCount} pages',
                    style: context.textTheme.bodyLarge,
                  ),
                  Text(
                    '${((selectedBook.pageCount > 0 ? readingProgress.currentPage / selectedBook.pageCount : 0.0) * 100).toStringAsFixed(1)}%',
                    style: context.textTheme.bodyLarge,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.push('/record-session/${selectedBook.id}');
                  },
                  icon: const Icon(Icons.timer),
                  label: const Text('Record New Session'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
            Text(
              selectedBook.description,
              style: context.textTheme.bodyMedium,
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
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
      onPressed: () => _showLibrarySheet(context, ref),
    );
  }

  Future<void> _showLibrarySheet(BuildContext context, WidgetRef ref) async {
    final bookmarkNotifier = ref.read(bookmarkNotifierProvider.notifier);
    final isBookmarked = bookmarkNotifier.isBookmarked(selectedBook.id);
    final repo = ref.read(libraryRepoProvider);
    final folders = await repo.getAllFolders();
    final folderIdsForBook = await repo.getFolderIdsForBook(selectedBook.id);

    if (!context.mounted) return;

    await showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            var saved = isBookmarked;
            var selectedFolderIds = folderIdsForBook.toSet();

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
                      Text(
                        'Library',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
                SwitchListTile(
                  title: const Text('Save to Library'),
                  subtitle: Text(saved ? 'Saved' : 'Not saved'),
                  value: saved,
                  onChanged: (value) async {
                    if (value) {
                      await repo.saveBook(selectedBook);
                      if (selectedFolderIds.isEmpty) {
                        selectedFolderIds.add(
                          LibraryFolderService.defaultFolderId,
                        );
                      }
                    } else {
                      await repo.removeBookmark(selectedBook.id);
                      await repo.removeBookFromAllFolders(selectedBook.id);
                      selectedFolderIds.clear();
                    }
                    saved = value;
                    setSheetState(() {});
                  },
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Move to Folder',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
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
                        await repo.removeBookFromAllFolders(selectedBook.id);
                        await repo.addBookToFolder(
                          LibraryFolderService.defaultFolderId,
                          selectedBook.id,
                        );
                        selectedFolderIds
                          ..clear()
                          ..add(LibraryFolderService.defaultFolderId);
                      }
                      setSheetState(() {});
                    },
                  ),
                  ...folders
                      .where(
                        (f) => f.id != LibraryFolderService.defaultFolderId,
                      )
                      .map(
                        (folder) => CheckboxListTile(
                          title: Text(folder.name),
                          subtitle: Text('${folder.bookCount} books'),
                          value: selectedFolderIds.contains(folder.id),
                          onChanged: (checked) async {
                            if (checked == true) {
                              await repo.addBookToFolder(
                                folder.id,
                                selectedBook.id,
                              );
                              selectedFolderIds.remove(
                                LibraryFolderService.defaultFolderId,
                              );
                              selectedFolderIds.add(folder.id);
                            } else {
                              await repo.removeBookFromFolder(
                                folder.id,
                                selectedBook.id,
                              );
                              selectedFolderIds.remove(folder.id);
                              if (selectedFolderIds.isEmpty) {
                                await repo.addBookToFolder(
                                  LibraryFolderService.defaultFolderId,
                                  selectedBook.id,
                                );
                                selectedFolderIds.add(
                                  LibraryFolderService.defaultFolderId,
                                );
                              }
                            }
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
          },
        );
      },
    );
  }
}

Widget bookThumbnail(Book selectedBook) {
  return selectedBook.thumbnail.isEmpty
      ? AspectRatio(
          aspectRatio: 3 / 4,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black, width: 0.05),
            ),
            child: const Icon(Icons.print, size: 35),
          ),
        )
      : AspectRatio(
          aspectRatio: 3 / 4,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              border: Border.all(color: Colors.black, width: 0.2),
              image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(selectedBook.thumbnail),
              ),
            ),
          ),
        );
}
