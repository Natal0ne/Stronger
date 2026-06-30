import 'dart:async';
import 'package:flutter/material.dart';
import 'package:stronger/theme/app_colors.dart';
import 'package:stronger/models/exercise.dart';
import 'package:stronger/models/exercise_set.dart';
import 'package:stronger/models/workout_session.dart';
import 'package:stronger/models/enums.dart';
import 'package:stronger/services/database_helper.dart';

/// Screen used to log a freestyle ("empty") workout, or any workout that
/// was started without a predefined routine. The user adds exercises,
/// logs sets (reps/weight) for each, and saves the session when done.
///
/// Returns `true` to the caller via Navigator.pop when a session was
/// successfully saved, so the previous screen knows to refresh.
class ActiveWorkoutScreen extends StatefulWidget {
  final String? routineId;
  final String? initialTitle;

  /// When set, opens in edit mode (completed session) or start mode (scheduled).
  final WorkoutSession? existingSession;

  const ActiveWorkoutScreen({
    super.key,
    this.routineId,
    this.initialTitle,
    this.existingSession,
  });

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _PerformedExerciseDraft {
  final Exercise exercise;
  final List<ExerciseSet> sets;

  _PerformedExerciseDraft({required this.exercise, List<ExerciseSet>? sets})
    : sets = sets ?? [];
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  final List<_PerformedExerciseDraft> _performed = [];
  late DateTime _startedAt;
  Stopwatch? _stopwatch;
  Timer? _ticker;
  Duration _elapsed = Duration.zero;

  int _fatigueLevel = 3;
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();

  List<Exercise> _availableExercises = [];
  bool _loadingExercises = true;

  bool get _isEditing =>
      widget.existingSession?.status == WorkoutStatus.completed;

  bool get _isStartingScheduled =>
      widget.existingSession?.status == WorkoutStatus.scheduled;

  bool get _isLiveWorkout => !_isEditing;

  Color _getDifficultyColor(Difficulty level) {
    switch (level) {
      case Difficulty.beginner:
        return Colors.greenAccent;
      case Difficulty.intermediate:
        return Colors.orangeAccent;
      case Difficulty.advanced:
        return Colors.redAccent;
    }
  }

  Color _getEquipmentColor(Equipment tool) {
    switch (tool) {
      case Equipment.bodyweight:
        return Colors.cyanAccent;
      case Equipment.dumbbell:
        return Colors.purpleAccent;
      case Equipment.barbell:
        return Colors.blueAccent;
      case Equipment.machine:
        return Colors.amberAccent;
      case Equipment.cable:
        return Colors.pinkAccent;
    }
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    final existing = widget.existingSession;
    if (existing != null) {
      _startedAt = existing.date;
      _titleController.text = existing.title;
      _fatigueLevel = existing.fatigueLevel > 0 ? existing.fatigueLevel : 3;
      _notesController.text = existing.notes;
      _elapsed = Duration(minutes: existing.durationMinutes);
    } else {
      _startedAt = DateTime.now();
      _titleController.text = widget.initialTitle ?? 'Freestyle Workout';
    }

    if (_isLiveWorkout) {
      _stopwatch = Stopwatch()..start();
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() => _elapsed = _stopwatch!.elapsed);
      });
    }
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    final exercises = await DatabaseHelper.instance.getExercises();
    if (!mounted) return;

    final exerciseById = {for (var ex in exercises) ex.id: ex};

    if (widget.existingSession != null) {
      final session = widget.existingSession!;
      if (_isStartingScheduled && session.routineId.isNotEmpty) {
        await _prefillFromRoutine(session.routineId, exerciseById);
      } else {
        _prefillFromSession(session, exerciseById);
      }
    } else if (widget.routineId != null && widget.routineId!.isNotEmpty) {
      await _prefillFromRoutine(widget.routineId!, exerciseById);
    }

    setState(() {
      _availableExercises = exercises;
      _loadingExercises = false;
    });
  }

  Future<void> _prefillFromRoutine(
    String routineId,
    Map<String, Exercise> exerciseById,
  ) async {
    final routineExercises =
        await DatabaseHelper.instance.getExercisesForRoutine(routineId);
    for (var re in routineExercises) {
      final exercise = exerciseById[re.exerciseId];
      if (exercise == null) continue;
      final sets = List.generate(
        re.sets,
        (i) => ExerciseSet(
          setNumber: i + 1,
          reps: re.reps,
          weightKg: 0,
          isCompleted: false,
        ),
      );
      _performed.add(_PerformedExerciseDraft(exercise: exercise, sets: sets));
    }
  }

  void _prefillFromSession(
    WorkoutSession session,
    Map<String, Exercise> exerciseById,
  ) {
    for (var pe in session.performedExercises) {
      final exercise = exerciseById[pe.exerciseId];
      if (exercise == null) continue;
      _performed.add(
        _PerformedExerciseDraft(
          exercise: exercise,
          sets: pe.sets
              .map(
                (s) => ExerciseSet(
                  setNumber: s.setNumber,
                  reps: s.reps,
                  weightKg: s.weightKg,
                  isCompleted: s.isCompleted,
                ),
              )
              .toList(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _stopwatch?.stop();
    _notesController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _removeExercise(int exerciseIndex) {
    setState(() => _performed.removeAt(exerciseIndex));
  }

  void _dismissKeyboard() => FocusScope.of(context).unfocus();

  String get _elapsedLabel {
    final minutes = _elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = _elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hours = _elapsed.inHours;
    return hours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
  }

  Future<void> _addExerciseDialog() async {
    if (_loadingExercises) return;

    final searchController = TextEditingController();
    MuscleGroup? filterMuscle;

    final selected = await showModalBottomSheet<Exercise>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              final query = searchController.text.toLowerCase();
              final filtered = _availableExercises.where((ex) {
                final alreadyAdded = _performed.any(
                  (p) => p.exercise.id == ex.id,
                );
                if (alreadyAdded) return false;
                final matchesSearch =
                    ex.name.toLowerCase().contains(query) ||
                    ex.description.toLowerCase().contains(query);
                final matchesMuscle =
                    filterMuscle == null ||
                    ex.primaryMuscleGroup == filterMuscle;
                return matchesSearch && matchesMuscle;
              }).toList();

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Add Exercise',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                    child: TextField(
                      controller: searchController,
                      style: const TextStyle(color: AppColors.textPrimary),
                      onChanged: (_) => setSheetState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Search exercises...',
                        hintStyle: const TextStyle(color: Colors.grey),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppColors.accent,
                        ),
                        suffixIcon: searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  color: Colors.grey,
                                ),
                                onPressed: () => setSheetState(
                                  () => searchController.clear(),
                                ),
                              )
                            : null,
                        filled: true,
                        fillColor: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHigh,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        for (var muscle in MuscleGroup.values) ...[
                          GestureDetector(
                            onTap: () => setSheetState(
                              () => filterMuscle = filterMuscle == muscle
                                  ? null
                                  : muscle,
                            ),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: filterMuscle == muscle
                                    ? AppColors.accent.withAlpha(50)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: filterMuscle == muscle
                                      ? AppColors.accent
                                      : Colors.grey.withAlpha(80),
                                ),
                              ),
                              child: Text(
                                muscle.name.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: filterMuscle == muscle
                                      ? AppColors.accent
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Divider(height: 1, color: Colors.white10),
                  Expanded(
                    child: filtered.isEmpty
                        ? const Center(
                            child: Text(
                              'No matching exercises found.',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final ex = filtered[index];
                              return Card(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHigh,
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 6,
                                  ),
                                  title: Text(
                                    ex.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Wrap(
                                      spacing: 6,
                                      runSpacing: 4,
                                      children: [
                                        _buildTag(
                                          ex.primaryMuscleGroup.name,
                                          AppColors.accent,
                                        ),
                                        _buildTag(
                                          ex.equipment.name,
                                          _getEquipmentColor(ex.equipment),
                                        ),
                                        _buildTag(
                                          ex.difficulty.name,
                                          _getDifficultyColor(ex.difficulty),
                                        ),
                                      ],
                                    ),
                                  ),
                                  trailing: const Icon(
                                    Icons.add_circle_outline,
                                    color: AppColors.accent,
                                  ),
                                  onTap: () => Navigator.of(context).pop(ex),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );

    searchController.dispose();

    if (selected == null) return;

    final alreadyAdded = _performed.any((p) => p.exercise.id == selected.id);
    if (alreadyAdded) return;

    setState(() {
      _performed.add(_PerformedExerciseDraft(exercise: selected));
      _addSet(_performed.length - 1);
    });
  }

  void _addSet(int exerciseIndex) {
    final draft = _performed[exerciseIndex];
    setState(() {
      draft.sets.add(
        ExerciseSet(
          setNumber: draft.sets.length + 1,
          reps: draft.exercise.recommendedReps,
          weightKg: 0,
          isCompleted: false,
        ),
      );
    });
  }

  void _removeSet(int exerciseIndex, int setIndex) {
    setState(() {
      _performed[exerciseIndex].sets.removeAt(setIndex);
      // Renumber remaining sets
      for (var i = 0; i < _performed[exerciseIndex].sets.length; i++) {
        final s = _performed[exerciseIndex].sets[i];
        _performed[exerciseIndex].sets[i] = ExerciseSet(
          setNumber: i + 1,
          reps: s.reps,
          weightKg: s.weightKg,
          isCompleted: s.isCompleted,
        );
      }
    });
  }

  void _updateSet(
    int exerciseIndex,
    int setIndex, {
    int? reps,
    double? weightKg,
    bool? isCompleted,
  }) {
    final current = _performed[exerciseIndex].sets[setIndex];
    setState(() {
      _performed[exerciseIndex].sets[setIndex] = ExerciseSet(
        setNumber: current.setNumber,
        reps: reps ?? current.reps,
        weightKg: weightKg ?? current.weightKg,
        isCompleted: isCompleted ?? current.isCompleted,
      );
    });
  }

  bool get _hasLoggedAnySet =>
      _performed.any((p) => p.sets.any((s) => s.isCompleted));

  Future<void> _saveWorkout() async {
    if (_isLiveWorkout) {
      _stopwatch?.stop();
      _ticker?.cancel();
    }

    final dialogTitle = _isEditing ? 'Save changes?' : 'Finish workout?';
    final dialogContent = _isEditing
        ? 'Your changes to this workout will be saved.'
        : _hasLoggedAnySet
        ? 'This will save the session to your history.'
        : 'No sets were marked as completed. The session will still be saved as completed with zero volume.';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        title: Text(dialogTitle),
        content: Text(dialogContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
            child: const Text('Save', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      if (_isLiveWorkout) {
        _stopwatch?.start();
        _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
          if (!mounted) return;
          setState(() => _elapsed = _stopwatch!.elapsed);
        });
      }
      return;
    }

    final existing = widget.existingSession;
    final sessionId = existing?.id ??
        'sess_${DateTime.now().millisecondsSinceEpoch}';
    final routineId = existing?.routineId ??
        widget.routineId ??
        '';

    final session = WorkoutSession(
      id: sessionId,
      title: _titleController.text.trim().isEmpty
          ? 'Freestyle Workout'
          : _titleController.text.trim(),
      date: _startedAt,
      routineId: routineId,
      performedExercises: _performed
          .map(
            (p) => PerformedExercise(exerciseId: p.exercise.id, sets: p.sets),
          )
          .toList(),
      durationMinutes: _elapsed.inMinutes < 1 ? 1 : _elapsed.inMinutes,
      status: WorkoutStatus.completed,
      fatigueLevel: _fatigueLevel,
      notes: _notesController.text.trim(),
    );

    await DatabaseHelper.instance.insertWorkoutSession(session);

    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  Future<void> _discardWorkout() async {
    if (_isEditing) {
      Navigator.of(context).pop(false);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        title: const Text('Discard workout?'),
        content: const Text('This session will not be saved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep going'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Discard',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      Navigator.of(context).pop(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _isEditing,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && !_isEditing) _discardWorkout();
      },
      child: GestureDetector(
        onTap: _dismissKeyboard,
        behavior: HitTestBehavior.translucent,
        child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(_isEditing ? Icons.arrow_back : Icons.close),
            onPressed: _discardWorkout,
          ),
          title: TextField(
            controller: _titleController,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: _isEditing ? 'Workout title' : 'Workout title',
            ),
          ),
          actions: [
            if (_isLiveWorkout)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Center(
                  child: Row(
                    children: [
                      const Icon(Icons.timer, size: 16, color: AppColors.accent),
                      const SizedBox(width: 4),
                      Text(
                        _elapsedLabel,
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        body: _loadingExercises
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (_performed.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(
                              Icons.fitness_center,
                              size: 40,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'No exercises added yet',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  for (var i = 0; i < _performed.length; i++)
                    _ExerciseCard(
                      draft: _performed[i],
                      onRemoveExercise: () => _removeExercise(i),
                      onAddSet: () => _addSet(i),
                      onRemoveSet: (setIndex) => _removeSet(i, setIndex),
                      onUpdateSet: (setIndex, {reps, weightKg, isCompleted}) =>
                          _updateSet(
                            i,
                            setIndex,
                            reps: reps,
                            weightKg: weightKg,
                            isCompleted: isCompleted,
                          ),
                    ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _addExerciseDialog,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(46),
                      side: const BorderSide(color: AppColors.accent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.add, color: AppColors.accent),
                    label: const Text(
                      'Add Exercise',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Row(
                    children: [
                      Icon(Icons.bolt, color: AppColors.accent, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Perceived Fatigue (RPE)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: AppColors.accent,
                              thumbColor: AppColors.accent,
                              inactiveTrackColor: Colors.grey.withAlpha(60),
                              overlayColor: AppColors.accent.withAlpha(40),
                            ),
                            child: Slider(
                              value: _fatigueLevel.toDouble(),
                              min: 1,
                              max: 5,
                              divisions: 4,
                              label: '$_fatigueLevel',
                              onChanged: (v) =>
                                  setState(() => _fatigueLevel = v.round()),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withAlpha(40),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$_fatigueLevel/5',
                            style: const TextStyle(
                              color: AppColors.accent,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _notesController,
                    maxLines: 3,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Notes',
                      labelStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: const Icon(
                        Icons.notes_outlined,
                        color: AppColors.accent,
                        size: 20,
                      ),
                      filled: true,
                      fillColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHigh,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.accent,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _performed.isEmpty ? null : _saveWorkout,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _isEditing ? 'Save Changes' : 'Finish Workout',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final _PerformedExerciseDraft draft;
  final VoidCallback onRemoveExercise;
  final VoidCallback onAddSet;
  final void Function(int setIndex) onRemoveSet;
  final void Function(
    int setIndex, {
    int? reps,
    double? weightKg,
    bool? isCompleted,
  })
  onUpdateSet;

  const _ExerciseCard({
    required this.draft,
    required this.onRemoveExercise,
    required this.onAddSet,
    required this.onRemoveSet,
    required this.onUpdateSet,
  });

  Color _getDifficultyColor(Difficulty level) {
    switch (level) {
      case Difficulty.beginner:
        return Colors.greenAccent;
      case Difficulty.intermediate:
        return Colors.orangeAccent;
      case Difficulty.advanced:
        return Colors.redAccent;
    }
  }

  Color _getEquipmentColor(Equipment tool) {
    switch (tool) {
      case Equipment.bodyweight:
        return Colors.cyanAccent;
      case Equipment.dumbbell:
        return Colors.purpleAccent;
      case Equipment.barbell:
        return Colors.blueAccent;
      case Equipment.machine:
        return Colors.amberAccent;
      case Equipment.cable:
        return Colors.pinkAccent;
    }
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  draft.exercise.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.redAccent.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  iconSize: 18,
                  tooltip: 'Remove exercise',
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
                  onPressed: onRemoveExercise,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              _buildTag(
                draft.exercise.primaryMuscleGroup.name,
                AppColors.accent,
              ),
              _buildTag(
                draft.exercise.equipment.name,
                _getEquipmentColor(draft.exercise.equipment),
              ),
              _buildTag(
                draft.exercise.difficulty.name,
                _getDifficultyColor(draft.exercise.difficulty),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < draft.sets.length; i++)
            _SetRow(
              setIndex: i,
              set: draft.sets[i],
              onRemove: () => onRemoveSet(i),
              onUpdate: ({reps, weightKg, isCompleted}) => onUpdateSet(
                i,
                reps: reps,
                weightKg: weightKg,
                isCompleted: isCompleted,
              ),
            ),
          const SizedBox(height: 8),
          Center(
            child: TextButton.icon(
              onPressed: onAddSet,
              icon: const Icon(Icons.add, size: 18, color: AppColors.accent),
              label: const Text(
                'Add Set',
                style: TextStyle(color: AppColors.accent),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SetRow extends StatelessWidget {
  final int setIndex;
  final ExerciseSet set;
  final VoidCallback onRemove;
  final void Function({int? reps, double? weightKg, bool? isCompleted})
  onUpdate;

  const _SetRow({
    required this.setIndex,
    required this.set,
    required this.onRemove,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey('set_$setIndex'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 12),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.redAccent.withAlpha(30),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.redAccent),
      ),
      onDismissed: (_) => onRemove(),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            SizedBox(
              width: 28,
              child: Text(
                '${set.setNumber}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: _NumberField(
                label: 'Weight',
                icon: Icons.fitness_center_outlined,
                value: set.weightKg,
                onChanged: (v) => onUpdate(weightKg: v),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _NumberField(
                label: 'Reps',
                icon: Icons.repeat,
                value: set.reps.toDouble(),
                isInt: true,
                onChanged: (v) => onUpdate(reps: v.round()),
              ),
            ),
            const SizedBox(width: 8),
            Checkbox(
              value: set.isCompleted,
              activeColor: AppColors.accent,
              onChanged: (v) => onUpdate(isCompleted: v ?? false),
            ),
          ],
        ),
      ),
    );
  }
}

class _NumberField extends StatefulWidget {
  final String label;
  final double value;
  final IconData icon;
  final bool isInt;
  final void Function(double) onChanged;

  const _NumberField({
    required this.label,
    required this.value,
    required this.icon,
    required this.onChanged,
    this.isInt = false,
  });

  @override
  State<_NumberField> createState() => _NumberFieldState();
}

class _NumberFieldState extends State<_NumberField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _formatValue(widget.value));
  }

  @override
  void didUpdateWidget(_NumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      final currentParsed = double.tryParse(_controller.text) ?? 0;
      if (currentParsed != widget.value) {
        _controller.text = _formatValue(widget.value);
      }
    }
  }

  String _formatValue(double val) {
    if (val <= 0) return '';
    return widget.isInt ? val.round().toString() : val.toString();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      keyboardType: TextInputType.numberWithOptions(decimal: !widget.isInt),
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: const TextStyle(fontSize: 13, color: Colors.grey),
        prefixIcon: Icon(widget.icon, size: 16, color: AppColors.accent),
        isDense: true,
        filled: true,
        fillColor: Colors.white.withAlpha(20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: (text) {
        widget.onChanged(double.tryParse(text) ?? 0);
      },
    );
  }
}
