import 'package:book_verse/core/models/book_model.dart';
import 'package:book_verse/core/shared/helpers/helper/book_authors.dart';
import 'package:book_verse/core/shared/themes_extension.dart';
import 'package:book_verse/features/reading_tracker/viewmodel/reading_tracker_viewmodel.dart';
import 'package:book_verse/features/reading_tracker/viewmodel/session_recording_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class SessionRecordingPage extends ConsumerStatefulWidget {
  final String bookId;
  const SessionRecordingPage({super.key, required this.bookId});

  @override
  ConsumerState<SessionRecordingPage> createState() =>
      _SessionRecordingPageState();
}

class _SessionRecordingPageState extends ConsumerState<SessionRecordingPage> {
  final TextEditingController _pageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _initializeSession();
  }

  Future<void> _initializeSession() async {
    final sessionNotifier = ref.read(sessionRecordingNotifierProvider.notifier);
    final initialProgress = await ref.read(
      readingTrackerNotifierProvider(widget.bookId).future,
    );
    sessionNotifier.initializeSession(widget.bookId, initialProgress);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _formatDuration(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  Future<void> _showSaveSessionDialog(
    BuildContext context,
    int previousCurrentPage,
    int totalPages,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Finish Reading Session'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: ListBody(
                children: <Widget>[
                  Text(
                    'Your previous progress: $previousCurrentPage / $totalPages pages',
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _pageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Last page read in this session',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a page number';
                      }
                      final page = int.tryParse(value);
                      if (page == null) {
                        return 'Please enter a valid number';
                      }
                      if (page < 1 || page > totalPages) {
                        return 'Page must be between 1 and $totalPages';
                      }
                      if (page < previousCurrentPage) {
                        return 'Page cannot be less than previous progress ($previousCurrentPage)';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            FilledButton(
              child: const Text('Save Session'),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final lastPage = int.parse(_pageController.text);

                  // Simpan context sebelum operasi async
                  final navigator = Navigator.of(dialogContext);
                  final rootNavigator = Navigator.of(context);

                  await ref
                      .read(sessionRecordingNotifierProvider.notifier)
                      .saveSession(lastPage);

                  // Tutup dialog
                  navigator.pop();

                  // Tutup halaman session recording
                  rootNavigator.pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final sessionNotifier = ref.watch(
      sessionRecordingNotifierProvider.notifier,
    );
    final StopWatchTimer stopWatchTimer = ref.watch(
      sessionRecordingNotifierProvider,
    );
    final readingProgress = sessionNotifier.initialProgress;
    final Book? book = readingProgress?.book;

    if (book == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Record Session')),
        body: const Center(
          child: Text('Error: Book data not found for session recording.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Record Session')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Book Info
            Text(
              book.title,
              style: context.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            Text(
              bookAuthors(book),
              style: context.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Stopwatch Display
            StreamBuilder<int>(
              stream: stopWatchTimer.rawTime,
              initialData: stopWatchTimer.rawTime.value,
              builder: (context, snap) {
                final value = snap.data!;
                return Text(
                  _formatDuration(value ~/ 1000),
                  style: context.textTheme.displayLarge,
                );
              },
            ),
            const SizedBox(height: 32),

            // Control Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                StreamBuilder<int>(
                  stream: stopWatchTimer.rawTime,
                  initialData: stopWatchTimer.rawTime.value,
                  builder: (context, snap) {
                    final isRunning = stopWatchTimer.isRunning;
                    return ElevatedButton.icon(
                      onPressed: () {
                        if (isRunning) {
                          sessionNotifier.pauseTimer();
                        } else {
                          sessionNotifier.startTimer();
                        }
                        setState(() {});
                      },
                      icon: Icon(isRunning ? Icons.pause : Icons.play_arrow),
                      label: Text(isRunning ? 'Pause' : 'Resume'),
                    );
                  },
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    sessionNotifier.resetTimer();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Restart'),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Finish Session Button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  sessionNotifier.pauseTimer();
                  _showSaveSessionDialog(
                    context,
                    readingProgress!.currentPage,
                    book.pageCount,
                  );
                },
                icon: const Icon(Icons.check),
                label: const Text('Finish Session'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
