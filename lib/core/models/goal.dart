import 'package:stronger/core/models/enums.dart';

class Goal {
  final String id;
  final String title;
  final String description;
  final GoalCategory category;
  final double startingValue;
  final double targetValue;
  final double currentValue;
  final DateTime startDate;
  final DateTime? endDate;
  final GoalStatus status;
  final String notes;

  Goal({
    required this.id,
    required this.title,
    this.description = "",
    required this.category,
    required this.startingValue,
    required this.targetValue,
    required this.currentValue,
    required this.startDate,
    this.endDate,
    required this.status,
    this.notes = "",
  });

  double get progressPercentage {
    if (status == GoalStatus.completed) return 100.0;

    double totalDistance = (targetValue - startingValue).abs();
    if (totalDistance == 0) return 0.0;

    double completedDistance;
    if (targetValue >= startingValue) {
      completedDistance = currentValue - startingValue;
    } else {
      completedDistance = startingValue - currentValue;
    }

    if (completedDistance <= 0) return 0.0;

    double percentage = (completedDistance / totalDistance) * 100;
    return percentage > 100 ? 100.0 : percentage;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.name,
      'startingValue': startingValue,
      'targetValue': targetValue,
      'currentValue': currentValue,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'status': status.name,
      'notes': notes,
    };
  }

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String? ?? "",
      category: GoalCategory.values.byName(map['category'] as String),
      startingValue: (map['startingValue'] as num? ?? 0.0).toDouble(),
      targetValue: (map['targetValue'] as num).toDouble(),
      currentValue: (map['currentValue'] as num).toDouble(),
      startDate: DateTime.parse(map['startDate'] as String),
      endDate: map['endDate'] != null
          ? DateTime.parse(map['endDate'] as String)
          : null,
      status: GoalStatus.values.byName(map['status'] as String),
      notes: map['notes'] as String? ?? "",
    );
  }
}
