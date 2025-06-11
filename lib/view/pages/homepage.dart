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
      body: _buildBookList(textTheme),
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
        slivers: [
          _buildAppBar(context),
          SliverAppBar(
            automaticallyImplyLeading: false,
            toolbarHeight: 360,
            flexibleSpace: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          'More like The Great Shifting - Rhenald Kasali',
                          maxLines: 2,
                          softWrap: true,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.arrow_forward),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 260,
                    child: ListView.separated(
                      physics: BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: 20,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        // TODO : implement real book
                        // Book book = books[index];
                        Book book = Book(
                          id: 'id',
                          title: 'title',
                          subTitle: 'subTitle',
                          authors: ['authors'],
                          publisher: 'publisher',
                          publishedDate: 'publishedDate',
                          description: 'description',
                          thumbnail:
                              'https://imgs.search.brave.com/mBEp4eus0E1w21Ja7IQg_kozkW-Z1G_38RMIPc-hDqc/rs:fit:500:0:0:0/g:ce/aHR0cHM6Ly9pbWdz/LnNlYXJjaC5icmF2/ZS5jb20vc2lVWHFY/b2ZtZE14SElrbWts/Tjdpai0xcWhuT1pL/czNnS0Npb1NfTUJ2/US9yczpmaXQ6NTAw/OjA6MDowL2c6Y2Uv/YUhSMGNITTZMeTlw/YldjdS9abkpsWlhC/cGF5NWpiMjB2L1pu/SmxaUzF3YUc5MGJ5/OWkvYjI5ckxXTnZi/WEJ2YzJsMC9hVzl1/TFhkcGRHZ3RiM0Js/L2JpMWliMjlyWHpJ/ekxUSXgvTkRjMk9U/QTFOVFV1YW5Cbi9Q/M05sYlhROVlXbHpY/Mmg1L1luSnBaQ1oz/UFRjME1B.jpeg',
                          pageCount: 200,
                        );
                        return bookGridTile(
                          book: book,
                          textTheme: Theme.of(context).textTheme,
                        );
                      },
                      separatorBuilder: (context, index) {
                        return SizedBox(width: 8);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
      onTap: pushNavigation(
        context,
        destinationPage: DetailPage(selectedBookId: book.id),
      ),
      child: bookGridTile(book: book, textTheme: textTheme),
    );
  }
}
