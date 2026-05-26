import 'package:book_verse/features/library/model/library_state.dart';
import 'package:book_verse/features/library/view/widgets/currently_reading_tab.dart';
import 'package:book_verse/features/library/view/widgets/finished_tab.dart';
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
      error: (err, _) => Center(child: Text('Error: $err')),
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
              CurrentlyReadingTab(state: state),
              FinishedTab(state: state),
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
