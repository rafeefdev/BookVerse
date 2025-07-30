import 'package:book_verse/core/models/searchstate_model.dart';
import 'package:book_verse/core/services/playbook_services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search_viewmodel.g.dart';

@Riverpod(keepAlive: true)
class SearchNotifier extends _$SearchNotifier {
  final _playbookService = PlaybookServices();
  
  @override
  SearchState build() {
    return SearchState(query: '', result: [], isLoading: false, error: null);
  }

  void resetQuery() {
    SearchState newState = SearchState(query: '', result: []);
    state = newState;
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
      final books = await _playbookService.searchBooks(query);
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
