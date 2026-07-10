import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronger/core/models/routine.dart';
import 'package:stronger/core/models/enums.dart';
import 'package:stronger/core/theme/app_colors.dart';
import 'package:stronger/features/routines/presentation/routines_controller.dart';
import 'package:stronger/features/routines/presentation/widgets/routine_details_sheet.dart';
import 'package:stronger/features/routines/presentation/routine_editor_screen.dart';
import 'package:stronger/core/theme/enum_theme_extensions.dart';

import 'package:stronger/features/sessions/presentation/sessions_controller.dart';

class RoutinesScreen extends ConsumerWidget {
  const RoutinesScreen({super.key});

  Route _createEditorRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const RoutineEditorScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeOutQuart;
        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 8, top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(40),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 9,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routinesState = ref.watch(routinesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Routines',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      floatingActionButton: Padding(
        padding: EdgeInsets.only(
          bottom: ref.watch(activeWorkoutProvider) != null ? 60.0 : 0.0,
        ),
        child: FloatingActionButton(
          heroTag: 'routines_fab',
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.push(context, _createEditorRoute());
          },
          backgroundColor: AppColors.accent,
          child: const Icon(Icons.add),
        ),
      ),
      body: routinesState.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (routines) {
          if (routines.isEmpty) {
            return const Center(
              child: Text(
                'No routines saved yet.',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: routines.length,
            itemBuilder: (context, index) {
              final routine = routines[index];
              return Card(
                color: Theme.of(context).colorScheme.surfaceContainer,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) =>
                          RoutineDetailsSheet(routine: routine),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                routine.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            _buildTag(
                              routine.goal.name.toUpperCase(),
                              routine.goal.color,
                            ),
                          ],
                        ),
                        if (routine.description.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            routine.description,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                        const SizedBox(height: 14),
                        const Divider(height: 1, color: Colors.white10),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(
                              Icons.timer_outlined,
                              size: 16,
                              color: AppColors.accent,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${routine.estimatedDurationMinutes} min',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 24),
                            const Icon(
                              Icons.fitness_center_outlined,
                              size: 16,
                              color: AppColors.accent,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${routine.exercises.length} ${routine.exercises.length == 1 ? "exercise" : "exercises"}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
