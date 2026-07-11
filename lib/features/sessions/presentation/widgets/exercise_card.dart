import 'package:flutter/material.dart';
import 'package:stronger/core/models/enums.dart';
import 'package:stronger/core/models/exercise_set.dart';
import 'package:stronger/core/theme/app_colors.dart';
import 'package:stronger/features/sessions/presentation/sessions_controller.dart';
import 'set_row.dart';

class ExerciseCard extends StatelessWidget {
  final PerformedExerciseDraft draft;
  final List<ExerciseSet>? lastSets;
  final VoidCallback onRemoveExercise;
  final VoidCallback onAddSet;
  final void Function(int setIndex) onRemoveSet;
  final void Function(int setIndex, {int? reps, double? weightKg, bool? isCompleted}) onUpdateSet;

  const ExerciseCard({
    super.key,
    required this.draft,
    this.lastSets,
    required this.onRemoveExercise,
    required this.onAddSet,
    required this.onRemoveSet,
    required this.onUpdateSet,
  });

  Color _getDifficultyColor(Difficulty level) {
    switch (level) {
      case Difficulty.beginner: return Colors.greenAccent;
      case Difficulty.intermediate: return Colors.orangeAccent;
      case Difficulty.advanced: return Colors.redAccent;
    }
  }

  Color _getEquipmentColor(Equipment tool) {
    switch (tool) {
      case Equipment.bodyweight: return Colors.cyanAccent;
      case Equipment.dumbbell: return Colors.purpleAccent;
      case Equipment.barbell: return Colors.blueAccent;
      case Equipment.machine: return Colors.amberAccent;
      case Equipment.cable: return Colors.pinkAccent;
    }
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        draft.exercise.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.timer_outlined, size: 14, color: AppColors.accent),
                          const SizedBox(width: 4),
                          Text(
                            'Rest Time: ${draft.exercise.defaultRestSeconds}s',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    iconSize: 18,
                    tooltip: 'Remove exercise',
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: onRemoveExercise,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Wrap(
              spacing: 6, runSpacing: 4,
              children: [
                _buildTag(draft.exercise.primaryMuscleGroup.name, AppColors.accent),
                _buildTag(draft.exercise.equipment.name, _getEquipmentColor(draft.exercise.equipment)),
                _buildTag(draft.exercise.difficulty.name, _getDifficultyColor(draft.exercise.difficulty)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < draft.sets.length; i++) ...[
            Dismissible(
              key: draft.setKeys[i],
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 16),
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.delete_outline, color: Colors.redAccent),
              ),
              onDismissed: (_) => onRemoveSet(i),
              child: SetRow(
                setIndex: i,
                set: draft.sets[i],
                previousSet: (lastSets != null && i < lastSets!.length) ? lastSets![i] : null,
                exerciseRecommendedReps: draft.exercise.recommendedReps,
                onRemove: () => onRemoveSet(i),
                onUpdate: ({reps, weightKg, isCompleted}) => onUpdateSet(
                  i,
                  reps: reps,
                  weightKg: weightKg,
                  isCompleted: isCompleted,
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Center(
            child: TextButton.icon(
              onPressed: onAddSet,
              icon: const Icon(Icons.add, size: 18, color: AppColors.accent),
              label: const Text('Add Set', style: TextStyle(color: AppColors.accent)),
            ),
          ),
        ],
      ),
    );
  }
}
