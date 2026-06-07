import 'package:book_verse/features/reading_tracker/view/components/session_secondary_control.dart';
import 'package:flutter/material.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class SessionTimerSection extends StatefulWidget {
  final StopWatchTimer stopWatchTimer;
  final void Function() onPauseTimer;
  final void Function() onStartTimer;
  final void Function() onResetTimer;
  final double progressRatio;
  final String Function(int) formatDuration;

  const SessionTimerSection({
    super.key,
    required this.stopWatchTimer,
    required this.onPauseTimer,
    required this.onStartTimer,
    required this.onResetTimer,
    required this.progressRatio,
    required this.formatDuration,
  });

  @override
  State<SessionTimerSection> createState() => _SessionTimerSectionState();
}

class _SessionTimerSectionState extends State<SessionTimerSection> {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
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
                    ? Colors.green.withValues(alpha: 0.15)
                    : scheme.tertiaryContainer.withValues(alpha: 0.15),
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
              style: textTheme.displayLarge?.copyWith(
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
              value: widget.progressRatio,
              backgroundColor: scheme.surfaceContainerHighest,
            ),
            const SizedBox(height: 4),
            Text(
              '${(widget.progressRatio * 100).toStringAsFixed(0)}% through book',
              style: textTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
                fontSize: 10,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SessionSecondaryControl(
              icon: Icons.restart_alt_rounded,
              onPressed: widget.onResetTimer,
            ),
            const SizedBox(width: 20),
            SizedBox(
              width: 60,
              height: 60,
              child: FloatingActionButton(
                onPressed: () {
                  if (widget.stopWatchTimer.isRunning) {
                    widget.onPauseTimer();
                  } else {
                    widget.onStartTimer();
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
            SessionSecondaryControl(
              icon: Icons.skip_next_rounded,
              onPressed: null,
            ),
          ],
        ),
      ],
    );
  }
}
