import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronger/core/theme/app_colors.dart';
import 'package:stronger/core/models/exercise.dart';
import 'package:stronger/core/models/exercise_set.dart';
import 'package:stronger/core/models/workout_session.dart';
import 'package:stronger/core/models/enums.dart';
import 'package:stronger/features/sessions/presentation/widgets/exercise_card.dart';
import 'package:stronger/features/sessions/presentation/widgets/exercise_picker_sheet.dart';
import 'package:stronger/features/sessions/presentation/widgets/rest_timer_card.dart';
import 'package:stronger/features/sessions/presentation/widgets/fatigue_selector.dart';
import 'package:stronger/features/exercises/data/exercise_repository.dart';
import 'package:stronger/features/sessions/data/session_repository.dart';
import 'package:stronger/features/sessions/presentation/sessions_controller.dart';

class ActiveWorkoutScreen extends ConsumerStatefulWidget {
  final String? routineId;
  final String? initialTitle;
  final WorkoutSession? existingSession;

  const ActiveWorkoutScreen({
    super.key,
    this.routineId,
    this.initialTitle,
    this.existingSession,
  });

  static Route<bool> route({
    String? routineId,
    String? initialTitle,
    WorkoutSession? existingSession,
  }) {
    return PageRouteBuilder<bool>(
      opaque: false,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      pageBuilder: (context, animation, secondaryAnimation) => ActiveWorkoutScreen(
        routineId: routineId,
        initialTitle: initialTitle,
        existingSession: existingSession,
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeOutQuart;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }

  @override
  ConsumerState<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends ConsumerState<ActiveWorkoutScreen> {
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  int _fatigueLevel = 3;

  List<Exercise> _availableExercises = [];
  bool _loadingExercises = true;
  bool _initialized = false;

  double _dragOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    if (_initialized) return;
    _initialized = true;

    final exercises = await ref.read(exerciseRepositoryProvider).getExercises();
    if (!mounted) return;

    final runningWorkout = ref.read(activeWorkoutProvider);
    if (runningWorkout != null) {
      _titleController.text = runningWorkout.title;
      _notesController.text = runningWorkout.notes;
      _fatigueLevel = runningWorkout.fatigueLevel;
      setState(() {
        _availableExercises = exercises;
        _loadingExercises = false;
      });
      return;
    }

    final isStartingFresh = widget.existingSession == null;
    final startedARoutine = widget.routineId != null && widget.routineId!.isNotEmpty;
    WorkoutSession? todayScheduled;

    if (isStartingFresh && startedARoutine) {
      final scheduledThisWeek = await ref.read(sessionRepositoryProvider).getScheduledSessionsForWeek(DateTime.now());
      final now = DateTime.now();

      for (var session in scheduledThisWeek) {
        if (session.status == WorkoutStatus.scheduled &&
          session.date.year == now.year &&
          session.date.month == now.month &&
          session.date.day == now.day &&
          session.routineId == widget.routineId) {

          todayScheduled = session;
        break;
          }
      }
    }

    bool linkToSchedule = false;
    if (todayScheduled != null && mounted) {
      HapticFeedback.heavyImpact();
      linkToSchedule = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          title: const Row(
            children: [
              Icon(Icons.sync, color: AppColors.accent, size: 22),
              SizedBox(width: 10),
              Text("Link today's plan?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          content: const Text(
            "You have this routine scheduled for today. Link this session to complete your plan?",
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(ctx, false);
                  },
                  child: const Text('Skip', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    Navigator.pop(ctx, true);
                  },
                  child: const Text('Link', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ) ?? false;
    }

    if (linkToSchedule && todayScheduled != null) {
      await ref.read(activeWorkoutProvider.notifier).startWorkout(
        existingSession: todayScheduled,
      );
    } else {
      await ref.read(activeWorkoutProvider.notifier).startWorkout(
        routineId: widget.routineId,
        initialTitle: widget.initialTitle,
        existingSession: widget.existingSession,
      );
    }

    final activeState = ref.read(activeWorkoutProvider);
    if (activeState != null) {
      _titleController.text = activeState.title;
      _notesController.text = activeState.notes;
      _fatigueLevel = activeState.fatigueLevel;
    }

    setState(() {
      _availableExercises = exercises;
      _loadingExercises = false;
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _dismissKeyboard() => FocusScope.of(context).unfocus();

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hours = d.inHours;
    return hours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
  }

  void _removeExercise(int index) {
    HapticFeedback.mediumImpact();
    ref.read(activeWorkoutProvider.notifier).removeExercise(index);
  }

  void _addSet(int exerciseIndex) {
    HapticFeedback.lightImpact();
    final active = ref.read(activeWorkoutProvider);
    if (active == null) return;
    ref.read(activeWorkoutProvider.notifier).addSet(
      exerciseIndex,
      active.performedExercises[exerciseIndex].exercise.recommendedReps,
    );
  }

  void _removeSet(int exerciseIndex, int setIndex) {
    HapticFeedback.lightImpact();
    ref.read(activeWorkoutProvider.notifier).removeSet(exerciseIndex, setIndex);
  }

  void _updateSet(int exerciseIndex, int setIndex, {int? reps, double? weightKg, bool? isCompleted}) {
    ref.read(activeWorkoutProvider.notifier).updateSet(
      exerciseIndex,
      setIndex,
      reps: reps,
      weightKg: weightKg,
      isCompleted: isCompleted,
    );
  }

  Future<void> _addExerciseDialog() async {
    final active = ref.read(activeWorkoutProvider);
    if (_loadingExercises || active == null) return;

    final selected = await showModalBottomSheet<Exercise>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ExercisePickerSheet(
        availableExercises: _availableExercises,
        alreadyPerformed: active.performedExercises,
      ),
    );

    if (selected == null) return;
    ref.read(activeWorkoutProvider.notifier).addExercise(selected);
  }

  void _showSetDefaultRestDialog() {
    final active = ref.read(activeWorkoutProvider);
    if (active == null) return;

    showDialog(
      context: context,
      builder: (ctx) {
        final ctrl = TextEditingController(text: '${active.totalRestDuration}');
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          title: const Text('Set Rest Time', style: TextStyle(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              labelText: 'Rest (seconds)',
              suffixText: 'sec',
              labelStyle: TextStyle(color: Colors.grey),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
              onPressed: () {
                final val = int.tryParse(ctrl.text) ?? 60;
                final restExerciseId = active.activeRestExerciseId ?? '';

            ref.read(activeWorkoutProvider.notifier).startRestTimer(
              restExerciseId,
              val,
            );

            if (restExerciseId.isNotEmpty) {
              ref.read(activeWorkoutProvider.notifier).updateExerciseRestSeconds(
                restExerciseId,
                val,
              );
            }
            Navigator.pop(ctx);
              },
              child: const Text('Apply', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _discardWorkout() async {
    final isLiveWorkout = ref.read(activeWorkoutProvider.notifier).existingWorkoutIsLive();

    if (!isLiveWorkout) {
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
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Keep going')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Discard', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      ref.read(activeWorkoutProvider.notifier).discardWorkout();
      Navigator.of(context).pop(false);
    }
  }

  Future<void> _saveWorkout() async {
    final active = ref.read(activeWorkoutProvider);
    if (active == null) return;

    final isLiveWorkout = ref.read(activeWorkoutProvider.notifier).existingWorkoutIsLive();

    ref.read(activeWorkoutProvider.notifier).updateTitle(_titleController.text.trim());
    ref.read(activeWorkoutProvider.notifier).updateNotes(_notesController.text.trim());
    ref.read(activeWorkoutProvider.notifier).updateFatigue(_fatigueLevel);

    final hasLoggedAnySet = active.performedExercises.any((p) => p.sets.any((s) => s.isCompleted));
    final dialogContent = hasLoggedAnySet
    ? 'This will save the session to your history.'
    : 'No sets were marked as completed. The session will still be saved with zero volume.';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        title: const Text('Finish workout?'),
        content: Text(dialogContent),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
            child: const Text('Save', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(activeWorkoutProvider.notifier).saveWorkout();
      if (!mounted) return;
      Navigator.of(context).pop(true);
    }
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (details.primaryDelta! > 0) {
      setState(() {
        _dragOffset += details.primaryDelta!;
      });
    }
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (_dragOffset > 110) {
      HapticFeedback.lightImpact();
      Navigator.of(context).pop(false);
    } else {
      setState(() {
        _dragOffset = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeWorkout = ref.watch(activeWorkoutProvider);

    if (_loadingExercises || activeWorkout == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.accent)),
      );
    }

    final isLiveWorkout = ref.read(activeWorkoutProvider.notifier).existingWorkoutIsLive();

    return PopScope(
      canPop: true,
      child: GestureDetector(
        onTap: _dismissKeyboard,
        behavior: HitTestBehavior.translucent,
        child: Transform.translate(
          offset: Offset(0, _dragOffset),
          child: Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
            body: SafeArea(
              child: Column(
                children: [
                  if (isLiveWorkout)
                    GestureDetector(
                      onVerticalDragUpdate: _onVerticalDragUpdate,
                      onVerticalDragEnd: _onVerticalDragEnd,
                      child: Container(
                        width: double.infinity,
                        color: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Center(
                          child: Container(
                            width: 48,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(2.5),
                            ),
                          ),
                        ),
                      ),
                    ),

                    GestureDetector(
                      onVerticalDragUpdate: isLiveWorkout ? (details) => _handleDragUpdate(details) : null,
                      onVerticalDragEnd: isLiveWorkout ? (_) => _handleDragEnd() : null,
                      child: Container(
                        height: 56,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          children: [
                            if (!isLiveWorkout)
                              IconButton(
                                icon: const Icon(Icons.arrow_back),
                                onPressed: () => Navigator.of(context).pop(false),
                              )
                              else
                                const SizedBox(width: 12),

                                Expanded(
                                  child: TextField(
                                    controller: _titleController,
                                    onChanged: ref.read(activeWorkoutProvider.notifier).updateTitle,
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 18),
                                    decoration: const InputDecoration(border: InputBorder.none, hintText: 'Workout title'),
                                  ),
                                ),
                                if (isLiveWorkout) ...[
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
                                    tooltip: 'Discard workout',
                                    onPressed: _discardWorkout,
                                  ),
                                   const SizedBox(width: 8),

                                   Padding(
                                     padding: const EdgeInsets.only(right: 12),
                                     child: Row(
                                       children: [
                                         const Icon(Icons.timer, size: 16, color: AppColors.accent),
                                         const SizedBox(width: 4),
                                         Text(
                                           _formatDuration(activeWorkout.elapsedDuration),
                                           style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold),
                                         ),
                                       ],
                                     ),
                                   ),
                                ],
                          ],
                        ),
                      ),
                    ),

                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          if (activeWorkout.performedExercises.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 48),
                              child: Center(
                                child: Column(
                                  children: [
                                    Icon(Icons.fitness_center, size: 40, color: AppColors.textSecondary),
                                    SizedBox(height: 12),
                                    Text('No exercises added yet', style: TextStyle(color: AppColors.textSecondary)),
                                  ],
                                ),
                              ),
                            ),
                            for (var i = 0; i < activeWorkout.performedExercises.length; i++)
                              ExerciseCard(
                                draft: activeWorkout.performedExercises[i],
                                lastSets: activeWorkout.lastWorkoutSets[activeWorkout.performedExercises[i].exercise.id],
                                onRemoveExercise: () => _removeExercise(i),
                                onAddSet: () => _addSet(i),
                                onRemoveSet: (setIndex) => _removeSet(i, setIndex),
                                onUpdateSet: (setIndex, {reps, weightKg, isCompleted}) => _updateSet(
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
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                icon: const Icon(Icons.add, color: AppColors.accent),
                                label: const Text('Add Exercise', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(height: 24),
                              FatigueSelector(
                                fatigueLevel: _fatigueLevel,
                                onChanged: (v) {
                                  setState(() => _fatigueLevel = v.round());
                                  ref.read(activeWorkoutProvider.notifier).updateFatigue(v.round());
                                },
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _notesController,
                                onChanged: ref.read(activeWorkoutProvider.notifier).updateNotes,
                                maxLines: 3,
                                style: const TextStyle(color: AppColors.textPrimary),
                                decoration: InputDecoration(
                                  labelText: 'Notes',
                                  labelStyle: const TextStyle(color: Colors.grey),
                                  prefixIcon: const Icon(Icons.notes_outlined, color: AppColors.accent, size: 20),
                                  filled: true,
                                  fillColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white10)),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white10)),
                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.accent, width: 1.5)),
                                ),
                              ),
                              const SizedBox(height: 24),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            bottomNavigationBar: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (activeWorkout.restSecondsRemaining > 0)
                    RestTimerCard(
                      secondsRemaining: activeWorkout.restSecondsRemaining,
                      progressValue: activeWorkout.totalRestDuration > 0
                      ? activeWorkout.restSecondsRemaining / activeWorkout.totalRestDuration
                      : 0.0,
                      onAdd10s: ref.read(activeWorkoutProvider.notifier).add10sToRest,
                      onSkip: ref.read(activeWorkoutProvider.notifier).skipRest,
                      onEditDefaultRest: _showSetDefaultRestDialog,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: ElevatedButton(
                        onPressed: activeWorkout.performedExercises.isEmpty ? null : _saveWorkout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          isLiveWorkout ? 'Finish Workout' : 'Save Changes',
                          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (details.primaryDelta! > 0) {
      setState(() {
        _dragOffset += details.primaryDelta!;
      });
    }
  }

  void _handleDragEnd() {
    if (_dragOffset > 110) {
      HapticFeedback.lightImpact();
      Navigator.of(context).pop(false);
    } else {
      setState(() {
        _dragOffset = 0.0;
      });
    }
  }
}
