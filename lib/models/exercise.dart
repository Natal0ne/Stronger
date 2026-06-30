import 'enums.dart';

class Exercise {
  final String id; // Unique ID for the exercise
  final String name;
  final String description; // Brief instructions on how to perform it
  final MuscleGroup primaryMuscleGroup;
  final Difficulty difficulty; // "beginner", "intermediate", "advanced"
  final Equipment equipment; // "dumbbell", "machine", "barbell", "bodyweight"
  final int recommendedReps;
  final String notes; // Optional user notes

  Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.primaryMuscleGroup,
    required this.difficulty,
    required this.equipment,
    required this.recommendedReps,
    this.notes = "", // Empty notes by default
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'primaryMuscleGroup': primaryMuscleGroup.name,
      'difficulty': difficulty.name,
      'equipment': equipment.name,
      'recommendedReps': recommendedReps,
      'notes': notes,
    };
  }

  // Crea un oggetto Esercizio da una Mappa estratta dal DB
  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      primaryMuscleGroup: MuscleGroup.values.byName(
        map['primaryMuscleGroup'] as String,
      ),
      difficulty: Difficulty.values.byName(map['difficulty'] as String),
      equipment: Equipment.values.byName(map['equipment'] as String),
      recommendedReps: map['recommendedReps'] as int,
      notes: map['notes'] as String,
    );
  }
}
