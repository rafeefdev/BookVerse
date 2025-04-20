import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_book/view/app_theme.dart';
import 'package:google_book/view/pages/chatbot_page.dart';
import 'package:google_book/view/pages/homepage.dart';
import 'package:google_book/view/pages/savedbook_page.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BookVerse',
      debugShowCheckedModeBanner: false,
      theme: themeData,
      home: MainPage(),
    );
  }
}

List pages = [HomePage(), ChatbotPage(), SavedbookPage()];

final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

class MainPage extends ConsumerWidget {
  const MainPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int index = ref.watch(bottomNavIndexProvider);
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (value) {
          ref.read(bottomNavIndexProvider.notifier).state = value;
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat AI'),
          BottomNavigationBarItem(icon: Icon(Icons.save), label: 'Saved Books'),
        ],
      ),
    );
  }
}
