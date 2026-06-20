import 'package:book_verse/core/models/book_model.dart';
import 'package:book_verse/core/extensions/iterable_extensions.dart';
import 'package:book_verse/core/theme/themes_extension.dart';
import 'package:book_verse/features/bookmarks/viewmodel/bookmark_viewmodel.dart';
import 'package:book_verse/features/home/view/sections/library_action_sheet.dart';
import 'package:book_verse/features/library/data/library_folder_datasource.dart';
import 'package:book_verse/features/library/viewmodel/library_viewmodel.dart';
import 'package:book_verse/features/reading_tracker/model/reading_progress_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ReadingProgressSection extends ConsumerWidget {
  final Book book;
  const ReadingProgressSection(this.book, {super.key});

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
          final folderDs = ref.read(libraryFolderDatasourceProvider);
          await folderDs.assignToDefaultFolder(book.id);
          ref.invalidate(bookmarkNotifierProvider);
          ref.invalidate(libraryNotifierProvider);
          if (context.mounted) {
            showSetCurrentPageSheet(context, ref, book);
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
    final effectiveTotal = readingProgress?.effectivePageCount ?? 0;
    final progressValue = hasStarted && effectiveTotal > 0
        ? readingProgress!.currentPage / effectiveTotal
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
                '${readingProgress!.currentPage} / $effectiveTotal pages',
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
