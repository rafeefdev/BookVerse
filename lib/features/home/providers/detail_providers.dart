import 'package:book_verse/core/models/book_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final bookCacheProvider = StateProvider<Map<String, Book>>((ref) => {});
