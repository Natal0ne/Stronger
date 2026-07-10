import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronger/core/models/workout_session.dart';
import 'package:stronger/core/theme/app_colors.dart';
import 'package:stronger/features/dashboard/presentation/dashboard_controller.dart';
import 'package:stronger/features/exercises/data/exercise_repository.dart';
import 'package:stronger/features/sessions/data/session_repository.dart';
import 'package:stronger/features/sessions/presentation/sessions_controller.dart';
import 'package:stronger/features/sessions/presentation/active_workout_screen.dart';
import 'package:stronger/features/sessions/presentation/widgets/session_detail_sheet.dart';

class LastSessionCard extends ConsumerWidget {
  final WorkoutSession session;

  const LastSessionCard({super.key, required this.session});

  Future<void> _openLastSessionDetail(BuildContext context, WidgetRef ref) async {
    final exercises = await ref.read(exerciseRepositoryProvider).getExercises();
    final exerciseNames = {for (var ex in exercises) ex.id: ex.name};

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SessionDetailSheet(
        session: session,
        exerciseNames: exerciseNames,
        onEdit: () async {
          Navigator.pop(context);
          final saved = await Navigator.of(context).push<bool>(
            ActiveWorkoutScreen.route(existingSession: session),
          );
          if (saved == true) ref.invalidate(dashboardProvider);
        },
        onDelete: () async {
          Navigator.pop(context);
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
              title: const Text('Delete workout?'),
              content: Text('This will permanently remove "${session.title}".'),
              actions: [
                TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                  onPressed: () async {
                    await ref.read(sessionRepositoryProvider).deleteWorkoutSession(session.id);
                    ref.invalidate(dashboardProvider);
                    ref.invalidate(historySessionsProvider);
                    ref.invalidate(scheduledSessionsProvider);
                    ref.invalidate(exerciseHistoryProvider);
                    Navigator.pop(context);
                  },
                  child: const Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateStr = '${session.date.day}/${session.date.month}/${session.date.year}';

    return Material(
      color: Theme.of(context).colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openLastSessionDetail(context, ref),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.history, color: AppColors.accent, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.title,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$dateStr · ${session.durationMinutes} min · ${session.performedExercises.length} exercises',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                    if (session.totalVolumeLifted > 0) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${session.totalVolumeLifted.toStringAsFixed(0)} kg total volume',
                        style: const TextStyle(color: AppColors.accent, fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}