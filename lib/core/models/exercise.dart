import 'package:stronger/core/models/enums.dart';

class Exercise {
  final String id;
  final String name;
  final String description;
  final MuscleGroup primaryMuscleGroup;
  final Difficulty difficulty;
  final Equipment equipment;
  final int recommendedReps;
  final int defaultRestSeconds;
  final String notes;

  Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.primaryMuscleGroup,
    required this.difficulty,
    required this.equipment,
    required this.recommendedReps,
    this.defaultRestSeconds = 60, 
    this.notes = "",
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
      'defaultRestSeconds': defaultRestSeconds, 
      'notes': notes,
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      primaryMuscleGroup: MuscleGroup.values.byName(map['primaryMuscleGroup'] as String),
      difficulty: Difficulty.values.byName(map['difficulty'] as String),
      equipment: Equipment.values.byName(map['equipment'] as String),
      recommendedReps: map['recommendedReps'] as int,
      defaultRestSeconds: map['defaultRestSeconds'] as int? ?? 60, 
      notes: map['notes'] as String,
    );
  }
}