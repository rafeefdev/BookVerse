import 'package:BookVerse/model/book_model.dart';
import 'package:BookVerse/model/searchstate_model.dart';
import 'package:BookVerse/source/playbook_services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search_provider.g.dart';

@Riverpod(keepAlive: true)
class SearchNotifier extends _$SearchNotifier {
  PlaybookServices playbookService = PlaybookServices();
  
  @override
  SearchState build() {
    return SearchState(query: '', result: [], isLoading: false, error: null);
  }

  Future<void> onQueryChanged(String query) async {
    if (query.isEmpty) {
      state = SearchState(query: query, result: [], isLoading: false, error: null);
      return;
    }

    state = SearchState(
      query: query,
      result: state.result,
      isLoading: true,
      error: null,
    );

    try {
      final books = await playbookService.searchBooks(query);
      state = SearchState(
        query: query,
        result: books ?? [],
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = SearchState(
        query: query,
        result: [],
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}
