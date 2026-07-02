import 'package:book_verse/core/theme/themes_extension.dart';
import 'package:book_verse/features/library/model/library_state.dart';
import 'package:book_verse/features/library/view/widgets/finished_book_card.dart';
import 'package:book_verse/features/library/view/widgets/library_book_list_tab.dart';
import 'package:book_verse/features/library/view/widgets/saved_tab.dart';
import 'package:book_verse/features/library/viewmodel/library_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LibraryPage extends ConsumerStatefulWidget {
  const LibraryPage({super.key});

  @override
  ConsumerState<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends ConsumerState<LibraryPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final libraryAsync = ref.watch(libraryNotifierProvider);

    return libraryAsync.when(
      data: (state) => _buildContent(state),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: context.colorScheme.error,
            ),
            const SizedBox(height: 16),
            const Text('Could not load your library'),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => ref.invalidate(libraryNotifierProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(LibraryState state) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Reading'),
            Tab(text: 'Finished'),
            Tab(text: 'Saved'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              LibraryBookListTab(
                books: state.currentlyReading,
                emptyIcon: Icons.menu_book_outlined,
                emptyText: 'No books being read',
              ),
              _FinishedTab(state: state),
              SavedTab(
                state: state,
                onCreateFolder: (name) {
                  ref.read(libraryNotifierProvider.notifier).createFolder(name);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FinishedTab extends StatelessWidget {
  final LibraryState state;
  const _FinishedTab({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.finishedInfo.isEmpty) {
      final scheme = Theme.of(context).colorScheme;
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: scheme.outlineVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No finished books yet',
              style: TextStyle(fontSize: 16, color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.finishedInfo.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: FinishedBookCard(info: state.finishedInfo[index]),
        );
      },
    );
  }
}
