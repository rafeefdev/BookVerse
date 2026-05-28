import 'package:book_verse/core/models/book_model.dart';
import 'package:book_verse/core/shared/helpers/helper/book_authors.dart';
import 'package:book_verse/core/shared/themes_extension.dart';
import 'package:book_verse/features/bookmarks/viewmodel/bookmark_viewmodel.dart';
import 'package:book_verse/features/library/viewmodel/library_viewmodel.dart';
import 'package:book_verse/features/reading_tracker/model/reading_progress_model.dart';
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

class _SessionRecordingPageState extends ConsumerState<SessionRecordingPage> {
  final TextEditingController _pageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeSession();
  }

  Future<void> _initializeSession() async {
    final sessionNotifier = ref.read(sessionRecordingNotifierProvider.notifier);
    final success = await sessionNotifier.initializeSession(widget.bookId);

    if (mounted) {
      setState(() {});
    }

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(sessionNotifier.errorMessage ?? 'Unknown error'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
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

  Future<void> _showSaveBottomSheet(
    BuildContext context,
    int previousCurrentPage,
    int totalPages,
  ) async {
    int adjustedTotal = totalPages;
    bool isExpanded = false;
    bool pagesAdjusted = false;
    final totalPagesController = TextEditingController(
      text: totalPages.toString(),
    );
    final sheetFormKey = GlobalKey<FormState>();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetInnerContext, setSheetState) {
            final effectiveTotal = pagesAdjusted ? adjustedTotal : totalPages;

            String? pageValidator(String? value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a page number';
              }
              final page = int.tryParse(value);
              if (page == null) return 'Please enter a valid number';
              if (page < 1 || page > effectiveTotal) {
                return 'Page must be between 1 and $effectiveTotal';
              }
              if (page < previousCurrentPage) {
                return 'Page cannot be less than previous progress ($previousCurrentPage)';
              }
              return null;
            }

            final pageText = _pageController.text;
            final pageVal = int.tryParse(pageText);
            final showEditionError = pageVal != null && pageVal > totalPages;

            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 12,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Form(
                key: sheetFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Finish Reading Session',
                      style: context.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your progress: $previousCurrentPage / $effectiveTotal pages',
                      style: context.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _pageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Last page read in this session',
                        border: OutlineInputBorder(),
                      ),
                      validator: pageValidator,
                    ),
                    if (showEditionError) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Page exceeds edition length',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 13,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () => setSheetState(() {
                          if (!isExpanded) {
                            totalPagesController.text = adjustedTotal
                                .toString();
                          }
                          isExpanded = !isExpanded;
                        }),
                        icon: AnimatedRotation(
                          turns: isExpanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: const Icon(Icons.expand_more, size: 20),
                        ),
                        label: Text(
                          isExpanded
                              ? 'Hide edition settings'
                              : 'Adjust page count',
                        ),
                      ),
                    ),
                    if (pagesAdjusted) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 16,
                            color: Colors.green[600],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Edition adjusted to $adjustedTotal pages',
                            style: TextStyle(
                              color: Colors.green[600],
                              fontSize: 13,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => setSheetState(() {
                              pagesAdjusted = false;
                              adjustedTotal = totalPages;
                              totalPagesController.text = totalPages.toString();
                            }),
                            child: Text(
                              'Revert',
                              style: TextStyle(
                                color: context.textTheme.bodySmall?.color,
                                fontSize: 13,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    AnimatedSize(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      alignment: Alignment.topCenter,
                      child: isExpanded
                          ? Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Divider(),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Edition Settings',
                                    style: context.textTheme.titleSmall,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Adjust for your copy',
                                    style: TextStyle(
                                      color: context.textTheme.bodySmall?.color,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: totalPagesController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'Total pages',
                                      border: const OutlineInputBorder(),
                                      suffixText: 'pages',
                                      suffixStyle: TextStyle(
                                        color:
                                            context.textTheme.bodySmall?.color,
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Enter total pages';
                                      }
                                      final p = int.tryParse(value);
                                      if (p == null || p < 1) {
                                        return 'Enter a valid number';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Reference: $totalPages (Google Books)',
                                    style: TextStyle(
                                      color: context.textTheme.bodySmall?.color,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: FilledButton.tonal(
                                      onPressed: () {
                                        if (totalPagesController
                                            .text
                                            .isNotEmpty) {
                                          final newTotal = int.tryParse(
                                            totalPagesController.text,
                                          );
                                          if (newTotal != null &&
                                              newTotal > 0) {
                                            setSheetState(() {
                                              adjustedTotal = newTotal;
                                              pagesAdjusted = true;
                                              isExpanded = false;
                                            });
                                          }
                                        }
                                      },
                                      child: const Text('Save Changes'),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(sheetContext).pop(),
                          child: const Text('Cancel'),
                        ),
                        const Spacer(),
                        FilledButton(
                          onPressed: () async {
                            if (sheetFormKey.currentState!.validate()) {
                              final lastPage = int.parse(_pageController.text);
                              final notifier = ref.read(
                                sessionRecordingNotifierProvider.notifier,
                              );
                              final success = await notifier.saveSession(
                                lastPage,
                                userPageCount: pagesAdjusted
                                    ? adjustedTotal
                                    : null,
                              );
                              if (!sheetContext.mounted) return;
                              if (success) {
                                ref.invalidate(bookmarkNotifierProvider);
                                ref.invalidate(libraryNotifierProvider);
                                Navigator.of(sheetContext).pop();
                                if (context.mounted) {
                                  context.pop();
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      notifier.errorMessage ??
                                          'Failed to save session',
                                    ),
                                    backgroundColor: Theme.of(
                                      context,
                                    ).colorScheme.error,
                                  ),
                                );
                              }
                            }
                          },
                          child: const Text('Save Session'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      totalPagesController.dispose();
    });
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
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    sessionNotifier.errorMessage ?? 'An error occurred',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
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
    return PopScope(
      canPop: !stopWatchTimer.isRunning,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
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
                          icon: Icon(
                            isRunning ? Icons.pause : Icons.play_arrow,
                          ),
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
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      sessionNotifier.pauseTimer();
                      final effectiveTotal = readingProgress.effectivePageCount;
                      if (_pageController.text.isEmpty) {
                        _pageController.text = readingProgress.currentPage
                            .toString();
                      }
                      setState(() {});
                      _showSaveBottomSheet(
                        context,
                        readingProgress.currentPage,
                        effectiveTotal,
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
        ),
      ),
    );
  }
}
