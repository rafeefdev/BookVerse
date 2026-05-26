import 'package:book_verse/features/reading_tracker/viewmodel/reading_tracker_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ShellScaffold extends ConsumerStatefulWidget {
  const ShellScaffold({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<ShellScaffold> createState() => _ShellScaffoldState();
}

class _ShellScaffoldState extends ConsumerState<ShellScaffold> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(isShellRouteProvider.notifier).state = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [const CircleAvatar(child: Icon(Icons.book))],
        ),
        automaticallyImplyLeading: false,
        actionsPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        actions: [
          IconButton.filledTonal(
            onPressed: () {
              context.push('/settings');
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: widget.navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: widget.navigationShell.currentIndex,
        onTap: (index) {
          widget.navigationShell.goBranch(
            index,
            initialLocation: index == widget.navigationShell.currentIndex,
          );
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.save), label: 'Saved Books'),
        ],
      ),
    );
  }
}
