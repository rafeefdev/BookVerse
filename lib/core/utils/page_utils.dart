import 'package:book_verse/features/reading_tracker/model/reading_session_model.dart';

// Duration formatting
String formatMinutes(int minutes) {
  if (minutes < 60) return '${minutes}m';
  final h = minutes ~/ 60;
  final m = minutes % 60;
  return m > 0 ? '${h}h ${m}m' : '${h}h';
}

String formatHours(int totalMinutes) {
  final hours = totalMinutes ~/ 60;
  final mins = totalMinutes % 60;
  if (hours > 0) return '${hours}h ${mins}m';
  return '${mins}m';
}

String monthLabel(int month) {
  const labels = [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return labels[month];
}

int computePagesInRange(
  List<ReadingSessionModel> rangeSessions,
  List<ReadingSessionModel> allSessions,
  DateTime rangeStart,
) {
  final byBook = <String, List<ReadingSessionModel>>{};
  for (final s in rangeSessions) {
    byBook.putIfAbsent(s.bookId, () => []).add(s);
  }

  int total = 0;
  for (final entry in byBook.entries) {
    final bookSessions = entry.value
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final before =
        allSessions
            .where(
              (s) => s.bookId == entry.key && s.timestamp.isBefore(rangeStart),
            )
            .toList()
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final prevEndPage = before.isNotEmpty ? before.last.endPage : 0;

    int prevPage = prevEndPage;
    int bookTotal = 0;
    for (final session in bookSessions) {
      final start = session.startPage ?? prevPage;
      bookTotal += (session.endPage - start).clamp(0, session.endPage);
      prevPage = session.endPage;
    }
    total += bookTotal;
  }
  return total;
}

int computeAllTimePages(List<ReadingSessionModel> allSessions) {
  final byBook = <String, List<ReadingSessionModel>>{};
  for (final s in allSessions) {
    byBook.putIfAbsent(s.bookId, () => []).add(s);
  }

  int total = 0;
  for (final entry in byBook.entries) {
    final bookSessions = entry.value
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    int prevPage = 0;
    int bookTotal = 0;
    for (final session in bookSessions) {
      final start = session.startPage ?? prevPage;
      bookTotal += (session.endPage - start).clamp(0, session.endPage);
      prevPage = session.endPage;
    }
    total += bookTotal;
  }
  return total;
}
