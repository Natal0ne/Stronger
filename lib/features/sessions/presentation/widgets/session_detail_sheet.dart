import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronger/core/models/workout_session.dart';
import 'package:stronger/core/models/enums.dart';
import 'package:stronger/core/models/exercise_set.dart';
import 'package:stronger/core/theme/app_colors.dart';
import 'package:stronger/features/sessions/presentation/sessions_controller.dart';

Color _sessionRpeColor(int rpe) {
  if (rpe <= 2) return Colors.greenAccent;
  if (rpe == 3) return Colors.amberAccent;
  return Colors.redAccent;
}

class SessionDetailSheet extends ConsumerWidget {
  final WorkoutSession session;
  final Map<String, String> exerciseNames;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const SessionDetailSheet({
    super.key,
    required this.session,
    required this.exerciseNames,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCompleted = session.status == WorkoutStatus.completed;
    final historyState = ref.watch(historySessionsProvider);

    if (historyState.isLoading) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
      );
    }

    final historyList = historyState.value ?? [];

    final currentSessionIndex = historyList.indexWhere((sess) => sess.id == session.id);
    final previousSessions = currentSessionIndex != -1
    ? historyList.sublist(currentSessionIndex + 1)
    : <WorkoutSession>[];

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  session.title,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
              ),
              if (isCompleted && onEdit != null)
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: AppColors.accent),
                  tooltip: 'Edit workout',
                  onPressed: onEdit,
                ),
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: onDelete,
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${session.date.day}/${session.date.month}/${session.date.year}',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.timer_outlined, size: 18, color: AppColors.accent),
                  const SizedBox(width: 8),
                  Text('${session.durationMinutes} min', style: const TextStyle(color: AppColors.textPrimary)),
                ],
              ),
               const SizedBox(width: 16),
               Row(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   const Icon(Icons.fitness_center, size: 18, color: AppColors.accent),
                   const SizedBox(width: 8),
                   Text('${session.performedExercises.length} exercises', style: const TextStyle(color: AppColors.textPrimary)),
                 ],
               ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isCompleted ? Colors.green.withAlpha(40) : AppColors.advanced.withAlpha(40),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  session.status.name.toUpperCase(),
                  style: TextStyle(
                    color: isCompleted ? Colors.greenAccent : AppColors.advanced,
                    fontSize: 11, fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.purpleAccent.withAlpha(40),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${session.totalVolumeLifted.toStringAsFixed(0)} KG VOLUME',
                    style: const TextStyle(color: Colors.purpleAccent, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _sessionRpeColor(session.fatigueLevel).withAlpha(40),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'RPE ${session.fatigueLevel}/5',
                    style: TextStyle(
                      color: _sessionRpeColor(session.fatigueLevel),
                      fontSize: 11, fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const Divider(height: 32, color: Colors.white10),
          Expanded(
            child: session.performedExercises.isEmpty
            ? const Center(
              child: Text('No exercises logged for this session.', style: TextStyle(color: AppColors.textSecondary)),
            )
            : ListView(
              children: [
                for (var ex in session.performedExercises)
                  Builder(
                    builder: (context) {
                      WorkoutSession? prevSession;
                      for (var sess in previousSessions) {
                        final hasExercise = sess.performedExercises.any((pe) => pe.exerciseId == ex.exerciseId);
                        if (hasExercise) {
                          prevSession = sess;
                          break;
                        }
                      }

                      final prevPe = prevSession?.performedExercises.firstWhere((pe) => pe.exerciseId == ex.exerciseId);

                      return Card(
                        color: Theme.of(context).colorScheme.surfaceContainerHigh,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.fitness_center, size: 16, color: AppColors.accent),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      exerciseNames[ex.exerciseId] ?? ex.exerciseId,
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 15),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              for (var s in ex.sets)
                                Builder(
                                  builder: (context) {
                                    final matchedSets = prevPe?.sets.where((prevS) => prevS.setNumber == s.setNumber && prevS.isCompleted).toList();
                                    final previousSet = (matchedSets != null && matchedSets.isNotEmpty) ? matchedSets.first : null;

                                    final isHistoricalPR = s.isCompleted && previousSet != null &&
                                    (s.weightKg > previousSet.weightKg ||
                                    (s.weightKg == previousSet.weightKg && s.reps > previousSet.reps));

                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 6),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 22, height: 22,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(color: AppColors.accent.withAlpha(30), shape: BoxShape.circle),
                                            child: Text(
                                              '${s.setNumber}',
                                              style: const TextStyle(color: AppColors.accent, fontSize: 11, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            '${s.weightKg.toStringAsFixed(0).replaceAll('.', ',')}kg × ${s.reps} reps',
                                            style: const TextStyle(color: AppColors.textSecondary),
                                          ),
                                          const SizedBox(width: 8),
                                          if (!s.isCompleted)
                                            const Text('(not completed)', style: TextStyle(color: Colors.grey, fontSize: 11, fontStyle: FontStyle.italic))
                                            else ...[
                                              const Icon(Icons.check_circle, size: 14, color: Colors.greenAccent),
                                              if (isHistoricalPR) ...[
                                                const SizedBox(width: 8),
                                                const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                                              ]
                                            ],
                                        ],
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                      );
                    }
                  ),
                  if (session.notes.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    const Text('Notes', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    Text(session.notes, style: const TextStyle(color: AppColors.textSecondary)),
                  ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
