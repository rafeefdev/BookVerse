import 'package:flutter_test/flutter_test.dart';
import 'package:book_verse/core/models/book_model.dart';

void main() {
  group('Book.fromJson', () {
    test('Google API format with volumeInfo', () {
      final json = {
        'id': 'abc123',
        'volumeInfo': {
          'title': 'The Great Gatsby',
          'subtitle': 'A Novel',
          'authors': ['F. Scott Fitzgerald'],
          'publisher': 'Scribner',
          'publishedDate': '1925-04-10',
          'description': 'A story of the jazz age.',
          'pageCount': 180,
          'categories': ['Fiction', 'Classics'],
          'imageLinks': {'thumbnail': 'http://example.com/cover.jpg'},
        },
      };
      final book = Book.fromJson(json);
      expect(book.id, 'abc123');
      expect(book.title, 'The Great Gatsby');
      expect(book.subTitle, 'A Novel');
      expect(book.authors, ['F. Scott Fitzgerald']);
      expect(book.publisher, 'Scribner');
      expect(book.publishedDate, '1925-04-10');
      expect(book.description, 'A story of the jazz age.');
      expect(book.pageCount, 180);
      expect(book.categories, ['Fiction', 'Classics']);
      expect(book.thumbnail, 'http://example.com/cover.jpg');
      expect(book.isFavorite, false);
    });

    test('flat DB format without volumeInfo', () {
      final json = {
        'id': 'abc123',
        'title': '1984',
        'subTitle': '',
        'authors': '["George Orwell"]',
        'publisher': 'Secker & Warburg',
        'publishedDate': '1949',
        'description': 'Dystopian novel.',
        'pageCount': 328,
        'categories': '["Fiction"]',
        'thumbnail': '',
        'isFavorite': 1,
      };
      final book = Book.fromJson(json);
      expect(book.id, 'abc123');
      expect(book.title, '1984');
      expect(book.authors, ['George Orwell']);
      expect(book.categories, ['Fiction']);
      expect(book.isFavorite, true);
    });

    test('missing optional fields use defaults', () {
      final json = {
        'id': 'b1',
        'volumeInfo': {'title': 'Minimal'},
      };
      final book = Book.fromJson(json);
      expect(book.title, 'Minimal');
      expect(book.subTitle, '');
      expect(book.authors, []);
      expect(book.publisher, 'Unknown Publisher');
      expect(book.publishedDate, 'Unknown Date');
      expect(book.description, 'No Description');
      expect(book.thumbnail, '');
      expect(book.pageCount, 0);
      expect(book.categories, []);
      expect(book.isFavorite, false);
    });

    test('null id in json throws TypeError (code assumes id always present)', () {
      expect(
        () => Book.fromJson({'id': null}),
        throwsA(isA<TypeError>()),
      );
    });

    test('authors as malformed JSON string returns empty list', () {
      final json = {
        'id': 'b1',
        'volumeInfo': {'authors': 'not-a-list'},
      };
      final book = Book.fromJson(json);
      expect(book.authors, []);
    });

    test('authors as non-list non-string returns empty list', () {
      final json = {
        'id': 'b1',
        'volumeInfo': {'authors': 42},
      };
      final book = Book.fromJson(json);
      expect(book.authors, []);
    });

    test('thumbnail from volumeInfo.imageLinks.thumbnail', () {
      final json = {
        'id': 'b1',
        'volumeInfo': {
          'imageLinks': {'thumbnail': 'http://example.com/img.jpg'},
        },
      };
      final book = Book.fromJson(json);
      expect(book.thumbnail, 'http://example.com/img.jpg');
    });

    test('no volumeInfo key uses flat json directly', () {
      final json = {
        'id': 'b1',
        'thumbnail': 'http://example.com/thumb.jpg',
      };
      final book = Book.fromJson(json);
      expect(book.thumbnail, 'http://example.com/thumb.jpg');
    });

    test('empty volumeInfo uses volumeInfo scope, not flat json', () {
      // When volumeInfo exists (even empty), the code uses it as `info`,
      // so flat keys like 'thumbnail' are not consulted.
      final json = {
        'id': 'b1',
        'volumeInfo': {},
        'thumbnail': 'http://example.com/fallback.jpg',
      };
      final book = Book.fromJson(json);
      expect(book.thumbnail, '');
    });

    test('isFavorite from int 1 is true', () {
      final json = {
        'id': 'b1',
        'volumeInfo': {'isFavorite': 1},
      };
      final book = Book.fromJson(json);
      expect(book.isFavorite, true);
    });

    test('isFavorite from bool is true', () {
      final json = {
        'id': 'b1',
        'volumeInfo': {'isFavorite': true},
      };
      final book = Book.fromJson(json);
      expect(book.isFavorite, true);
    });
  });

  group('Book.toMap', () {
    test('roundtrip preserves all fields', () {
      final book = Book(
        id: 'b1',
        title: 'Test',
        subTitle: 'Sub',
        authors: ['Author A', 'Author B'],
        publisher: 'Pub',
        publishedDate: '2020',
        description: 'Desc',
        thumbnail: 'http://example.com/img.jpg',
        pageCount: 200,
        categories: ['Fiction'],
        isFavorite: true,
      );
      final map = book.toMap();
      expect(map['id'], 'b1');
      expect(map['title'], 'Test');
      expect(map['subTitle'], 'Sub');
      expect(map['pageCount'], 200);
      expect(map['publisher'], 'Pub');
      expect(map['publishedDate'], '2020');
      expect(map['description'], 'Desc');
      expect(map['thumbnail'], 'http://example.com/img.jpg');
      expect(map['isFavorite'], 1);
      // authors and categories are JSON-encoded strings
      expect(map['authors'], isA<String>());
      expect(map['categories'], isA<String>());
    });
  });

  group('Book.generateInternalId', () {
    test('produces deterministic UUID for same googleBooksId', () {
      final id1 = Book.generateInternalId('abc123');
      final id2 = Book.generateInternalId('abc123');
      expect(id1, id2);
    });

    test('produces different UUID for different googleBooksId', () {
      final id1 = Book.generateInternalId('abc123');
      final id2 = Book.generateInternalId('xyz789');
      expect(id1, isNot(id2));
    });
  });

  group('Book.copyWith', () {
    test('preserves unchanged fields', () {
      final original = Book(
        id: 'b1',
        title: 'Original',
        subTitle: '',
        authors: ['Author'],
        publisher: 'Pub',
        publishedDate: '2020',
        description: 'Desc',
        thumbnail: '',
        pageCount: 100,
      );
      final updated = original.copyWith(title: 'Updated');
      expect(updated.title, 'Updated');
      expect(updated.id, 'b1');
      expect(updated.authors, ['Author']);
    });
  });
}
