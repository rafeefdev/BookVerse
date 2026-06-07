import 'package:book_verse/features/reading_tracker/viewmodel/session_recording_viewmodel.dart';
import 'package:flutter/material.dart';

class SessionSaveSheet extends StatefulWidget {
  final SessionRecordingNotifier notifier;
  final TextEditingController pageController;
  final int previousCurrentPage;
  final int totalPages;
  final VoidCallback onSaved;

  const SessionSaveSheet({
    super.key,
    required this.notifier,
    required this.pageController,
    required this.previousCurrentPage,
    required this.totalPages,
    required this.onSaved,
  });

  @override
  State<SessionSaveSheet> createState() => _SessionSaveSheetState();
}

class _SessionSaveSheetState extends State<SessionSaveSheet> {
  final _totalPagesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  int _adjustedTotal = 0;
  bool _isExpanded = false;
  bool _pagesAdjusted = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _adjustedTotal = widget.totalPages;
    _totalPagesController.text = widget.totalPages.toString();
  }

  @override
  void dispose() {
    _totalPagesController.dispose();
    super.dispose();
  }

  int get _effectiveTotal => _pagesAdjusted ? _adjustedTotal : widget.totalPages;

  String? _pageValidator(String? value) {
    if (value == null || value.isEmpty) return 'Please enter a page number';
    final page = int.tryParse(value);
    if (page == null) return 'Please enter a valid number';
    if (page < 1 || page > _effectiveTotal) {
      return 'Page must be between 1 and $_effectiveTotal';
    }
    if (page < widget.previousCurrentPage) {
      return 'Page cannot be less than previous progress (${widget.previousCurrentPage})';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final pageText = widget.pageController.text;
    final pageVal = int.tryParse(pageText);
    final showEditionError = pageVal != null && pageVal > widget.totalPages;

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
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
              'Your progress: ${widget.previousCurrentPage} / $_effectiveTotal pages',
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: widget.pageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Last page read in this session',
                border: OutlineInputBorder(),
              ),
              validator: _pageValidator,
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
                onPressed: () => setState(() {
                  if (!_isExpanded) {
                    _totalPagesController.text = _adjustedTotal.toString();
                  }
                  _isExpanded = !_isExpanded;
                }),
                icon: AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(Icons.expand_more, size: 20),
                ),
                label: Text(
                  _isExpanded ? 'Hide edition settings' : 'Adjust page count',
                ),
              ),
            ),
            if (_pagesAdjusted) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.check_circle, size: 16, color: Colors.green.shade600),
                  const SizedBox(width: 6),
                  Text(
                    'Edition adjusted to $_adjustedTotal pages',
                    style: TextStyle(color: Colors.green.shade600, fontSize: 13),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() {
                      _pagesAdjusted = false;
                      _adjustedTotal = widget.totalPages;
                      _totalPagesController.text = widget.totalPages.toString();
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
              child: _isExpanded
                  ? Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(),
                          const SizedBox(height: 8),
                          Text('Edition Settings', style: textTheme.titleSmall),
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
                            controller: _totalPagesController,
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
                            'Reference: ${widget.totalPages} (Google Books)',
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
                                if (_totalPagesController.text.isNotEmpty) {
                                  final newTotal = int.tryParse(
                                    _totalPagesController.text,
                                  );
                                  if (newTotal != null && newTotal > 0) {
                                    setState(() {
                                      _adjustedTotal = newTotal;
                                      _pagesAdjusted = true;
                                      _isExpanded = false;
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
                  onPressed: _isSaving
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: _isSaving
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() => _isSaving = true);
                            final lastPage = int.parse(widget.pageController.text);
                            final success = await widget.notifier.saveSession(
                              lastPage,
                              userPageCount:
                                  _pagesAdjusted ? _adjustedTotal : null,
                            );
                            if (!context.mounted) return;
                            setState(() => _isSaving = false);
                            if (success) {
                              widget.notifier.resetState();
                              widget.onSaved();
                              if (context.mounted) Navigator.of(context).pop();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    widget.notifier.errorMessage ??
                                        'Failed to save session',
                                  ),
                                  backgroundColor: scheme.error,
                                ),
                              );
                            }
                          }
                        },
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save Session'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
