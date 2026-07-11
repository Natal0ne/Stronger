import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:stronger/core/models/workout_session.dart';
import 'package:stronger/core/models/exercise_set.dart';
import 'package:stronger/core/models/enums.dart';
import 'package:stronger/core/models/recurring_schedule.dart';
import 'package:stronger/core/database/database_provider.dart';

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return SessionRepository(db);
});

class SessionRepository {
  final Database _db;

  SessionRepository(this._db);

  Future<void> _checkAndMarkSkippedWorkouts() async {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);

    await _db.update(
      'workout_sessions',
      {'status': WorkoutStatus.skipped.name},
      where: 'status = ? AND date < ?',
      whereArgs: [WorkoutStatus.scheduled.name, startOfToday.toIso8601String()],
    );
  }

  Future<List<WorkoutSession>> getWorkoutSessions() async {
    await _checkAndMarkSkippedWorkouts();

    final List<Map<String, dynamic>> sessionMaps = await _db.query(
      'workout_sessions',
      orderBy: 'date DESC',
    );

    List<WorkoutSession> sessions = [];
    for (var sessionMap in sessionMaps) {
      final performedExercises = await _getPerformedExercisesForSession(
        sessionMap['id'] as String,
      );
      sessions.add(WorkoutSession.fromMap(sessionMap, performedExercises));
    }
    return sessions;
  }

  Future<List<WorkoutSession>> getScheduledSessionsForWeek(DateTime date) async {
    await _checkAndMarkSkippedWorkouts();

    final weekStart = _startOfWeek(date);
    await ensureRecurringSessionsForWeek(weekStart);
    final weekEnd = weekStart.add(const Duration(days: 7));

    final sessionMaps = await _db.query(
      'workout_sessions',
      where: 'status = ? AND date >= ? AND date < ?',
      whereArgs: [
        WorkoutStatus.scheduled.name,
        weekStart.toIso8601String(),
        weekEnd.toIso8601String(),
      ],
      orderBy: 'date ASC',
    );

    List<WorkoutSession> sessions = [];
    for (var sessionMap in sessionMaps) {
      final performedExercises = await _getPerformedExercisesForSession(
        sessionMap['id'] as String,
      );
      sessions.add(WorkoutSession.fromMap(sessionMap, performedExercises));
    }
    return sessions;
  }

  Future<void> deleteWorkoutSession(String id) async {
    await _db.delete('workout_sessions', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> insertWorkoutSession(WorkoutSession session) async {
    await _db.transaction((txn) async {
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

  Future<void> ensureRecurringSessionsForWeek(DateTime weekStart) async {
    final normalizedStart = _startOfWeek(weekStart);
    final recurring = await getRecurringSchedules();
    if (recurring.isEmpty) return;

    for (final template in recurring) {
      final dayOffset = template.weekday - 1;
      final day = normalizedStart.add(Duration(days: dayOffset));
      final existing = await _getSessionsForDayUnchecked(day);
      if (existing.isNotEmpty) continue;

      final session = WorkoutSession(
        id: 'recur_${template.id}_${day.year}${day.month}${day.day}',
        title: template.title,
        date: DateTime(day.year, day.month, day.day, 8),
        routineId: template.routineId,
        performedExercises: const [],
        durationMinutes: template.durationMinutes,
        status: WorkoutStatus.scheduled,
        notes: template.notes,
      );
      await insertWorkoutSession(session);
    }
  }

  Future<List<RecurringSchedule>> getRecurringSchedules() async {
    final maps = await _db.query(
      'recurring_schedules',
      orderBy: 'weekday ASC',
    );
    return maps.map(RecurringSchedule.fromMap).toList();
  }

  Future<void> deleteRecurringScheduleForWeekday(int weekday) async {
    await _db.transaction((txn) async {
      await txn.delete(
        'recurring_schedules',
        where: 'weekday = ?',
        whereArgs: [weekday],
      );

      await txn.delete(
        'workout_sessions',
        where: 'id LIKE ? AND status = ?',
        whereArgs: ['%recur_recur_$weekday%', WorkoutStatus.scheduled.name],
      );
    });
  }

  Future<void> upsertRecurringSchedule(RecurringSchedule schedule) async {
    await _db.insert(
      'recurring_schedules',
      schedule.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, List<ExerciseSet>>> getLastWorkoutSetsByExercise() async {
    final sessions = await getWorkoutSessions();
    final map = <String, List<ExerciseSet>>{};

    for (final session in sessions) {
      if (session.status != WorkoutStatus.completed) continue;
      for (final pe in session.performedExercises) {
        if (map.containsKey(pe.exerciseId)) continue;

        final completedSets = pe.sets.where((s) => s.isCompleted).toList();
        if (completedSets.isNotEmpty) {
          map[pe.exerciseId] = completedSets;
        }
      }
    }
    return map;
  }

  Future<List<PerformedExercise>> _getPerformedExercisesForSession(
    String sessionId,
  ) async {
    final List<Map<String, dynamic>> setMaps = await _db.query(
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
          isCompleted: row['isCompleted'] == 1 || row['isCompleted'] == true,
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

  Future<List<WorkoutSession>> _getSessionsForDayUnchecked(DateTime day) async {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    final sessionMaps = await _db.query(
      'workout_sessions',
      where: 'date >= ? AND date < ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'date ASC',
    );

    final sessions = <WorkoutSession>[];
    for (var sessionMap in sessionMaps) {
      final performedExercises = await _getPerformedExercisesForSession(
        sessionMap['id'] as String,
      );
      sessions.add(WorkoutSession.fromMap(sessionMap, performedExercises));
    }
    return sessions;
  }

  Future<List<double>> getExerciseWeightHistory(String exerciseId) async {
    final sessions = await getWorkoutSessions();
    final history = <double>[];

    for (final session in sessions) {
      if (session.status != WorkoutStatus.completed) continue;
      for (final pe in session.performedExercises) {
        if (pe.exerciseId == exerciseId) {

          double maxWeight = 0;
          for (final s in pe.sets) {
            if (s.isCompleted && s.weightKg > maxWeight) {
              maxWeight = s.weightKg;
            }
          }
          if (maxWeight > 0) {
            history.add(maxWeight);
          }
          break;
        }
      }
      if (history.length >= 4) break;
    }
    return history.reversed.toList();
  }

  Future<ExerciseSet?> getBestSetForExerciseBeforeDate(String exerciseId, DateTime date) async {
    final sessions = await getWorkoutSessions();
    ExerciseSet? bestSet;

    for (final session in sessions) {
      if (session.status != WorkoutStatus.completed) continue;

      if (!session.date.isBefore(date)) continue;

      for (final pe in session.performedExercises) {
        if (pe.exerciseId == exerciseId) {
          for (final s in pe.sets) {
            if (s.isCompleted) {
              if (bestSet == null) {
                bestSet = s;
              } else {
                final currentBestWeight = bestSet.weightKg;
                final currentBestReps = bestSet.reps;

                if (s.weightKg > currentBestWeight ||
                  (s.weightKg == currentBestWeight && s.reps > currentBestReps)) {
                  bestSet = s;
                  }
              }
            }
          }
        }
      }
    }
    return bestSet;
  }

  DateTime _startOfWeek(DateTime date) {
    final weekday = date.weekday;
    return DateTime(date.year, date.month, date.day - (weekday - 1));
  }
}
