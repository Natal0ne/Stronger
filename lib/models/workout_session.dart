import 'package:stronger/models/exercise_set.dart';
import 'enums.dart';

class PerformedExercise {
  final String exerciseId;
  final List<ExerciseSet> sets;

  PerformedExercise({required this.exerciseId, required this.sets});
}

class WorkoutSession {
  final String id;
  final String title; // Example: "Monday Workout - Chest"
  final DateTime date; // Date and time of the workout
  final String routineId; // Reference to the routine used

  final List<PerformedExercise> performedExercises;

  final int durationMinutes; // Actual duration of the workout
  final WorkoutStatus status; // "Scheduled", "Completed", "Skipped"
  final int fatigueLevel; // RPE / Fatigue level from 1 to 5
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
}
