import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronger/core/models/exercise.dart';
import 'package:stronger/core/models/enums.dart';
import 'package:stronger/core/theme/app_colors.dart';
import 'package:stronger/features/exercises/presentation/exercises_controller.dart';
import 'package:stronger/core/theme/enum_theme_extensions.dart';
import 'package:stronger/features/sessions/presentation/sessions_controller.dart';
import 'exercise_form_dialog.dart';

class LineChartPainter extends CustomPainter {
  final List<double> values;
  final double maxVal;

  LineChartPainter({required this.values, required this.maxVal});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..strokeWidth = 1.0;

    for (var i = 0; i < 3; i++) {
      double y = 15 + i * (size.height - 30) / 2;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (values.isEmpty) return;

    final linePaint = Paint()
      ..color = AppColors.accent
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dotOutlinePaint = Paint()
      ..color = Colors.greenAccent
      ..style = PaintingStyle.fill;

    final dotInnerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final glowPaint = Paint()
      ..color = AppColors.accent.withOpacity(0.15)
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final double padding = values.length > 1 ? 28.0 : 0.0;
    final double chartWidth = size.width - 2 * padding;
    final double chartHeight = size.height - 30.0;

    final double segmentWidth = values.length > 1
        ? (chartWidth / (values.length - 1))
        : 0.0;

    final path = Path();
    final points = <Offset>[];

    for (int i = 0; i < values.length; i++) {
      double x = values.length > 1
          ? (padding + i * segmentWidth)
          : (size.width / 2);

      double heightRatio = maxVal > 0 ? (values[i] / maxVal) : 0.0;
      double y = (size.height - 15) - (heightRatio * chartHeight);
      points.add(Offset(x, y));

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    if (values.length > 1) {
      canvas.drawPath(path, glowPaint);
      canvas.drawPath(path, linePaint);
    }

    for (var pt in points) {
      canvas.drawCircle(pt, 5.0, dotOutlinePaint);
      canvas.drawCircle(pt, 2.0, dotInnerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant LineChartPainter oldDelegate) => true;
}

class ExerciseDetailsSheet extends ConsumerWidget {
  final Exercise exercise;

  const ExerciseDetailsSheet({super.key, required this.exercise});

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

  Color _getMuscleColor(MuscleGroup muscle) => AppColors.accent;

  Widget _buildTag(String label, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
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

  Widget _buildLineChart(BuildContext context, List<double> history) {
    final isEmptyState = history.isEmpty;
    final displayList = isEmptyState ? [0.0, 0.0, 0.0, 0.0] : history;
    final maxVal = isEmptyState
        ? 1.0
        : displayList.reduce((a, b) => a > b ? a : b);

    const double canvasHeight = 100.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Strength Progression (Per Workout)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              Icon(
                Icons.show_chart_rounded,
                color: isEmptyState ? Colors.grey : AppColors.accent,
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: 16),

          SizedBox(
            height: canvasHeight + 35,
            child: Stack(
              children: [
                Positioned(
                  top: 15,
                  left: 0,
                  right: 0,
                  height: canvasHeight,
                  child: CustomPaint(
                    painter: LineChartPainter(
                      values: displayList,
                      maxVal: maxVal,
                    ),
                  ),
                ),

                Positioned(
                  top: 0,
                  left: 16,
                  right: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      for (var val in displayList)
                        Text(
                          val > 0 ? '${val.toStringAsFixed(0)}kg' : '-',
                          style: TextStyle(
                            fontSize: 10,
                            color: isEmptyState
                                ? Colors.grey
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),

                if (isEmptyState)
                  const Positioned.fill(
                    child: Center(
                      child: Text(
                        'No workout logged yet.\nTrack your first session to see progress!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),

                Positioned(
                  bottom: 0,
                  left: 16,
                  right: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      for (var i = 0; i < displayList.length; i++)
                        Text(
                          'Log ${i + 1}',
                          style: const TextStyle(
                            fontSize: 9,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyState = ref.watch(exerciseHistoryProvider(exercise.id));

    return Container(
      height: MediaQuery.of(context).size.height * 0.70,
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
                  exercise.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: AppColors.accent),
                onPressed: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (ctx) => ExerciseFormDialog(exercise: exercise),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete Exercise'),
                      content: Text(
                        'Are you sure you want to delete "${exercise.name}"?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                          ),
                          onPressed: () {
                            ref
                                .read(exercisesProvider.notifier)
                                .deleteExercise(exercise.id);
                            Navigator.pop(ctx);
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Delete',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _buildTag(
                exercise.primaryMuscleGroup.name.toUpperCase(),
                _getMuscleColor(exercise.primaryMuscleGroup),
              ),
              _buildTag(
                exercise.equipment.name.toUpperCase(),
                _getEquipmentColor(exercise.equipment),
              ),
              _buildTag(
                exercise.difficulty.name.toUpperCase(),
                _getDifficultyColor(exercise.difficulty),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recommended Reps',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.repeat,
                          color: AppColors.accent,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${exercise.recommendedReps} Reps',
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Default Rest Time',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.timer_outlined,
                          size: 18,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${exercise.defaultRestSeconds}s Rest',
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Description / Instructions',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    exercise.description,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                  if (exercise.notes.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const Text(
                      'Notes',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      exercise.notes,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),
                  historyState.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(color: AppColors.accent),
                    ),
                    error: (err, stack) => Container(),
                    data: (historyList) {
                      return _buildLineChart(context, historyList);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
