/// Weekly recurrence: same routine on a fixed weekday every week.
class RecurringSchedule {
  final String id;
  final String routineId;
  final int weekday; // Mon=1 … Sun=7
  final String title;
  final int durationMinutes;
  final String notes;

  const RecurringSchedule({
    required this.id,
    required this.routineId,
    required this.weekday,
    required this.title,
    required this.durationMinutes,
    this.notes = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'routineId': routineId,
      'weekday': weekday,
      'title': title,
      'durationMinutes': durationMinutes,
      'notes': notes,
    };
  }

  factory RecurringSchedule.fromMap(Map<String, dynamic> map) {
    return RecurringSchedule(
      id: map['id'] as String,
      routineId: map['routineId'] as String,
      weekday: map['weekday'] as int,
      title: map['title'] as String,
      durationMinutes: map['durationMinutes'] as int,
      notes: (map['notes'] as String?) ?? '',
    );
  }
}
