class Goal {
  final String id;
  final String title;
  final String category;

  final double targetValue;
  final double currentValue;

  final DateTime startDate;
  final String status; // "active", "completed", "abandoned"

  Goal({
    required this.id,
    required this.title,
    required this.category,
    required this.targetValue,
    required this.currentValue,
    required this.startDate,
    required this.status,
  });

  double get progressPercentage {
    if (targetValue == 0) return 0.0;
    double percentage = (currentValue / targetValue) * 100;
    return percentage > 100 ? 100.0 : percentage;
  }
}
