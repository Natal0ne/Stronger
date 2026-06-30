import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:stronger/models/enums.dart';
import 'package:stronger/models/exercise.dart';
import 'package:stronger/models/routine.dart';
import 'package:stronger/models/routine_exercise.dart';
import 'package:stronger/services/default_exercises.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('stronger.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onConfigure: _onConfigure,
    );
  }

  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE exercises (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        primaryMuscleGroup TEXT NOT NULL,
        difficulty TEXT NOT NULL,
        equipment TEXT NOT NULL,
        recommendedReps INTEGER NOT NULL,
        notes TEXT NOT NULL DEFAULT ''
      )
    ''');

    await db.execute('''
      CREATE TABLE routines (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        targetGoal TEXT NOT NULL,
        estimatedDurationMinutes TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE routine_exercises (
        routine_id TEXT NOT NULL,
        exercise_id TEXT NOT NULL,
        sets INTEGER NOT NULL DEFAULT 3,
        reps INTEGER NOT NULL DEFAULT 10,
        FOREIGN KEY (routine_id) REFERENCES routines (id) ON DELETE CASCADE,
        FOREIGN KEY (exercise_id) REFERENCES exercises (id) ON DELETE CASCADE,
        PRIMARY KEY (routine_id, exercise_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE workout_sessions (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        date TEXT NOT NULL, 
        routineId TEXT,
        durationMinutes INTEGER NOT NULL,
        status TEXT NOT NULL,
        fatigueLevel INTEGER NOT NULL DEFAULT 0,
        notes TEXT NOT NULL DEFAULT '',
        FOREIGN KEY (routineId) REFERENCES routines (id) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE exercise_sets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id TEXT NOT NULL,
        exercise_id TEXT NOT NULL,
        setNumber INTEGER NOT NULL,
        reps INTEGER NOT NULL, weightKg REAL NOT NULL,
        isCompleted INTEGER NOT NULL DEFAULT 0, 
        FOREIGN KEY (session_id) REFERENCES workout_sessions (id) ON DELETE CASCADE,
        FOREIGN KEY (exercise_id) REFERENCES exercises (id) ON DELETE CASCADE
      )
    ''');

    await _seedDefaultExercises(db);
  }

  // --- CRUD Methods for Routines ---

  Future<void> insertRoutine(Routine routine) async {
    final db = await instance.database;
    await db.transaction((txn) async {
      // Save metadata
      await txn.insert(
        'routines',
        routine.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      // Clear old links
      await txn.delete(
        'routine_exercises',
        where: 'routine_id = ?',
        whereArgs: [routine.id],
      );
      // Insert new links with sets/reps
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

  Future<List<Routine>> getRoutines() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> routineMaps = await db.query(
      'routines',
      orderBy: 'name ASC',
    );
    List<Routine> routines = [];

    for (var routineMap in routineMaps) {
      final String routineId = routineMap['id'] as String;
      // Join to get exercise details and config in one query
      final List<Map<String, dynamic>> junctionMaps = await db.rawQuery(
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

  Future<void> deleteRoutine(String id) async {
    final db = await instance.database;
    await db.delete(
      'routines',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- CRUD Methods for Exercises ---

  Future<void> insertExercise(Exercise exercise) async {
    final db = await instance.database;
    await db.insert(
      'exercises',
      exercise.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteExercise(String id) async {
    final db = await instance.database;
    await db.delete(
      'exercises',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Exercise>> getExercises() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'exercises',
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => Exercise.fromMap(maps[i]));
  }

  Future<void> _seedDefaultExercises(Database db) async {
    for (var exercise in defaultExercisesList) {
      await db.insert(
        'exercises',
        exercise.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore, // Skip if it already exists
      );
    }
  }

  Future close() async {
    (await instance.database).close();
  }
}
