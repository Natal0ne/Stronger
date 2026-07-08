class RoutineExercise {
  final String exerciseId;
  final String name;
  int sets;
  int reps;

  RoutineExercise({
    required this.exerciseId,
    this.name = '',
    required this.sets,
    required this.reps,
  });

  Map<String, dynamic> toMap(String routineId) {
    return {
      'routine_id': routineId,
      'exercise_id': exerciseId,
      'sets': sets,
      'reps': reps,
    };
  }
}
