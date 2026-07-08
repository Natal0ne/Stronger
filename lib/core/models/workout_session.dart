import 'package:stronger/core/models/exercise_set.dart';
import 'enums.dart';

class PerformedExercise {
  final String exerciseId;
  final List<ExerciseSet> sets;

  PerformedExercise({required this.exerciseId, required this.sets});
}

class WorkoutSession {
  final String id;
  final String title;
  final DateTime date;
  final String routineId;

  final List<PerformedExercise> performedExercises;

  final int durationMinutes;
  final WorkoutStatus status;
  final int fatigueLevel;
  final String notes;

  WorkoutSession({
    required this.id,
    required this.title,
    required this.date,
    required this.routineId,
    required this.performedExercises,
    required this.durationMinutes,
    required this.status,
    this.fatigueLevel = 0,
    this.notes = "",
  });

  double get totalVolumeLifted {
    double total = 0.0;
    for (var exercise in performedExercises) {
      for (var set in exercise.sets) {
        if (set.isCompleted) {
          total += set.weightKg * set.reps;
        }
      }
    }
    return total;
  }

  int get totalCompletedSets {
    int count = 0;
    for (var exercise in performedExercises) {
      count += exercise.sets.where((s) => s.isCompleted).length;
    }
    return count;
  }

  WorkoutSession copyWith({
    String? title,
    DateTime? date,
    String? routineId,
    List<PerformedExercise>? performedExercises,
    int? durationMinutes,
    WorkoutStatus? status,
    int? fatigueLevel,
    String? notes,
  }) {
    return WorkoutSession(
      id: id,
      title: title ?? this.title,
      date: date ?? this.date,
      routineId: routineId ?? this.routineId,
      performedExercises: performedExercises ?? this.performedExercises,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      status: status ?? this.status,
      fatigueLevel: fatigueLevel ?? this.fatigueLevel,
      notes: notes ?? this.notes,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'routineId': routineId.isEmpty ? null : routineId,
      'durationMinutes': durationMinutes,
      'status': status.name,
      'fatigueLevel': fatigueLevel,
      'notes': notes,
    };
  }

  factory WorkoutSession.fromMap(
    Map<String, dynamic> map,
    List<PerformedExercise> performedExercises,
  ) {
    return WorkoutSession(
      id: map['id'] as String,
      title: map['title'] as String,
      date: DateTime.parse(map['date'] as String),
      routineId: (map['routineId'] as String?) ?? '',
      performedExercises: performedExercises,
      durationMinutes: map['durationMinutes'] as int,
      status: WorkoutStatus.values.byName(map['status'] as String),
      fatigueLevel: map['fatigueLevel'] as int,
      notes: map['notes'] as String,
    );
  }
}
