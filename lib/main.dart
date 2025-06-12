import 'package:BookVerse/view/pages/new_homepage.dart';
import 'package:BookVerse/view/pages/splash_screens/first_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:BookVerse/shared/app_theme.dart';
import 'package:BookVerse/view/pages/chatbot_page.dart';
import 'package:BookVerse/view/pages/savedbook_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(); //load .env file
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
      home: FirstScreen(),
    );
  }
}

List pages = [NewHomePage(), SavedbookPage()];

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
          BottomNavigationBarItem(icon: Icon(Icons.save), label: 'Saved Books'),
        ],
      ),
    );
  }
}
