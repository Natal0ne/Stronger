import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'default_exercises.dart';
import 'default_routines.dart';

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
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
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
      defaultRestSeconds INTEGER NOT NULL DEFAULT 60, -- <--- AGGIUNGI QUESTO!
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
      reps INTEGER NOT NULL,
      weightKg REAL NOT NULL,
      isCompleted INTEGER NOT NULL DEFAULT 0,
      FOREIGN KEY (session_id) REFERENCES workout_sessions (id) ON DELETE CASCADE,
      FOREIGN KEY (exercise_id) REFERENCES exercises (id) ON DELETE CASCADE
    )
    ''');

    await db.execute('''
    CREATE TABLE recurring_schedules (
      id TEXT PRIMARY KEY,
      routineId TEXT NOT NULL,
      weekday INTEGER NOT NULL,
      title TEXT NOT NULL,
      durationMinutes INTEGER NOT NULL,
      notes TEXT NOT NULL DEFAULT '',
      FOREIGN KEY (routineId) REFERENCES routines (id) ON DELETE CASCADE,
      UNIQUE(weekday)
    )
    ''');

    await db.execute('''
    CREATE TABLE goals (
      id TEXT PRIMARY KEY,
      title TEXT NOT NULL,
      description TEXT NOT NULL DEFAULT '',
      category TEXT NOT NULL,
      startingValue REAL NOT NULL DEFAULT 0.0,
      targetValue REAL NOT NULL,
      currentValue REAL NOT NULL,
      startDate TEXT NOT NULL,
      endDate TEXT,
      status TEXT NOT NULL,
      notes TEXT NOT NULL DEFAULT ''
    )
    ''');

    await _seedDefaultExercises(db);
    await _seedDefaultRoutines(db);
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
      CREATE TABLE IF NOT EXISTS recurring_schedules (
        id TEXT PRIMARY KEY,
        routineId TEXT NOT NULL,
        weekday INTEGER NOT NULL,
        title TEXT NOT NULL,
        durationMinutes INTEGER NOT NULL,
        notes TEXT NOT NULL DEFAULT '',
        FOREIGN KEY (routineId) REFERENCES routines (id) ON DELETE CASCADE,
        UNIQUE(weekday)
      )
      ''');
    }
  }

  Future<void> _seedDefaultExercises(Database db) async {
    for (var exercise in defaultExercisesList) {
      await db.insert(
        'exercises',
        exercise.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  Future<void> _seedDefaultRoutines(Database db) async {
    for (var routine in defaultRoutinesList) {
      await db.insert('routines', {
        'id': routine.id,
        'name': routine.name,
        'description': routine.description,
        'targetGoal': routine.goal.name,
        'estimatedDurationMinutes': routine.estimatedDurationMinutes,
      });

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
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
