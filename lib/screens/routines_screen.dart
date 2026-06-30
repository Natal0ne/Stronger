import 'package:flutter/material.dart';
import 'package:stronger/models/routine.dart';
import 'package:stronger/models/routine_exercise.dart';
import 'package:stronger/models/exercise.dart';
import 'package:stronger/models/enums.dart';
import 'package:stronger/services/database_helper.dart';
import 'package:stronger/theme/app_colors.dart';
import 'package:stronger/screens/routine_editor_screen.dart';

class RoutinesScreen extends StatefulWidget {
  const RoutinesScreen({super.key});

  @override
  State<RoutinesScreen> createState() => _RoutinesScreenState();
}

class _RoutinesScreenState extends State<RoutinesScreen> {
  List<Routine> _routines = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final routines = await DatabaseHelper.instance.getRoutines();
      setState(() {
        _routines = routines;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Creazione di una transizione stilosa (scorrimento dal basso)
  Route _createEditorRoute([Routine? routine]) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          RoutineEditorScreen(routine: routine),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeOutQuart;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(position: offsetAnimation, child: child);
      },
    );
  }

  Color _getGoalColor(RoutineGoal goal) {
    switch (goal) {
      case RoutineGoal.hypertrophy:
        return Colors.amberAccent;
      case RoutineGoal.strength:
        return Colors.redAccent;
      case RoutineGoal.endurance:
        return Colors.lightGreenAccent;
      case RoutineGoal.powerlifting:
        return Colors.deepPurpleAccent;
      default:
        return Colors.white;
    }
  }

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

  void _showRoutineDetails(Routine routine) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
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
                    routine.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: AppColors.accent,
                  ),
                  onPressed: () async {
                    Navigator.pop(context); // Chiude il bottom sheet
                    final result = await Navigator.push(
                      context,
                      _createEditorRoute(routine),
                    );
                    if (result == true) {
                      _fetchData();
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete Routine'),
                        content: Text(
                          'Are you sure you want to delete "${routine.name}"?',
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
                            onPressed: () async {
                              await DatabaseHelper.instance.deleteRoutine(
                                routine.id,
                              );
                              _fetchData();
                              if (ctx.mounted) Navigator.pop(ctx);
                              if (context.mounted) Navigator.pop(context);
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
            Row(
              children: [
                const Icon(
                  Icons.timer_outlined,
                  size: 18,
                  color: AppColors.accent,
                ),
                const SizedBox(width: 8),
                Text(
                  '${routine.estimatedDurationMinutes} min',
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
                const SizedBox(width: 24),
                const Icon(
                  Icons.fitness_center,
                  size: 18,
                  color: AppColors.accent,
                ),
                const SizedBox(width: 8),
                Text(
                  '${routine.exercises.length} exercises',
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
              ],
            ),
            const Divider(height: 32, color: Colors.white10),
            Expanded(
              child: ListView.builder(
                itemCount: routine.exercises.length,
                itemBuilder: (context, index) {
                  final re = routine.exercises[index];
                  return Card(
                    color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(
                        re.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withAlpha(40),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${re.sets} SETS × ${re.reps} REPS',
                          style: const TextStyle(
                            color: AppColors.accent,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Routines',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'routines_fab',
        onPressed: () async {
          final result = await Navigator.push(context, _createEditorRoute());
          if (result == true) {
            _fetchData();
          }
        },
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _routines.length,
        itemBuilder: (context, index) {
          final routine = _routines[index];
          return Card(
            color: Theme.of(context).colorScheme.surfaceContainer,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              onTap: () => _showRoutineDetails(routine),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            routine.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        _buildTag(
                          routine.goal.name.toUpperCase(),
                          _getGoalColor(routine.goal),
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
      ),
    );
  }
}
