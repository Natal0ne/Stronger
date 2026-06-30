import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:stronger/models/exercise.dart';
import 'package:stronger/models/exercise_set.dart';
import 'package:stronger/models/routine.dart';
import 'package:stronger/models/routine_exercise.dart';
import 'package:stronger/models/workout_session.dart';
import 'package:stronger/services/default_exercises.dart';
import 'package:stronger/services/default_routines.dart';

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
    await _seedDefaultRoutines(db);
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
    await db.delete('routines', where: 'id = ?', whereArgs: [id]);
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
    await db.delete('exercises', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Exercise>> getExercises() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'exercises',
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => Exercise.fromMap(maps[i]));
  }

  Future<List<RoutineExercise>> getExercisesForRoutine(String routineId) async {
    final db = await instance.database;

    // Usiamo una JOIN per prendere il nome dalla tabella exercises
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
    SELECT
    re.exercise_id,
    re.sets,
    re.reps,
    e.name
    FROM routine_exercises re
    JOIN exercises e ON re.exercise_id = e.id
    WHERE re.routine_id = ?
    ''',
    [routineId],
    );

    return List.generate(maps.length, (i) {
      return RoutineExercise(
        exerciseId: maps[i]['exercise_id'],
        name: maps[i]['name'], // Ecco che il nome arriva dalla JOIN!
        sets: maps[i]['sets'],
        reps: maps[i]['reps'],
      );
    });
  }

  // --- CRUD Methods for Workout Sessions ---

  /// Inserts (or replaces) a workout session together with all of its
  /// performed exercises/sets. The previous sets for this session id
  /// are cleared first so this method is safe to use for both create
  /// and update.
  Future<void> insertWorkoutSession(WorkoutSession session) async {
    final db = await instance.database;
    await db.transaction((txn) async {
      await txn.insert(
        'workout_sessions',
        session.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      await txn.delete(
        'exercise_sets',
        where: 'session_id = ?',
        whereArgs: [session.id],
      );

      for (var performed in session.performedExercises) {
        for (var set in performed.sets) {
          await txn.insert('exercise_sets', {
            'session_id': session.id,
            'exercise_id': performed.exerciseId,
            'setNumber': set.setNumber,
            'reps': set.reps,
            'weightKg': set.weightKg,
            'isCompleted': set.isCompleted ? 1 : 0,
          });
        }
      }
    });
  }

  /// Alias kept for readability when updating an existing session.
  Future<void> updateWorkoutSession(WorkoutSession session) =>
  insertWorkoutSession(session);

  Future<List<WorkoutSession>> getWorkoutSessions() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> sessionMaps = await db.query(
      'workout_sessions',
      orderBy: 'date DESC',
    );

    List<WorkoutSession> sessions = [];
    for (var sessionMap in sessionMaps) {
      final performedExercises = await _getPerformedExercisesForSession(
        db,
        sessionMap['id'] as String,
      );
      sessions.add(WorkoutSession.fromMap(sessionMap, performedExercises));
    }
    return sessions;
  }

  Future<WorkoutSession?> getWorkoutSessionById(String id) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'workout_sessions',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    final performedExercises = await _getPerformedExercisesForSession(db, id);
    return WorkoutSession.fromMap(maps.first, performedExercises);
  }

  Future<List<PerformedExercise>> _getPerformedExercisesForSession(
    Database db,
    String sessionId,
  ) async {
    final List<Map<String, dynamic>> setMaps = await db.query(
      'exercise_sets',
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'exercise_id ASC, setNumber ASC',
    );

    final Map<String, List<ExerciseSet>> grouped = {};
    for (var row in setMaps) {
      final exerciseId = row['exercise_id'] as String;
      grouped.putIfAbsent(exerciseId, () => []).add(
        ExerciseSet(
          setNumber: row['setNumber'] as int,
          reps: row['reps'] as int,
          weightKg: (row['weightKg'] as num).toDouble(),
          isCompleted: (row['isCompleted'] as int) == 1,
        ),
      );
    }

    return grouped.entries
    .map((entry) => PerformedExercise(
      exerciseId: entry.key,
      sets: entry.value,
    ))
    .toList();
  }

  Future<void> deleteWorkoutSession(String id) async {
    final db = await instance.database;
    await db.delete('workout_sessions', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> _seedDefaultExercises(Database db) async {
    for (var exercise in defaultExercisesList) {
      await db.insert(
        'exercises',
        exercise.toMap(),
        conflictAlgorithm:
        ConflictAlgorithm.ignore, // Skip if it already exists
      );
    }
  }

  Future<void> _seedDefaultRoutines(Database db) async {
    for (var routine in defaultRoutinesList) {
      // Inseriamo la routine nella tabella 'routines'
      await db.insert('routines', {
        'id': routine.id,
        'name': routine.name,
        'description': routine.description,
        'targetGoal': routine.goal.name,
        'estimatedDurationMinutes': routine.estimatedDurationMinutes,
      });

      // Inseriamo i collegamenti nella tabella 'routine_exercises'
      for (var routineEx in routine.exercises) {
        await db.insert('routine_exercises', {
          'routine_id': routine.id,
          'exercise_id': routineEx.exerciseId,
          'sets': routineEx.sets,
          'reps': routineEx.reps,
        });
      }
    }
  }

  Future close() async {
    (await instance.database).close();
  }
}
