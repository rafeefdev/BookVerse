import 'package:BookVerse/shared/themes_extension.dart';
import 'package:BookVerse/view/pages/search_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
            const CircleAvatar(radius: 30, child: Icon(Icons.search, size: 30)),
            const SizedBox(height: 10),
            const Text("Tap to browse millions of books.", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 600),
                    pageBuilder: (_, __, ___) => const SearchPage(),
                  ),
                );
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
                      color: context.theme.brightness == Brightness.dark
                        ? Colors.grey[800]
                        : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(
                      'Search...',
                      style: TextStyle(color: Colors.grey),
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
