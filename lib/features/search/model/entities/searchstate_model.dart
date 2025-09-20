import 'package:book_verse/core/models/book_model.dart';

class SearchState {
  final String query;
  final List<Book> result;
  final bool isLoading;
  final String? error;

  SearchState({
    required this.query,
    required this.result,
    this.isLoading = false,
    this.error,
  });
}
