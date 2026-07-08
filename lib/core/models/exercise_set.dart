class ExerciseSet {
  final int setNumber; // e.g., 1, 2, 3, 4
  final int reps;
  final double weightKg;
  final bool isCompleted;

  ExerciseSet({
    required this.setNumber,
    required this.reps,
    required this.weightKg,
    this.isCompleted = false,
  });
}
