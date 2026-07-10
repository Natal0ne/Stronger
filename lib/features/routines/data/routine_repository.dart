import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:stronger/core/models/routine.dart';
import 'package:stronger/core/models/routine_exercise.dart';
import 'package:stronger/core/database/database_provider.dart';

final routineRepositoryProvider = Provider<RoutineRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return RoutineRepository(db);
});

class RoutineRepository {
  final Database _db;

  RoutineRepository(this._db);

  Future<List<Routine>> getRoutines() async {
    final List<Map<String, dynamic>> routineMaps = await _db.query(
      'routines',
      orderBy: 'name ASC',
    );
    List<Routine> routines = [];

    for (var routineMap in routineMaps) {
      final String routineId = routineMap['id'] as String;
      final List<Map<String, dynamic>> junctionMaps = await _db.rawQuery(
        '''
      SELECT re.exercise_id, re.sets, re.reps, e.name
      FROM routine_exercises re
      JOIN exercises e ON re.exercise_id = e.id
      WHERE re.routine_id = ?
      ''',
        [routineId],
      );

      List<RoutineExercise> exercises = junctionMaps
          .map(
            (row) => RoutineExercise(
              exerciseId: row['exercise_id'] as String,
              name: row['name'] as String,
              sets: row['sets'] as int,
              reps: row['reps'] as int,
            ),
          )
          .toList();

      routines.add(Routine.fromMap(routineMap, exercises));
    }
    return routines;
  }

  Future<void> insertRoutine(Routine routine) async {
    await _db.transaction((txn) async {
      await txn.insert(
        'routines',
        routine.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await txn.delete(
        'routine_exercises',
        where: 'routine_id = ?',
        whereArgs: [routine.id],
      );
      for (var ex in routine.exercises) {
        await txn.insert('routine_exercises', {
          'routine_id': routine.id,
          'exercise_id': ex.exerciseId,
          'sets': ex.sets,
          'reps': ex.reps,
        });
      }
    });
  }

  Future<void> deleteRoutine(String id) async {
    await _db.delete('routines', where: 'id = ?', whereArgs: [id]);
  }
}
