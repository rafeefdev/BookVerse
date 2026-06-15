import 'package:book_verse/features/reading_tracker/viewmodel/session_recording_viewmodel.dart';
import 'package:flutter/material.dart';

class SessionCatchUpSheet extends StatefulWidget {
  final SessionRecordingNotifier notifier;
  const SessionCatchUpSheet({super.key, required this.notifier});

  @override
  State<SessionCatchUpSheet> createState() => _SessionCatchUpSheetState();
}

class _SessionCatchUpSheetState extends State<SessionCatchUpSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
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
            controller: _controller,
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
                final text = _controller.text.trim();
                final page = int.tryParse(text);
                if (page == null || page < 1) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Please enter a valid page number'),
                      backgroundColor: scheme.error,
                    ),
                  );
                  return;
                }
                widget.notifier.setStartPage(page);
                Navigator.of(context).pop();
              },
              child: const Text('Set Page'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                widget.notifier.skipCatchUp();
                Navigator.of(context).pop();
              },
              child: const Text('Start from Page 1'),
            ),
          ),
          ],
        ),
      ),
    );
  }
}
