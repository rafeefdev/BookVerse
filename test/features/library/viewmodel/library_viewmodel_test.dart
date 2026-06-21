import 'package:book_verse/core/models/book_model.dart';
import 'package:book_verse/features/library/model/library_repo_di.dart';
import 'package:book_verse/features/library/viewmodel/library_viewmodel.dart';
import 'package:book_verse/features/reading_tracker/model/reading_progress_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/test_providers.dart';

void main() {
  late MockLibraryRepo mockRepo;
  late MockBookmarkDatasource mockBookmark;
  late MockLibraryFolderDatasource mockFolder;

  setUp(() {
    mockRepo = MockLibraryRepo();
    mockBookmark = MockBookmarkDatasource();
    mockFolder = MockLibraryFolderDatasource();

    when(() => mockRepo.getAllFolders()).thenAnswer((_) async => []);
  });

  ProviderContainer createContainer() {
    return createTestContainer(
      bookmarkDatasource: mockBookmark,
      libraryFolderDatasource: mockFolder,
      additionalOverrides: [
        libraryRepoProvider.overrideWithValue(mockRepo),
      ],
    );
  }

  group('LibraryNotifier - effectivePageCount', () {
    test('finished when userPageCount < book.pageCount and currentPage >= userPageCount',
        () async {
      final book = Book(
        id: 'b1',
        title: 'Test Book',
        subTitle: '',
        authors: [],
        publisher: '',
        publishedDate: '',
        description: '',
        thumbnail: '',
        pageCount: 300,
      );
      when(() => mockRepo.getAllProgressWithBooks()).thenAnswer(
        (_) async => [
          ReadingProgressModel(
            bookId: 'b1',
            currentPage: 260,
            book: book,
            userPageCount: 250,
          ),
        ],
      );

      final container = createContainer();
      final state = await container.read(libraryNotifierProvider.future);

      expect(state.finished, hasLength(1));
      expect(state.currentlyReading, isEmpty);
    });

    test('currentlyReading when userPageCount > book.pageCount and currentPage < userPageCount',
        () async {
      final book = Book(
        id: 'b1',
        title: 'Test Book',
        subTitle: '',
        authors: [],
        publisher: '',
        publishedDate: '',
        description: '',
        thumbnail: '',
        pageCount: 300,
      );
      when(() => mockRepo.getAllProgressWithBooks()).thenAnswer(
        (_) async => [
          ReadingProgressModel(
            bookId: 'b1',
            currentPage: 320,
            book: book,
            userPageCount: 350,
          ),
        ],
      );

      final container = createContainer();
      final state = await container.read(libraryNotifierProvider.future);

      expect(state.currentlyReading, hasLength(1));
      expect(state.finished, isEmpty);
    });

    test('finished when currentPage equals effectivePageCount', () async {
      final book = Book(
        id: 'b1',
        title: 'Test Book',
        subTitle: '',
        authors: [],
        publisher: '',
        publishedDate: '',
        description: '',
        thumbnail: '',
        pageCount: 300,
      );
      when(() => mockRepo.getAllProgressWithBooks()).thenAnswer(
        (_) async => [
          ReadingProgressModel(
            bookId: 'b1',
            currentPage: 300,
            book: book,
          ),
        ],
      );

      final container = createContainer();
      final state = await container.read(libraryNotifierProvider.future);

      expect(state.finished, hasLength(1));
      expect(state.currentlyReading, isEmpty);
    });

    test('currentlyReading when userPageCount > 0 and currentPage is 0', () async {
      final book = Book(
        id: 'b1',
        title: 'Test Book',
        subTitle: '',
        authors: [],
        publisher: '',
        publishedDate: '',
        description: '',
        thumbnail: '',
        pageCount: 300,
      );
      when(() => mockRepo.getAllProgressWithBooks()).thenAnswer(
        (_) async => [
          ReadingProgressModel(
            bookId: 'b1',
            currentPage: 0,
            book: book,
            userPageCount: 250,
          ),
        ],
      );

      final container = createContainer();
      final state = await container.read(libraryNotifierProvider.future);

      expect(state.currentlyReading, hasLength(1));
      expect(state.finished, isEmpty);
    });

    test('excludes progress with null book from both lists', () async {
      when(() => mockRepo.getAllProgressWithBooks()).thenAnswer(
        (_) async => [
          ReadingProgressModel(
            bookId: 'b1',
            currentPage: 100,
            book: null,
          ),
        ],
      );

      final container = createContainer();
      final state = await container.read(libraryNotifierProvider.future);

      expect(state.currentlyReading, isEmpty);
      expect(state.finished, isEmpty);
    });
  });
}
