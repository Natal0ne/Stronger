import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronger/core/models/routine.dart';
import 'package:stronger/features/routines/data/routine_repository.dart';

class RoutinesNotifier extends AsyncNotifier<List<Routine>> {
  @override
  Future<List<Routine>> build() async {
    return ref.read(routineRepositoryProvider).getRoutines();
  }

  Future<void> addRoutine(Routine routine) async {
    await ref.read(routineRepositoryProvider).insertRoutine(routine);
    ref.invalidateSelf();
  }

  Future<void> deleteRoutine(String id) async {
    await ref.read(routineRepositoryProvider).deleteRoutine(id);
    ref.invalidateSelf();
  }

  Future<void> duplicateRoutine(Routine routine) async {
    final duplicated = Routine(
      id: 'routine_copy_${DateTime.now().millisecondsSinceEpoch}',
      name: '${routine.name} (Copy)',
      description: routine.description,
      goal: routine.goal,
      estimatedDurationMinutes: routine.estimatedDurationMinutes,
      exercises: routine.exercises,
    );
    await addRoutine(duplicated);
  }
}

final routinesProvider = AsyncNotifierProvider<RoutinesNotifier, List<Routine>>(
  RoutinesNotifier.new,
);
