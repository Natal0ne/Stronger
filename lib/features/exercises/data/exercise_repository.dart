import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:stronger/core/models/exercise.dart';
import 'package:stronger/core/models/routine_exercise.dart';
import 'package:stronger/core/database/database_provider.dart';

final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  // Otteniamo l'istanza del database iniettata sincronicamente da Riverpod
  final db = ref.watch(databaseProvider);
  return ExerciseRepository(db);
});

class ExerciseRepository {
  final Database _db;

  ExerciseRepository(this._db);

  Future<List<Exercise>> getExercises() async {
    final List<Map<String, dynamic>> maps = await _db.query(
      'exercises',
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => Exercise.fromMap(maps[i]));
  }

  Future<void> insertExercise(Exercise exercise) async {
    await _db.insert(
      'exercises',
      exercise.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteExercise(String id) async {
    await _db.delete('exercises', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<RoutineExercise>> getExercisesForRoutine(String routineId) async {
    final List<Map<String, dynamic>> maps = await _db.rawQuery(
      '''
    SELECT re.exercise_id, re.sets, re.reps, e.name
    FROM routine_exercises re
    JOIN exercises e ON re.exercise_id = e.id
    WHERE re.routine_id = ?
    ''',
    [routineId],
    );

    return List.generate(maps.length, (i) {
      return RoutineExercise(
        exerciseId: maps[i]['exercise_id'],
        name: maps[i]['name'],
        sets: maps[i]['sets'],
        reps: maps[i]['reps'],
      );
    });
  }
}
