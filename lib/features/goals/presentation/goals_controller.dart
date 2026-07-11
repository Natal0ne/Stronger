import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:stronger/core/models/goal.dart';
import 'package:stronger/core/models/enums.dart';
import 'package:stronger/features/goals/data/goal_repository.dart';
import 'package:stronger/features/dashboard/presentation/dashboard_controller.dart';

class GoalsNotifier extends AsyncNotifier<List<Goal>> {
  @override
  Future<List<Goal>> build() async {
    return ref.read(goalRepositoryProvider).getGoals();
  }

  Future<void> addGoal(Goal goal) async {
    await ref.read(goalRepositoryProvider).insertGoal(goal);
    ref.invalidateSelf();
    ref.invalidate(dashboardProvider);
  }

  Future<void> deleteGoal(String id) async {
    await ref.read(goalRepositoryProvider).deleteGoal(id);
    ref.invalidateSelf();
    ref.invalidate(dashboardProvider);
  }

  Future<void> incrementProgress(Goal goal, double incrementValue) async {
    double updatedValue;
    bool isCompleted;

    if (goal.targetValue >= goal.startingValue) {
      updatedValue = goal.currentValue + incrementValue;
      isCompleted = updatedValue >= goal.targetValue;

      if (updatedValue > goal.targetValue) {
        updatedValue = goal.targetValue;
      }
    } else {
      updatedValue = goal.currentValue - incrementValue;
      isCompleted = updatedValue <= goal.targetValue;

      if (updatedValue < goal.targetValue) {
        updatedValue = goal.targetValue;
      }
    }

    if (isCompleted && goal.status == GoalStatus.active) {
      HapticFeedback.vibrate();
    }

    final updatedGoal = Goal(
      id: goal.id,
      title: goal.title,
      description: goal.description,
      category: goal.category,
      startingValue: goal.startingValue,
      targetValue: goal.targetValue,
      currentValue: updatedValue,
      startDate: goal.startDate,
      endDate: goal.endDate,
      status: isCompleted ? GoalStatus.completed : goal.status,
      notes: goal.notes,
    );

    await ref.read(goalRepositoryProvider).insertGoal(updatedGoal);
    ref.invalidateSelf();
    ref.invalidate(dashboardProvider);
  }
}

final goalsProvider = AsyncNotifierProvider<GoalsNotifier, List<Goal>>(
  GoalsNotifier.new,
);