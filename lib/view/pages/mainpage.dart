import 'package:BookVerse/helper/push_navigation.dart';
import 'package:BookVerse/view/pages/new_homepage.dart';
import 'package:BookVerse/view/pages/savedbook_page.dart';
import 'package:BookVerse/view/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

List pages = [NewHomePage(), SavedbookPage()];

final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

class MainPage extends ConsumerWidget {
  const MainPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int index = ref.watch(bottomNavIndexProvider);
    return Scaffold(
      appBar: AppBar(
        title: CircleAvatar(child: const Icon(Icons.book)),
        automaticallyImplyLeading: false,
        actionsPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        actions: [
          IconButton.filledTonal(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      body: pages[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (value) {
          ref.read(bottomNavIndexProvider.notifier).state = value;
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.save), label: 'Saved Books'),
        ],
      ),
    );
  }
}
