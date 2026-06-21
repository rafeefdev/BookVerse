import 'package:book_verse/core/models/book_model.dart';
import 'package:book_verse/core/theme/themes_extension.dart';
import 'package:book_verse/features/bookmarks/viewmodel/bookmark_viewmodel.dart';
import 'package:book_verse/features/insights/viewmodel/insights_viewmodel.dart';
import 'package:book_verse/features/library/viewmodel/library_viewmodel.dart';
import 'package:book_verse/features/reading_tracker/model/reading_progress_model.dart';
import 'package:book_verse/features/reading_tracker/view/session_helpers.dart';
import 'package:book_verse/features/reading_tracker/view/components/session_book_card.dart';
import 'package:book_verse/features/reading_tracker/view/components/session_catch_up_sheet.dart';
import 'package:book_verse/features/reading_tracker/view/components/session_save_sheet.dart';
import 'package:book_verse/features/reading_tracker/view/components/session_stat_card.dart';
import 'package:book_verse/features/reading_tracker/view/sections/session_timer_section.dart';
import 'package:book_verse/features/reading_tracker/viewmodel/session_recording_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class SessionRecordingPage extends ConsumerStatefulWidget {
  final String bookId;
  const SessionRecordingPage({super.key, required this.bookId});

  @override
  ConsumerState<SessionRecordingPage> createState() =>
      _SessionRecordingPageState();
}

class _SessionRecordingPageState extends ConsumerState<SessionRecordingPage>
    with WidgetsBindingObserver {
  final TextEditingController _pageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeSession();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _initializeSession() async {
    final sessionNotifier = ref.read(sessionRecordingNotifierProvider.notifier);
    final success = await sessionNotifier.initializeSession(widget.bookId);

    if (mounted) setState(() {});

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(sessionNotifier.errorMessage ?? 'Unknown error'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    if (mounted && sessionNotifier.needsCatchUp) {
      _showCatchUpPrompt();
    }
  }

  Future<void> _showCatchUpPrompt() async {
    await Future.delayed(Duration.zero);
    if (!mounted) return;
    final notifier = ref.read(sessionRecordingNotifierProvider.notifier);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SessionCatchUpSheet(notifier: notifier),
    );
    if (mounted) setState(() {});
  }

  Future<void> _showSaveBottomSheet(
    BuildContext context,
    int previousCurrentPage,
    int totalPages,
  ) async {
    final notifier = ref.read(sessionRecordingNotifierProvider.notifier);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SessionSaveSheet(
        notifier: notifier,
        pageController: _pageController,
        previousCurrentPage: previousCurrentPage,
        totalPages: totalPages,
        onSaved: () {
          ref.invalidate(bookmarkNotifierProvider);
          ref.invalidate(libraryNotifierProvider);
          ref.invalidate(insightsProvider);
        },
      ),
    );
    if (context.mounted) context.pop();
  }

  Widget _bookFallback(double width, double height) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.book_rounded, color: scheme.onSurfaceVariant),
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
    final bool isInitialized = sessionNotifier.isInitialized;
    final bool hasError = sessionNotifier.hasError;

    if (!isInitialized) {
      return Scaffold(
        appBar: AppBar(title: const Text('Record Session')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading book data...'),
            ],
          ),
        ),
      );
    }

    if (hasError) {
      return Scaffold(
        appBar: AppBar(title: const Text('Record Session')),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: context.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    sessionNotifier.errorMessage ?? 'An error occurred',
                    textAlign: TextAlign.center,
                    style: context.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () =>
                        ref.invalidate(sessionRecordingNotifierProvider),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (book == null || readingProgress == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Record Session')),
        body: const Center(child: Text('Book data not available')),
      );
    }

    return _buildSessionUI(
      context,
      sessionNotifier,
      stopWatchTimer,
      book,
      readingProgress,
    );
  }

  Widget _buildSessionUI(
    BuildContext context,
    SessionRecordingNotifier sessionNotifier,
    StopWatchTimer stopWatchTimer,
    Book book,
    ReadingProgressModel readingProgress,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final progressRatio = readingProgress.effectivePageCount > 0
        ? readingProgress.currentPage / readingProgress.effectivePageCount
        : 0.0;

    return PopScope(
      canPop: !stopWatchTimer.isRunning,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          sessionNotifier.resetState();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Please finish or pause your reading session before leaving.',
              ),
              action: SnackBarAction(
                label: 'Close',
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Record Session')),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SessionBookCard(
                        book: book,
                        readingProgress: readingProgress,
                        onFallback: _bookFallback,
                      ),
                      SessionTimerSection(
                        stopWatchTimer: stopWatchTimer,
                        onPauseTimer: () => sessionNotifier.pauseTimer(),
                        onStartTimer: () => sessionNotifier.startTimer(),
                        onResetTimer: () => sessionNotifier.resetTimer(),
                        progressRatio: progressRatio,
                        formatDuration: formatSessionDuration,
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: SessionStatCard(
                                  value: '${readingProgress.currentPage}',
                                  label: 'Prev page',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: SessionStatCard(
                                  value:
                                      '${readingProgress.effectivePageCount}',
                                  label: 'Total pages',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: SessionStatCard(
                                  value: formatSessionDuration(
                                    readingProgress.totalReadingTimeInSeconds +
                                        (stopWatchTimer.rawTime.value ~/ 1000),
                                  ),
                                  label: 'Elapsed',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          StreamBuilder<int>(
                            stream: stopWatchTimer.rawTime,
                            initialData: stopWatchTimer.rawTime.value,
                            builder: (context, snap) {
                              final canFinish = snap.data! > 0;
                              return SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: canFinish
                                      ? () {
                                          sessionNotifier.pauseTimer();
                                          if (_pageController.text.isEmpty) {
                                            _pageController.text =
                                                readingProgress.currentPage
                                                    .toString();
                                          }
                                          _showSaveBottomSheet(
                                            context,
                                            readingProgress.currentPage,
                                            readingProgress.effectivePageCount,
                                          );
                                        }
                                      : null,
                                  icon: const Icon(Icons.check_rounded),
                                  label: const Text('Finish Session'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    backgroundColor: scheme.primaryContainer
                                        .withValues(alpha: 0.3),
                                    side: BorderSide(
                                      color: scheme.primary.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
