import 'package:book_verse/core/theme/themes_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class NewHomePage extends ConsumerStatefulWidget {
  const NewHomePage({super.key});

  @override
  ConsumerState<NewHomePage> createState() => _HomeState();
}

class _HomeState extends ConsumerState<NewHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: context.colorScheme.surfaceContainerHighest,
              child: Icon(Icons.search, size: 30),
            ),
            const SizedBox(height: 10),
            Text(
              "Tap to browse millions of books !",
              style: context.textTheme.titleLarge,
            ),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: () {
                context.push('/search');
              },
              child: Hero(
                tag: 'searchBar',
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                    decoration: BoxDecoration(
                      color: context.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      'Search...',
                      style: TextStyle(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
