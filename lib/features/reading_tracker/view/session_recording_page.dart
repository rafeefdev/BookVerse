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
      return;
    }

    if (mounted && sessionNotifier.needsCatchUp) {
      _showCatchUpPrompt();
    }
  }

  Future<void> _showCatchUpPrompt() async {
    await Future.delayed(Duration.zero);
    if (!mounted) return;

    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final controller = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
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
                    child: Text('Welcome back!', style: textTheme.titleLarge),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Looks like you\'ve already started reading this book. '
                'What page are you on?',
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Current page',
                  border: const OutlineInputBorder(),
                  suffixText: 'pages',
                  suffixStyle: TextStyle(color: scheme.onSurfaceVariant),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    final text = controller.text.trim();
                    final page = int.tryParse(text);
                    if (page == null || page < 1) {
                      ScaffoldMessenger.of(sheetContext).showSnackBar(
                        SnackBar(
                          content: const Text(
                            'Please enter a valid page number',
                          ),
                          backgroundColor: scheme.error,
                        ),
                      );
                      return;
                    }
                    final notifier = ref.read(
                      sessionRecordingNotifierProvider.notifier,
                    );
                    notifier.setStartPage(page);
                    Navigator.of(sheetContext).pop();
                  },
                  child: const Text('Set Page'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    final notifier = ref.read(
                      sessionRecordingNotifierProvider.notifier,
                    );
                    notifier.skipCatchUp();
                    Navigator.of(sheetContext).pop();
                  },
                  child: const Text('Start from Page 1'),
                ),
              ),
            ],
          ),
        );
      },
    );
    controller.dispose();
    if (mounted) setState(() {});
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
    final scheme = context.colorScheme;
    final textTheme = context.textTheme;
    int adjustedTotal = totalPages;
    bool isExpanded = false;
    bool pagesAdjusted = false;
    bool isSaving = false;
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
                          color: scheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('Finish Reading Session', style: textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(
                      'Your progress: $previousCurrentPage / $effectiveTotal pages',
                      style: textTheme.bodyMedium,
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
                        style: TextStyle(color: scheme.error, fontSize: 13),
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
                            color: Colors.green.shade600,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Edition adjusted to $adjustedTotal pages',
                            style: TextStyle(
                              color: Colors.green.shade600,
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
                                color: scheme.onSurfaceVariant,
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
                                    style: textTheme.titleSmall,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Adjust for your copy',
                                    style: TextStyle(
                                      color: scheme.onSurfaceVariant,
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
                                        color: scheme.onSurfaceVariant,
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
                                      color: scheme.onSurfaceVariant,
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
                          onPressed: isSaving
                              ? null
                              : () => Navigator.of(sheetContext).pop(),
                          child: const Text('Cancel'),
                        ),
                        const Spacer(),
                        FilledButton(
                          onPressed: isSaving
                              ? null
                              : () async {
                                  if (sheetFormKey.currentState!.validate()) {
                                    setSheetState(() => isSaving = true);
                                    final lastPage = int.parse(
                                      _pageController.text,
                                    );
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
                                    setSheetState(() => isSaving = false);
                                    if (success) {
                                      notifier.resetState();
                                      ref.invalidate(bookmarkNotifierProvider);
                                      ref.invalidate(libraryNotifierProvider);
                                      Navigator.of(sheetContext).pop();
                                      if (context.mounted) {
                                        context.pop();
                                      }
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            notifier.errorMessage ??
                                                'Failed to save session',
                                          ),
                                          backgroundColor: scheme.error,
                                        ),
                                      );
                                    }
                                  }
                                },
                          child: isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Save Session'),
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
    final scheme = context.colorScheme;
    final textTheme = context.textTheme;
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
                      _BookCard(
                        book: book,
                        readingProgress: readingProgress,
                        scheme: scheme,
                        textTheme: textTheme,
                        onFallback: (w, h) => _bookFallback(scheme, w, h),
                      ),
                      _CenterSessionSection(
                        stopWatchTimer: stopWatchTimer,
                        sessionNotifier: sessionNotifier,
                        progressRatio: progressRatio,
                        scheme: scheme,
                        textTheme: textTheme,
                        formatDuration: _formatDuration,
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _StatCard(
                                  value: '${readingProgress.currentPage}',
                                  label: 'Prev page',
                                  scheme: scheme,
                                  textTheme: textTheme,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _StatCard(
                                  value:
                                      '${readingProgress.effectivePageCount}',
                                  label: 'Total pages',
                                  scheme: scheme,
                                  textTheme: textTheme,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _StatCard(
                                  value: _formatDuration(
                                    stopWatchTimer.rawTime.value ~/ 1000,
                                  ),
                                  label: 'Elapsed',
                                  scheme: scheme,
                                  textTheme: textTheme,
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
                                          setState(() {});
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
                                        .withOpacity(0.3),
                                    side: BorderSide(
                                      color: scheme.primary.withOpacity(0.5),
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

  Widget _bookFallback(ColorScheme scheme, double width, double height) {
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
}

class _BookCard extends StatelessWidget {
  const _BookCard({
    required this.book,
    required this.readingProgress,
    required this.scheme,
    required this.textTheme,
    required this.onFallback,
  });

  final Book book;
  final ReadingProgressModel readingProgress;
  final ColorScheme scheme;
  final TextTheme textTheme;
  final Widget Function(double w, double h) onFallback;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        border: Border.all(color: scheme.outlineVariant, width: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: book.thumbnail.isNotEmpty
                ? Image.network(
                    book.thumbnail,
                    width: 44,
                    height: 62,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        onFallback(44, 62),
                  )
                : onFallback(44, 62),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  bookAuthors(book),
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Page ${readingProgress.currentPage} · ${readingProgress.effectivePageCount} pages',
                    style: textTheme.labelSmall?.copyWith(
                      color: scheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimerSection extends StatelessWidget {
  const _TimerSection({
    required this.value,
    required this.isRunning,
    required this.progressRatio,
    required this.scheme,
    required this.textTheme,
    required this.formatDuration,
  });

  final int value;
  final bool isRunning;
  final double progressRatio;
  final ColorScheme scheme;
  final TextTheme textTheme;
  final String Function(int) formatDuration;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // recording chip indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isRunning
                ? Colors.green.withOpacity(0.15)
                : scheme.tertiaryContainer.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isRunning ? Colors.green.shade400 : scheme.tertiary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isRunning ? 'Recording' : 'Paused',
                style: textTheme.labelSmall?.copyWith(
                  color: isRunning ? Colors.green.shade400 : scheme.tertiary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          formatDuration(value ~/ 1000),
          style: textTheme.displayLarge?.copyWith(
            fontSize: 46,
            fontWeight: FontWeight.w300,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'SESSION DURATION',
          style: textTheme.labelSmall?.copyWith(
            color: scheme.onSurfaceVariant,
            fontSize: 10,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value: progressRatio,
              backgroundColor: scheme.surfaceContainerHighest,
            ),
            const SizedBox(height: 4),
            Text(
              '${(progressRatio * 100).toStringAsFixed(0)}% through book',
              style: textTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SecondaryControl extends StatelessWidget {
  const _SecondaryControl({
    required this.icon,
    required this.onPressed,
    required this.scheme,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: IconButton.filledTonal(
        onPressed: onPressed,
        icon: Icon(icon, size: 22),
        style: IconButton.styleFrom(
          backgroundColor: scheme.surfaceContainerHighest,
        ),
      ),
    );
  }
}

class _CenterSessionSection extends StatefulWidget {
  const _CenterSessionSection({
    required this.stopWatchTimer,
    required this.sessionNotifier,
    required this.progressRatio,
    required this.scheme,
    required this.textTheme,
    required this.formatDuration,
  });

  final StopWatchTimer stopWatchTimer;
  final SessionRecordingNotifier sessionNotifier;
  final double progressRatio;
  final ColorScheme scheme;
  final TextTheme textTheme;
  final String Function(int) formatDuration;

  @override
  State<_CenterSessionSection> createState() => _CenterSessionSectionState();
}

class _CenterSessionSectionState extends State<_CenterSessionSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        StreamBuilder<int>(
          stream: widget.stopWatchTimer.rawTime,
          initialData: widget.stopWatchTimer.rawTime.value,
          builder: (context, snap) {
            final isRunning = widget.stopWatchTimer.isRunning;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isRunning
                    ? Colors.green.withOpacity(0.15)
                    : widget.scheme.tertiaryContainer.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isRunning
                          ? Colors.green.shade400
                          : widget.scheme.tertiary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isRunning ? 'Recording' : 'Paused',
                    style: widget.textTheme.labelSmall?.copyWith(
                      color: isRunning
                          ? Colors.green.shade400
                          : widget.scheme.tertiary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        StreamBuilder<int>(
          stream: widget.stopWatchTimer.rawTime,
          initialData: widget.stopWatchTimer.rawTime.value,
          builder: (context, snap) {
            final value = snap.data!;
            return Text(
              widget.formatDuration(value ~/ 1000),
              style: widget.textTheme.displayLarge?.copyWith(
                fontSize: 46,
                fontWeight: FontWeight.w300,
                letterSpacing: -1,
              ),
            );
          },
        ),
        const SizedBox(height: 4),
        Text(
          'SESSION DURATION',
          style: widget.textTheme.labelSmall?.copyWith(
            color: widget.scheme.onSurfaceVariant,
            fontSize: 10,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value: widget.progressRatio,
              backgroundColor: widget.scheme.surfaceContainerHighest,
            ),
            const SizedBox(height: 4),
            Text(
              '${(widget.progressRatio * 100).toStringAsFixed(0)}% through book',
              style: widget.textTheme.labelSmall?.copyWith(
                color: widget.scheme.onSurfaceVariant,
                fontSize: 10,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SecondaryControl(
              icon: Icons.restart_alt_rounded,
              onPressed: () => widget.sessionNotifier.resetTimer(),
              scheme: widget.scheme,
            ),
            const SizedBox(width: 20),
            SizedBox(
              width: 60,
              height: 60,
              child: FloatingActionButton(
                onPressed: () {
                  if (widget.stopWatchTimer.isRunning) {
                    widget.sessionNotifier.pauseTimer();
                  } else {
                    widget.sessionNotifier.startTimer();
                  }
                  setState(() {});
                },
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    widget.stopWatchTimer.isRunning
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    key: ValueKey(widget.stopWatchTimer.isRunning),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            _SecondaryControl(
              icon: Icons.skip_next_rounded,
              onPressed: null,
              scheme: widget.scheme,
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    required this.scheme,
    required this.textTheme,
  });

  final String value;
  final String label;
  final ColorScheme scheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
