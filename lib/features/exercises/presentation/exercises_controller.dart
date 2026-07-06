import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronger/core/models/enums.dart';
import 'package:stronger/core/models/exercise.dart';
import 'package:stronger/features/exercises/data/exercise_repository.dart';

// 1. Provider per i filtri (inizialmente vuoti/nulli)
final searchFilterProvider = StateProvider<String>((ref) => '');
final muscleFilterProvider = StateProvider<MuscleGroup?>((ref) => null);
final difficultyFilterProvider = StateProvider<Difficulty?>((ref) => null);
final equipmentFilterProvider = StateProvider<Equipment?>((ref) => null);

// 2. Controller per gestire il CRUD (Carica, Aggiunge, Elimina)
class ExercisesNotifier extends AsyncNotifier<List<Exercise>> {
  @override
  Future<List<Exercise>> build() async {
    // Carica gli esercizi all'avvio
    return ref.read(exerciseRepositoryProvider).getExercises();
  }

  Future<void> addExercise(Exercise exercise) async {
    // Inserisce nel DB e poi ricarica la lista
    await ref.read(exerciseRepositoryProvider).insertExercise(exercise);
    ref.invalidateSelf(); // Ricarica i dati (triggera la UI)
  }

  Future<void> deleteExercise(String id) async {
    await ref.read(exerciseRepositoryProvider).deleteExercise(id);
    ref.invalidateSelf(); // Ricarica i dati
  }
}

final exercisesProvider = AsyncNotifierProvider<ExercisesNotifier, List<Exercise>>(
  ExercisesNotifier.new,
);

// 3. LA MAGIA: Il Provider per la lista filtrata.
// Si aggiorna in automatico ogni volta che un filtro o la lista principale cambiano.
final filteredExercisesProvider = Provider<AsyncValue<List<Exercise>>>((ref) {
  final asyncExercises = ref.watch(exercisesProvider);
  final search = ref.watch(searchFilterProvider).toLowerCase();
  final muscle = ref.watch(muscleFilterProvider);
  final difficulty = ref.watch(difficultyFilterProvider);
  final equipment = ref.watch(equipmentFilterProvider);

  // Se asyncExercises ha i dati, applichiamo i filtri
  return asyncExercises.whenData((exercises) {
    return exercises.where((ex) {
      final matchesSearch = ex.name.toLowerCase().contains(search) ||
      ex.description.toLowerCase().contains(search);
      final matchesMuscle = muscle == null || ex.primaryMuscleGroup == muscle;
      final matchesDifficulty = difficulty == null || ex.difficulty == difficulty;
      final matchesEquipment = equipment == null || ex.equipment == equipment;

      return matchesSearch && matchesMuscle && matchesDifficulty && matchesEquipment;
    }).toList();
  });
});
