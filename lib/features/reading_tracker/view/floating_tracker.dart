import 'package:book_verse/core/shared/themes_extension.dart';
import 'package:book_verse/features/reading_tracker/viewmodel/reading_tracker_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FloatingTracker extends ConsumerWidget {
  const FloatingTracker({super.key});

  String _formatDuration(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}h ${twoDigitMinutes}m ${twoDigitSeconds}s";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isActivelyReading = ref.watch(isActivelyReadingProvider);
    final isDismissed = ref.watch(trackerDismissedProvider);

    if (!isActivelyReading || isDismissed) return const SizedBox.shrink();

    final isBlocked = ref.watch(isTrackerBlockedProvider);
    if (isBlocked) return const SizedBox.shrink();

    final isShellRoute = ref.watch(isShellRouteProvider);

    final viewPadding = MediaQuery.of(context).viewPadding.bottom;
    final bottomNavHeight = isShellRoute ? kBottomNavigationBarHeight : 0.0;
    final bottomOffset = bottomNavHeight + viewPadding + 12;

    final activeProgressAsync = ref.watch(activeReadingProgressProvider);

    return activeProgressAsync.when(
      data: (progress) {
        if (progress == null || progress.book == null) {
          return const SizedBox.shrink();
        }
        final book = progress.book!;
        final double percent = book.pageCount > 0
            ? progress.currentPage / book.pageCount
            : 0.0;

        return Padding(
          padding: EdgeInsets.only(left: 12, right: 12, bottom: bottomOffset),
          child: SizedBox(
            height: 72,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 12, right: 4),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        book.thumbnail,
                        width: 44,
                        height: 52,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 44,
                          height: 52,
                          color: Colors.grey[300],
                          child: const Icon(Icons.book, size: 28),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            book.title,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: context.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                '${progress.currentPage}/${book.pageCount}',
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: context.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(2),
                                  child: LinearProgressIndicator(
                                    value: percent,
                                    minHeight: 4,
                                    backgroundColor: Colors.grey[200],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDuration(progress.totalReadingTimeInSeconds),
                      style: context.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        size: 18,
                        color: Colors.grey[500],
                      ),
                      visualDensity: VisualDensity.compact,
                      onPressed: () {
                        ref.read(trackerDismissedProvider.notifier).state =
                            true;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
