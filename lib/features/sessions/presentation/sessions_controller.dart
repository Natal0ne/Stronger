import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:stronger/core/models/workout_session.dart';
import 'package:stronger/core/models/exercise_set.dart';
import 'package:stronger/core/models/exercise.dart';
import 'package:stronger/core/models/enums.dart';
import 'package:stronger/features/sessions/data/session_repository.dart';
import 'package:stronger/features/exercises/data/exercise_repository.dart';
import 'package:stronger/features/dashboard/presentation/dashboard_controller.dart';
import 'package:stronger/features/exercises/presentation/exercises_controller.dart';

class HistorySessionsNotifier extends AsyncNotifier<List<WorkoutSession>> {
  @override
  Future<List<WorkoutSession>> build() async {
    final sessions = await ref.read(sessionRepositoryProvider).getWorkoutSessions();
    return sessions.where((s) => s.status != WorkoutStatus.scheduled).toList();
  }

  Future<void> deleteSession(String id) async {
    await ref.read(sessionRepositoryProvider).deleteWorkoutSession(id);
    ref.invalidateSelf();
    ref.invalidate(scheduledSessionsProvider);
    ref.invalidate(dashboardProvider);
    ref.invalidate(exerciseHistoryProvider);
  }
}

final historySessionsProvider = AsyncNotifierProvider<HistorySessionsNotifier, List<WorkoutSession>>(
  HistorySessionsNotifier.new,
);

class ScheduledSessionsNotifier extends AsyncNotifier<List<WorkoutSession>> {
  @override
  Future<List<WorkoutSession>> build() async {
    return ref.read(sessionRepositoryProvider).getScheduledSessionsForWeek(DateTime.now());
  }

  Future<void> deleteSession(String id) async {
    await ref.read(sessionRepositoryProvider).deleteWorkoutSession(id);
    ref.invalidateSelf();
    ref.invalidate(historySessionsProvider);
    ref.invalidate(dashboardProvider);
  }
}

final scheduledSessionsProvider = AsyncNotifierProvider<ScheduledSessionsNotifier, List<WorkoutSession>>(
  ScheduledSessionsNotifier.new,
);

final exerciseNamesProvider = FutureProvider<Map<String, String>>((ref) async {
  final exercises = await ref.read(exerciseRepositoryProvider).getExercises();
  return {for (var ex in exercises) ex.id: ex.name};
});

final exerciseHistoryProvider = FutureProvider.family<List<double>, String>((ref, exerciseId) async {
  return ref.read(sessionRepositoryProvider).getExerciseWeightHistory(exerciseId);
});

class PerformedExerciseDraft {
  final Exercise exercise;
  final List<ExerciseSet> sets;
  final List<UniqueKey> setKeys;

  PerformedExerciseDraft({
    required this.exercise,
    required this.sets,
    required this.setKeys,
  });

  PerformedExerciseDraft copyWith({
    Exercise? exercise,
    List<ExerciseSet>? sets,
    List<UniqueKey>? setKeys,
  }) {
    return PerformedExerciseDraft(
      exercise: exercise ?? this.exercise,
      sets: sets ?? this.sets,
      setKeys: setKeys ?? this.setKeys,
    );
  }
}

class ActiveWorkoutState {
  final String id;
  final String title;
  final DateTime startedAt;
  final String? routineId;
  final List<PerformedExerciseDraft> performedExercises;
  final int fatigueLevel;
  final String notes;
  final Duration elapsedDuration;
  final Map<String, List<ExerciseSet>> lastWorkoutSets;
  final int restSecondsRemaining;
  final int totalRestDuration;
  final String? activeRestExerciseId;

  ActiveWorkoutState({
    required this.id,
    required this.title,
    required this.startedAt,
    this.routineId,
    required this.performedExercises,
    this.fatigueLevel = 3,
    this.notes = '',
    required this.elapsedDuration,
    required this.lastWorkoutSets,
    this.restSecondsRemaining = 0,
    this.totalRestDuration = 60,
    this.activeRestExerciseId,
  });

  ActiveWorkoutState copyWith({
    String? id,
    String? title,
    List<PerformedExerciseDraft>? performedExercises,
    int? fatigueLevel,
    String? notes,
    Duration? elapsedDuration,
    Map<String, List<ExerciseSet>>? lastWorkoutSets,
    int? restSecondsRemaining,
    int? totalRestDuration,
    String? activeRestExerciseId,
  }) {
    return ActiveWorkoutState(
      id: id ?? this.id,
      title: title ?? this.title,
      startedAt: startedAt,
      routineId: routineId ?? this.routineId,
      performedExercises: performedExercises ?? this.performedExercises,
      fatigueLevel: fatigueLevel ?? this.fatigueLevel,
      notes: notes ?? this.notes,
      elapsedDuration: elapsedDuration ?? this.elapsedDuration,
      lastWorkoutSets: lastWorkoutSets ?? this.lastWorkoutSets,
      restSecondsRemaining: restSecondsRemaining ?? this.restSecondsRemaining,
      totalRestDuration: totalRestDuration ?? this.totalRestDuration,
      activeRestExerciseId: activeRestExerciseId ?? this.activeRestExerciseId,
    );
  }
}

class ActiveWorkoutNotifier extends Notifier<ActiveWorkoutState?> {
  Timer? _stopwatchTimer;
  Timer? _restTimer;

  @override
  ActiveWorkoutState? build() {
    ref.onDispose(() {
      _stopwatchTimer?.cancel();
      _restTimer?.cancel();
    });
    return null;
  }

  Future<void> startWorkout({
    String? routineId,
    String? initialTitle,
    WorkoutSession? existingSession,
  }) async {
    final sessionRepo = ref.read(sessionRepositoryProvider);
    final exerciseRepo = ref.read(exerciseRepositoryProvider);

    final exercises = await exerciseRepo.getExercises();
    final exerciseById = {for (var ex in exercises) ex.id: ex};

    String sessionId = existingSession?.id ?? 'sess_${DateTime.now().millisecondsSinceEpoch}';
    String finalTitle = initialTitle ?? 'Freestyle Workout';
    int fatigue = 3;
    String notes = '';
    Duration elapsed = Duration.zero;

    Map<String, List<ExerciseSet>> lastSets = {};
    List<PerformedExerciseDraft> performedDrafts = [];

    if (existingSession != null) {
      sessionId = existingSession.id;
      finalTitle = existingSession.title;
      fatigue = existingSession.fatigueLevel > 0 ? existingSession.fatigueLevel : 3;
      notes = existingSession.notes;

      if (existingSession.status == WorkoutStatus.completed) {
        elapsed = Duration(minutes: existingSession.durationMinutes);
      }

      if (!(existingSession.status == WorkoutStatus.scheduled && existingSession.performedExercises.isEmpty)) {
        for (var pe in existingSession.performedExercises) {
          final exercise = exerciseById[pe.exerciseId];
          if (exercise == null) continue;
          final listSets = pe.sets.map((s) => ExerciseSet(setNumber: s.setNumber, reps: s.reps, weightKg: s.weightKg, isCompleted: s.isCompleted)).toList();
          performedDrafts.add(PerformedExerciseDraft(
            exercise: exercise,
            sets: listSets,
            setKeys: List.generate(listSets.length, (_) => UniqueKey()),
          ));
        }
      }
    }

    if (existingSession?.status != WorkoutStatus.completed) {
      lastSets = await sessionRepo.getLastWorkoutSetsByExercise();
    }

    final targetRoutineId = existingSession?.routineId ?? routineId;
    if (targetRoutineId != null && targetRoutineId.isNotEmpty && performedDrafts.isEmpty) {
      final routineExercises = await exerciseRepo.getExercisesForRoutine(targetRoutineId);
      for (var re in routineExercises) {
        final exercise = exerciseById[re.exerciseId];
        if (exercise == null) continue;

        final sets = List.generate(re.sets, (i) => ExerciseSet(setNumber: i + 1, reps: 0, weightKg: 0.0, isCompleted: false));
        performedDrafts.add(PerformedExerciseDraft(
          exercise: exercise,
          sets: sets,
          setKeys: List.generate(sets.length, (_) => UniqueKey()),
        ));
      }
    }

    state = ActiveWorkoutState(
      id: sessionId,
      title: finalTitle,
      startedAt: existingSession?.date ?? DateTime.now(),
      routineId: targetRoutineId,
      performedExercises: performedDrafts,
      fatigueLevel: fatigue,
      notes: notes,
      elapsedDuration: elapsed,
      lastWorkoutSets: lastSets,
    );

    if (existingSession?.status != WorkoutStatus.completed) {
      _startStopwatch();
    }
  }

  void _startStopwatch() {
    _stopwatchTimer?.cancel();
    _stopwatchTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state == null) return;
      state = state!.copyWith(
        elapsedDuration: state!.elapsedDuration + const Duration(seconds: 1),
      );
    });
  }

  void startRestTimer(String exerciseId, int seconds) {
    _restTimer?.cancel();
    if (state == null) return;

    state = state!.copyWith(
      totalRestDuration: seconds,
      restSecondsRemaining: seconds,
      activeRestExerciseId: exerciseId,
    );

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state == null) {
        timer.cancel();
        return;
      }

      final remaining = state!.restSecondsRemaining - 1;
      if (remaining <= 0) {
        timer.cancel();
        state = state!.copyWith(
          restSecondsRemaining: 0,
          activeRestExerciseId: null,
        );
        _triggerRestFinishedHaptic();
      } else {
        state = state!.copyWith(restSecondsRemaining: remaining);
      }
    });
  }

  void add10sToRest() {
    if (state == null || state!.restSecondsRemaining <= 0) return;
    state = state!.copyWith(
      restSecondsRemaining: state!.restSecondsRemaining + 10,
      totalRestDuration: state!.totalRestDuration + 10,
    );
  }

  void skipRest() {
    _restTimer?.cancel();
    if (state == null) return;
    state = state!.copyWith(
      restSecondsRemaining: 0,
      activeRestExerciseId: null,
    );
  }

  void _triggerRestFinishedHaptic() {
    HapticFeedback.vibrate();
  }

  Future<void> updateExerciseRestSeconds(String exerciseId, int seconds) async {
    if (state == null) return;

    final updatedExercises = state!.performedExercises.map((pe) {
      if (pe.exercise.id == exerciseId) {
        final updatedEx = Exercise(
          id: pe.exercise.id,
          name: pe.exercise.name,
          description: pe.exercise.description,
          primaryMuscleGroup: pe.exercise.primaryMuscleGroup,
          difficulty: pe.exercise.difficulty,
          equipment: pe.exercise.equipment,
          recommendedReps: pe.exercise.recommendedReps,
          defaultRestSeconds: seconds,
            notes: pe.exercise.notes,
        );
        return pe.copyWith(exercise: updatedEx);
      }
      return pe;
    }).toList();

    state = state!.copyWith(performedExercises: updatedExercises);

    final exerciseRepo = ref.read(exerciseRepositoryProvider);
    final targetPe = state!.performedExercises.firstWhere((pe) => pe.exercise.id == exerciseId);
    await exerciseRepo.insertExercise(targetPe.exercise);

    ref.invalidate(exercisesProvider);
  }

  void updateTitle(String title) {
    if (state == null) return;
    state = state!.copyWith(title: title);
  }

  void updateNotes(String notes) {
    if (state == null) return;
    state = state!.copyWith(notes: notes);
  }

  void updateFatigue(int level) {
    if (state == null) return;
    state = state!.copyWith(fatigueLevel: level);
  }

  void addExercise(Exercise exercise) {
    if (state == null) return;
    final list = List<PerformedExerciseDraft>.from(state!.performedExercises);

    final draft = PerformedExerciseDraft(
      exercise: exercise,
      sets: [],
      setKeys: [],
    );
    list.add(draft);
    state = state!.copyWith(performedExercises: list);

    addSet(list.length - 1, exercise.recommendedReps);
  }

  void removeExercise(int index) {
    if (state == null) return;
    final list = List<PerformedExerciseDraft>.from(state!.performedExercises);
    list.removeAt(index);
    state = state!.copyWith(performedExercises: list);
  }

  void addSet(int exerciseIndex, int recommendedReps) {
    if (state == null) return;
    final list = List<PerformedExerciseDraft>.from(state!.performedExercises);
    final draft = list[exerciseIndex];

    final nextNumber = draft.sets.length + 1;

    final newSet = ExerciseSet(
      setNumber: nextNumber,
      reps: 0,
    weightKg: 0.0,
    isCompleted: false,
    );

    final updatedSets = List<ExerciseSet>.from(draft.sets)..add(newSet);
    final updatedKeys = List<UniqueKey>.from(draft.setKeys)..add(UniqueKey());

    list[exerciseIndex] = draft.copyWith(sets: updatedSets, setKeys: updatedKeys);
    state = state!.copyWith(performedExercises: list);
  }

  void removeSet(int exerciseIndex, int setIndex) {
    if (state == null) return;
    final list = List<PerformedExerciseDraft>.from(state!.performedExercises);
    final draft = list[exerciseIndex];

    final updatedSets = List<ExerciseSet>.from(draft.sets)..removeAt(setIndex);
    final updatedKeys = List<UniqueKey>.from(draft.setKeys)..removeAt(setIndex);

    for (var i = 0; i < updatedSets.length; i++) {
      final s = updatedSets[i];
      updatedSets[i] = ExerciseSet(
        setNumber: i + 1,
        reps: s.reps,
        weightKg: s.weightKg,
        isCompleted: s.isCompleted,
      );
    }

    list[exerciseIndex] = draft.copyWith(sets: updatedSets, setKeys: updatedKeys);
    state = state!.copyWith(performedExercises: list);
  }

  void updateSet(int exerciseIndex, int setIndex, {int? reps, double? weightKg, bool? isCompleted}) {
    if (state == null) return;
    final list = List<PerformedExerciseDraft>.from(state!.performedExercises);
    final draft = list[exerciseIndex];

    final current = draft.sets[setIndex];
    final previousSets = state!.lastWorkoutSets[draft.exercise.id];
    final prevSet = (previousSets != null && setIndex < previousSets.length) ? previousSets[setIndex] : null;

    double finalWeight = weightKg ?? current.weightKg;
    int finalReps = reps ?? current.reps;
    final wasCompletedBefore = current.isCompleted;
    final isNowCompleted = isCompleted ?? current.isCompleted;

    if (isNowCompleted == true) {
      if (finalWeight == 0.0 && prevSet != null) finalWeight = prevSet.weightKg;
      if (finalReps == 0) {
        finalReps = prevSet?.reps ?? draft.exercise.recommendedReps;
      }
    }

    if (existingWorkoutIsLive() && !wasCompletedBefore && isNowCompleted) {
      startRestTimer(draft.exercise.id, draft.exercise.defaultRestSeconds);

      bool isPR = false;
      if (prevSet != null) {
        isPR = finalWeight > prevSet.weightKg || (finalWeight == prevSet.weightKg && finalReps > prevSet.reps);
      }

      if (isPR) {
        HapticFeedback.vibrate();
      } else {
        HapticFeedback.mediumImpact();
      }
    }

    final updatedSet = ExerciseSet(
      setNumber: current.setNumber,
      reps: finalReps,
      weightKg: finalWeight,
      isCompleted: isNowCompleted,
    );

    final updatedSets = List<ExerciseSet>.from(draft.sets)..[setIndex] = updatedSet;
    list[exerciseIndex] = draft.copyWith(sets: updatedSets);
    state = state!.copyWith(performedExercises: list);
  }

  void discardWorkout() {
    _stopwatchTimer?.cancel();
    _restTimer?.cancel();
    state = null;
  }

  Future<void> saveWorkout() async {
    if (state == null) return;
    _stopwatchTimer?.cancel();
    _restTimer?.cancel();

    final session = WorkoutSession(
      id: state!.id,
      title: state!.title.trim().isEmpty ? 'Freestyle Workout' : state!.title.trim(),
      date: state!.startedAt,
      routineId: state!.routineId ?? '',
      performedExercises: state!.performedExercises.map((p) => PerformedExercise(exerciseId: p.exercise.id, sets: p.sets)).toList(),
      durationMinutes: state!.elapsedDuration.inMinutes < 1 ? 1 : state!.elapsedDuration.inMinutes,
      status: WorkoutStatus.completed,
      fatigueLevel: state!.fatigueLevel,
      notes: state!.notes.trim(),
    );

    await ref.read(sessionRepositoryProvider).insertWorkoutSession(session);

    ref.invalidate(historySessionsProvider);
    ref.invalidate(scheduledSessionsProvider);
    ref.invalidate(dashboardProvider);
    ref.invalidate(exerciseHistoryProvider);

    state = null;
  }

  bool existingWorkoutIsLive() {
    return state != null && _stopwatchTimer != null && _stopwatchTimer!.isActive;
  }
}

final activeWorkoutProvider = NotifierProvider<ActiveWorkoutNotifier, ActiveWorkoutState?>(
  ActiveWorkoutNotifier.new,
);

final workoutPanelExpandedProvider = StateProvider<bool>((ref) {
  return false;
});
