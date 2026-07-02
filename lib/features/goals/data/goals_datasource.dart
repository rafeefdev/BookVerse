import 'dart:developer';
import 'package:book_verse/core/database/database_constants.dart';
import 'package:book_verse/core/database/database_provider.dart';
import 'package:book_verse/features/goals/model/reading_goal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

final goalsDatasourceProvider = Provider<GoalsDatasource>((ref) {
  return GoalsDatasource(ref.watch(databaseProvider));
});

class GoalsDatasource {
  final Database _db;

  GoalsDatasource(this._db);

  Future<DailyGoal?> getGoal() async {
    try {
      final maps = await _db.query(readingGoalsTable, where: 'id = 1');
      if (maps.isNotEmpty) return DailyGoal.fromJson(maps.first);
      return null;
    } catch (e, stack) {
      log('GoalsDatasource.getGoal error: $e\n$stack');
      return null;
    }
  }

  Future<void> saveGoal(DailyGoal goal) async {
    try {
      await _db.insert(
        readingGoalsTable,
        goal.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e, stack) {
      log('GoalsDatasource.saveGoal error: $e\n$stack');
    }
  }

  Future<void> deleteGoal() async {
    try {
      await _db.delete(readingGoalsTable, where: 'id = 1');
    } catch (e, stack) {
      log('GoalsDatasource.deleteGoal error: $e\n$stack');
    }
  }
}
