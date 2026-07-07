import 'enums.dart';
import 'routine_exercise.dart';

class Routine {
  final String id;
  final String name;
  final String description;
  final RoutineGoal goal;
  final String estimatedDurationMinutes;
  final List<RoutineExercise> exercises;

  Routine({
    required this.id,
    required this.name,
    required this.description,
    required this.goal,
    required this.estimatedDurationMinutes,
    required this.exercises,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'targetGoal': goal.name,
      'estimatedDurationMinutes': estimatedDurationMinutes,
    };
  }

  factory Routine.fromMap(
    Map<String, dynamic> map,
    List<RoutineExercise> exercises,
  ) {
    return Routine(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      goal: RoutineGoal.values.byName(map['targetGoal'] as String),
      estimatedDurationMinutes: map['estimatedDurationMinutes'] as String,
      exercises: exercises,
    );
  }
}
