import 'package:book_verse/core/models/book_model.dart';
import 'package:book_verse/core/shared/helpers/helper/book_authors.dart';
import 'package:book_verse/core/shared/themes_extension.dart';
import 'package:book_verse/features/reading_tracker/model/reading_progress_model.dart';
import 'package:book_verse/features/reading_tracker/viewmodel/reading_tracker_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ReadingTrackerDetailPage extends ConsumerWidget {
  final String bookId;
  const ReadingTrackerDetailPage({super.key, required this.bookId});

  String _formatDuration(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}h ${twoDigitMinutes}m ${twoDigitSeconds}s";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readingProgressAsync = ref.watch(readingTrackerNotifierProvider(bookId));
    final readingSessionsAsync = ref.watch(bookReadingSessionsProvider(bookId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reading Progress'),
      ),
      body: readingProgressAsync.when(
        data: (progress) {
          if (progress == null || progress.book == null) {
            return const Center(child: Text('Book not found or not tracked.'));
          }
          final book = progress.book!;
          final double progressValue = book.pageCount > 0
              ? progress.currentPage / book.pageCount
              : 0.0;
          final String progressText =
              '${progress.currentPage} / ${book.pageCount} pages';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Book Info
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    book.thumbnail.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              book.thumbnail,
                              width: 100,
                              height: 150,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.book, size: 100),
                            ),
                          )
                        : Container(
                            width: 100,
                            height: 150,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                                child: Icon(Icons.book,
                                    size: 50, color: Colors.grey[600])),
                          ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            book.title,
                            style: context.textTheme.headlineSmall,
                          ),
                          Text(
                            bookAuthors(book),
                            style: context.textTheme.titleSmall,
                          ),
                          Text(
                            book.publisher,
                            style: context.textTheme.bodyMedium,
                          ),
                          Text(
                            'Total Pages: ${book.pageCount}',
                            style: context.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Reading Progress
                Text(
                  'Current Progress',
                  style: context.textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progressValue,
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
                      progressText,
                      style: context.textTheme.bodyLarge,
                    ),
                    Text(
                      '${(progressValue * 100).toStringAsFixed(1)}%',
                      style: context.textTheme.bodyLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Total Reading Time
                Text(
                  'Total Time Spent Reading',
                  style: context.textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  _formatDuration(progress.totalReadingTimeInSeconds),
                  style: context.textTheme.headlineMedium,
                ),
                const SizedBox(height: 24),

                // Start Session Button
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
                const SizedBox(height: 24),

                // Reading Sessions History
                Text(
                  'Reading Sessions History',
                  style: context.textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                readingSessionsAsync.when(
                  data: (sessions) {
                    if (sessions.isEmpty) {
                      return const Center(
                          child: Text('No reading sessions recorded yet.'));
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: sessions.length,
                      itemBuilder: (context, index) {
                        final session = sessions[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: const Icon(Icons.history_toggle_off),
                            title: Text(
                                'Session ${sessions.length - index} - Page ${session.endPage}'),
                            subtitle: Text(
                                '${_formatDuration(session.durationInSeconds)} - ${DateFormat('MMM dd, yyyy HH:mm').format(session.timestamp)}'),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) =>
                      Center(child: Text('Error loading sessions: $error')),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('Error loading progress: $error')),
      ),
    );
  }
}
