import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronger/core/theme/app_colors.dart';
import 'package:stronger/features/sessions/presentation/sessions_controller.dart';
import 'package:stronger/features/sessions/presentation/active_workout_screen.dart';

class MiniWorkoutBar extends ConsumerWidget {
  const MiniWorkoutBar({super.key});

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hours = d.inHours;
    return hours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
  }

  void _openActiveWorkout(BuildContext context) {
    HapticFeedback.mediumImpact();
    Navigator.of(context).push(
      ActiveWorkoutScreen.route(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeWorkout = ref.watch(activeWorkoutProvider);
    if (activeWorkout == null) return const SizedBox.shrink();

    final isRestActive = activeWorkout.restSecondsRemaining > 0;

    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      child: GestureDetector(
        onVerticalDragUpdate: (details) {
          if (details.primaryDelta! < -4) {
            _openActiveWorkout(context);
          }
        },
        child: InkWell(
          onTap: () => _openActiveWorkout(context),
          child: Container(
            height: 64,
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.white10, width: 0.5),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 4),
                Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accent,
                                blurRadius: 4,
                                spreadRadius: 0.5,
                              )
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activeWorkout.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary, height: 1.1),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _formatDuration(activeWorkout.elapsedDuration),
                                style: const TextStyle(color: AppColors.accent, fontSize: 11, fontWeight: FontWeight.bold, height: 1.0),
                              ),
                            ],
                          ),
                        ),
                        if (isRestActive) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.hourglass_top, color: AppColors.accent, size: 12),
                                const SizedBox(width: 4),
                                Text(
                                  '${activeWorkout.restSecondsRemaining}s',
                                  style: const TextStyle(color: AppColors.accent, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        const Icon(Icons.keyboard_arrow_up_rounded, color: AppColors.textSecondary, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
