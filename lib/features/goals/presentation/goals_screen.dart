import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:stronger/core/models/goal.dart';
import 'package:stronger/core/models/enums.dart';
import 'package:stronger/core/theme/app_colors.dart';
import 'package:stronger/features/goals/presentation/goals_controller.dart';
import 'package:stronger/core/theme/enum_theme_extensions.dart';
import 'widgets/goal_form_dialog.dart';
import 'package:stronger/features/sessions/presentation/sessions_controller.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  Widget _buildTag(String label, Color color) {
    return Container(
      margin: const EdgeInsets.only(top: 6),
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
    final goalsState = ref.watch(goalsProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'My Goals',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          bottom: const TabBar(
            indicatorColor: AppColors.accent,
            labelColor: AppColors.accent,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'ACTIVE', icon: Icon(Symbols.hourglass)),
              Tab(text: 'COMPLETED', icon: Icon(Icons.check)),
              Tab(text: 'ABANDONED', icon: Icon(Icons.close)),
            ],
          ),
        ),

        floatingActionButton: Padding(
          padding: EdgeInsets.only(
            bottom: ref.watch(activeWorkoutProvider) != null ? 60.0 : 0.0,
          ),
          child: FloatingActionButton(
            heroTag: 'goals_fab',
            onPressed: () {
              HapticFeedback.lightImpact();
              showDialog(
                context: context,
                builder: (_) => const GoalFormDialog(),
              );
            },
            backgroundColor: AppColors.accent,
            child: const Icon(Icons.add),
          ),
        ),
        body: goalsState.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          ),
          error: (err, stack) => Center(child: Text('Error: $err')),
          data: (goals) {
            final activeGoals = goals
            .where((g) => g.status == GoalStatus.active)
            .toList();
            final completedGoals = goals
            .where((g) => g.status == GoalStatus.completed)
            .toList();
            final abandonedGoals = goals
            .where((g) => g.status == GoalStatus.abandoned)
            .toList();

            return TabBarView(
              children: [
                _buildGoalList(context, ref, activeGoals, true),
                _buildGoalList(context, ref, completedGoals, false),
                _buildGoalList(context, ref, abandonedGoals, false),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildGoalList(
    BuildContext context,
    WidgetRef ref,
    List<Goal> list,
    bool isActiveTab,
  ) {
    if (list.isEmpty) {
      return const Center(
        child: Text(
          'No goals in this category.',
          style: TextStyle(color: Colors.grey, fontSize: 15),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final goal = list[index];
        final progress = (goal.progressPercentage / 100).clamp(0.0, 1.0);

        return Card(
          color: Theme.of(context).colorScheme.surfaceContainer,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            goal.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          _buildTag(goal.category.label, goal.category.color),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(
                            Icons.edit_outlined,
                            size: 18,
                            color: AppColors.accent,
                          ),
                          onPressed: () => showDialog(
                            context: context,
                            builder: (_) => GoalFormDialog(goal: goal),
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: Colors.redAccent,
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Delete Goal'),
                                content: Text('Remove "${goal.title}"?'),
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
                                      .read(goalsProvider.notifier)
                                      .deleteGoal(goal.id);
                                      Navigator.pop(ctx);
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
                  ],
                ),
                const SizedBox(height: 12),
                if (goal.description.isNotEmpty) ...[
                  Text(
                    goal.description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: Colors.white.withAlpha(20),
                          color: goal.status.color,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${goal.progressPercentage.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${goal.currentValue.toStringAsFixed(0)} / ${goal.targetValue.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (goal.endDate != null)
                      Row(
                        children: [
                          const Icon(
                            Icons.timer_outlined,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Deadline: ${goal.endDate!.day}/${goal.endDate!.month}/${goal.endDate!.year}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                if (isActiveTab) ...[
                  const Divider(height: 24, color: Colors.white10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent.withAlpha(40),
                          elevation: 0,
                          minimumSize: const Size(0, 32),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) {
                              final ctrl = TextEditingController(text: '5');
                              return AlertDialog(
                                title: const Text('Add Progress'),
                                content: TextField(
                                  controller: ctrl,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Amount to add',
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.accent,
                                    ),
                                    onPressed: () {
                                      final val =
                                      double.tryParse(ctrl.text) ?? 0;
                                      ref
                                      .read(goalsProvider.notifier)
                                      .incrementProgress(goal, val);
                                      Navigator.pop(ctx);
                                    },
                                    child: const Text(
                                      'Add',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        icon: const Icon(
                          Icons.add,
                          size: 14,
                          color: AppColors.accent,
                        ),
                        label: const Text(
                          'Log Progress',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.accent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}