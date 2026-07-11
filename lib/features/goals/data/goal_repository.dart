import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:stronger/core/models/goal.dart';
import 'package:stronger/core/database/database_provider.dart';

final goalRepositoryProvider = Provider<GoalRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return GoalRepository(db);
});

class GoalRepository {
  final Database _db;

  GoalRepository(this._db);

  Future<List<Goal>> getGoals() async {
    final List<Map<String, dynamic>> maps = await _db.query(
      'goals',
      orderBy: 'startDate DESC',
    );
    return List.generate(maps.length, (i) => Goal.fromMap(maps[i]));
  }

  Future<void> insertGoal(Goal goal) async {
    await _db.insert(
      'goals',
      goal.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteGoal(String id) async {
    await _db.delete('goals', where: 'id = ?', whereArgs: [id]);
  }
}