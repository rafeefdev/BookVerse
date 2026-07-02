import 'package:book_verse/features/goals/providers/goal_providers.dart';
import 'package:book_verse/features/goals/view/components/goal_progress_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GoalSettingsPage extends ConsumerStatefulWidget {
  const GoalSettingsPage({super.key});

  @override
  ConsumerState<GoalSettingsPage> createState() => _GoalSettingsPageState();
}

class _GoalSettingsPageState extends ConsumerState<GoalSettingsPage> {
  late TextEditingController _pagesCtrl;
  late TextEditingController _minutesCtrl;
  int? _lastPages;
  int? _lastMinutes;

  @override
  void initState() {
    super.initState();
    _pagesCtrl = TextEditingController();
    _minutesCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _pagesCtrl.dispose();
    _minutesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final goalAsync = ref.watch(dailyGoalProvider);
    final progressAsync = ref.watch(goalProgressProvider);
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Reading Goal')),
      body: goalAsync.when(
        data: (goal) {
          if (goal.targetPages != _lastPages) {
            _pagesCtrl.text = goal.targetPages.toString();
            _lastPages = goal.targetPages;
          }
          if (goal.targetMinutes != _lastMinutes) {
            _minutesCtrl.text = goal.targetMinutes.toString();
            _lastMinutes = goal.targetMinutes;
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // --- Enable switch (always active) ---
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                clipBehavior: Clip.antiAlias,
                child: SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  title: const Text('Enable Daily Goal'),
                  subtitle: goal.enabled
                      ? Text(
                          'Read ${goal.targetPages} pages or '
                          '${goal.targetMinutes} minutes each day',
                          style: textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        )
                      : Text(
                          'Set daily reading targets',
                          style: textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                  value: goal.enabled,
                  onChanged: (_) {
                    ref.read(dailyGoalProvider.notifier).toggleEnabled();
                  },
                ),
              ),
              const SizedBox(height: 12),

              // --- Content below: faded + non-interactive when disabled ---
              AnimatedOpacity(
                opacity: goal.enabled ? 1.0 : 0.38,
                duration: const Duration(milliseconds: 200),
                child: AbsorbPointer(
                  absorbing: !goal.enabled,
                  child: Column(
                    children: [
                      // Target inputs
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Target', style: textTheme.titleMedium),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _pagesCtrl,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Pages per day',
                                  border: OutlineInputBorder(),
                                  suffixText: 'pages',
                                ),
                                onChanged: (v) {
                                  final pages = int.tryParse(v);
                                  if (pages != null && pages > 0) {
                                    ref
                                        .read(dailyGoalProvider.notifier)
                                        .updateTargetPages(pages);
                                  }
                                },
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _minutesCtrl,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Minutes per day',
                                  border: OutlineInputBorder(),
                                  suffixText: 'min',
                                ),
                                onChanged: (v) {
                                  final minutes = int.tryParse(v);
                                  if (minutes != null && minutes > 0) {
                                    ref
                                        .read(dailyGoalProvider.notifier)
                                        .updateTargetMinutes(minutes);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Today's Progress preview
                      if (goal.enabled)
                        progressAsync.when(
                          data: (progress) {
                            if (progress == null) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: GoalProgressCard(
                                progress: progress,
                                onTap: null,
                              ),
                            );
                          },
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) {
          return Center(
            child: Text(
              'Failed to load goal settings',
              style: textTheme.bodyMedium?.copyWith(color: cs.error),
            ),
          );
        },
      ),
    );
  }
}
