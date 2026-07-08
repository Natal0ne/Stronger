import 'package:flutter/material.dart';
import 'package:stronger/core/theme/app_colors.dart';
import 'package:stronger/core/models/enums.dart';

extension DifficultyExtension on Difficulty {
  Color get color {
    switch (this) {
      case Difficulty.beginner:
        return Colors.greenAccent;
      case Difficulty.intermediate:
        return Colors.orangeAccent;
      case Difficulty.advanced:
        return Colors.redAccent;
    }
  }
}

extension EquipmentExtension on Equipment {
  Color get color {
    switch (this) {
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
}

extension RoutineGoalExtension on RoutineGoal {
  Color get color {
    switch (this) {
      case RoutineGoal.hypertrophy:
        return Colors.amberAccent;
      case RoutineGoal.strength:
        return Colors.redAccent;
      case RoutineGoal.endurance:
        return Colors.lightGreenAccent;
      case RoutineGoal.powerlifting:
        return Colors.deepPurpleAccent;
    }
  }
}

extension GoalStatusExtension on GoalStatus {
  Color get color {
    switch (this) {
      case GoalStatus.active:
        return AppColors.accent;
      case GoalStatus.completed:
        return Colors.lightGreenAccent;
      case GoalStatus.abandoned:
        return Colors.grey;
    }
  }
}

extension GoalCategoryExtension on GoalCategory {
  Color get color {
    switch (this) {
      case GoalCategory.strength:
        return Colors.redAccent;
      case GoalCategory.cardio:
        return Colors.cyanAccent;
      case GoalCategory.bodyweight:
        return Colors.amberAccent;
      case GoalStatus.completed:
        return Colors.lightGreenAccent;
      case GoalCategory.frequency:
        return Colors.lightGreenAccent;
      default:
        return Colors.purpleAccent;
    }
  }

  String get label {
    switch (this) {
      case GoalCategory.strength:
        return 'Strength';
      case GoalCategory.cardio:
        return 'Cardio';
      case GoalCategory.bodyweight:
        return 'Body Weight';
      case GoalCategory.frequency:
        return 'Frequency';
      case GoalCategory.other:
        return 'Other';
    }
  }
}
