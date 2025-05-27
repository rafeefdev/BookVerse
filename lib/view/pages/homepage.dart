import 'package:BookVerse/helper/push_navigation.dart';
import 'package:BookVerse/view/pages/search_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:BookVerse/model/book_model.dart';
import 'package:BookVerse/provider/playbook_services_provider.dart';
import 'package:BookVerse/view/components.dart';
import 'package:BookVerse/view/pages/chatbot_page.dart';
import 'package:BookVerse/view/pages/detail_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomeState();
}

class _HomeState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    // Panggil fetchBooks() hanya saat pertama kali widget dibangun
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentState = ref.read(bookNotifierProvider);
      if (currentState.data.isEmpty) {
        ref
            .read(bookNotifierProvider.notifier)
            .fetchBooks(author: 'malcolm gladwell');
      }
    });

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(bookNotifierProvider.notifier).fetchBooks();
        },
        child: _buildBookList(textTheme),
      ),
      floatingActionButton: _buildChatButton(context),
    );
  }
}

Widget _buildBookList(TextTheme textTheme) {
  return Consumer(
    builder: (context, ref, _) {
      final state = ref.watch(bookNotifierProvider);
      if (state.status == 'loading') {
        return const Center();
      }
      if (state.status == 'failed') {
        return Center(child: Text(state.message));
      }
      List<Book> books = state.data ?? [];
      return CustomScrollView(
        slivers: [_buildAppBar(context), _buildBookGrid(books, textTheme)],
      );
    },
  );
}

FloatingActionButton _buildChatButton(BuildContext context) {
  return FloatingActionButton.extended(
    onPressed: () {
      pushNavigation(context, destinationPage: ChatbotPage());
    },
    label: Text('Discuss with AI'),
    icon: Icon(Icons.chat),
  );
}

Widget _buildAppBar(BuildContext context) {
  return SliverAppBar(
    expandedHeight: 140,
    collapsedHeight: 140,
    automaticallyImplyLeading: false,
    pinned: true,
    //snap: true,
    floating: true,
    flexibleSpace: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Text(
            'BookVerse App',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              simpleSearcBar(
                context,
                isExpanded: true,
                onTap: pushNavigation(context, destinationPage: SearchPage()),
              ),
              _ActionButton(icon: Icons.settings, onPressed: () {}),
              _ActionButton(icon: Icons.person_2, onPressed: () {}),
            ],
          ),
        ],
      ),
    ),
  );
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _ActionButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: CircleAvatar(radius: 25, child: Icon(icon, size: 30)),
    );
  }
}

Widget _buildBookGrid(List<Book> books, TextTheme textTheme) {
  return SliverPadding(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    sliver: SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      delegate: SliverChildBuilderDelegate((context, index) {
        Book book = books[index];
        return _BuildGridItem(book: book, textTheme: textTheme);
      }, childCount: books.length),
    ),
  );
}

class _BuildGridItem extends StatelessWidget {
  const _BuildGridItem({required this.book, required this.textTheme});

  final TextTheme textTheme;
  final Book book;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: 
        pushNavigation(
          context,
          destinationPage: DetailPage(selectedBookId: book.id),
        )
      ,
      child: bookGridTile(book, textTheme),
    );
  }
}
