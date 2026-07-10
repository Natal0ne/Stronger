import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronger/core/models/workout_session.dart';
import 'package:stronger/core/models/enums.dart';
import 'package:stronger/core/models/routine.dart';
import 'package:stronger/core/models/exercise.dart';
import 'package:stronger/core/database/preferences_provider.dart';
import 'package:stronger/features/exercises/data/exercise_repository.dart';
import 'package:stronger/features/routines/data/routine_repository.dart';
import 'package:stronger/features/sessions/data/session_repository.dart';

enum ChartMetric { volume, workouts }

class DashboardData {
  final int completedThisWeek;
  final int scheduledThisWeek;
  final int routineCount;
  final int exerciseCount;
  final WorkoutSession? todaySession;
  final WorkoutSession? lastCompletedSession;
  final double weeklyVolume;
  final int todayExerciseCount;
  final List<double> last4WeeksVolume;
  final List<double> last4WeeksWorkouts;

  final int totalWorkoutsEver;
  final double totalVolumeEver;

  DashboardData({
    required this.completedThisWeek,
    required this.scheduledThisWeek,
    required this.routineCount,
    required this.exerciseCount,
    this.todaySession,
    this.lastCompletedSession,
    required this.weeklyVolume,
    required this.todayExerciseCount,
    required this.last4WeeksVolume,
    required this.last4WeeksWorkouts,
    required this.totalWorkoutsEver,
    required this.totalVolumeEver,
  });
}

final dashboardProvider = FutureProvider<DashboardData>((ref) async {
  final sessionRepo = ref.read(sessionRepositoryProvider);
  final routineRepo = ref.read(routineRepositoryProvider);
  final exerciseRepo = ref.read(exerciseRepositoryProvider);

  final results = await Future.wait<dynamic>([
    sessionRepo.getWorkoutSessions(),
    sessionRepo.getScheduledSessionsForWeek(DateTime.now()),
    routineRepo.getRoutines(),
    exerciseRepo.getExercises(),
  ]);

  final allSessions = results[0] as List<WorkoutSession>;
  final scheduledSessions = results[1] as List<WorkoutSession>;
  final routines = results[2] as List<Routine>;
  final exercises = results[3] as List<Exercise>;

  final now = DateTime.now();
  WorkoutSession? todayScheduled;
  for (var session in scheduledSessions) {
    if (session.status == WorkoutStatus.scheduled &&
      session.date.year == now.year &&
      session.date.month == now.month &&
      session.date.day == now.day) {
      todayScheduled = session;
    break;
      }
  }

  final weekStart = DateTime.now().subtract(
    Duration(days: DateTime.now().weekday - 1),
  );
  final w0Start = DateTime(weekStart.year, weekStart.month, weekStart.day);

  final w1Start = w0Start.subtract(const Duration(days: 7));
  final w2Start = w0Start.subtract(const Duration(days: 14));
  final w3Start = w0Start.subtract(const Duration(days: 21));

  double volW0 = 0;
  double volW1 = 0;
  double volW2 = 0;
  double volW3 = 0;

  double totalVolumeEver = 0;

  double countW0 = 0;
  double countW1 = 0;
  double countW2 = 0;
  double countW3 = 0;

  int completedThisWeek = 0;
  int scheduledThisWeek = 0;
  WorkoutSession? lastCompleted;

  for (final session in allSessions) {
    final isThisWeek =
    !session.date.isBefore(w0Start) &&
    session.date.isBefore(w0Start.add(const Duration(days: 7)));

    if (isThisWeek) {
      if (session.status == WorkoutStatus.scheduled ||
        session.id.startsWith('sched_') ||
        session.id.startsWith('recur_')) {
        scheduledThisWeek++;
        }
        if (session.status == WorkoutStatus.completed) {
          completedThisWeek++;
        }
    }

    if (session.status == WorkoutStatus.completed) {
      lastCompleted ??= session;

      totalVolumeEver += session.totalVolumeLifted;

      if (!session.date.isBefore(w0Start) &&
        session.date.isBefore(w0Start.add(const Duration(days: 7)))) {
        volW0 += session.totalVolumeLifted;
        countW0++;
        } else if (!session.date.isBefore(w1Start) &&
          session.date.isBefore(w0Start)) {
          volW1 += session.totalVolumeLifted;
        countW1++;
          } else if (!session.date.isBefore(w2Start) &&
            session.date.isBefore(w1Start)) {
            volW2 += session.totalVolumeLifted;
          countW2++;
            } else if (!session.date.isBefore(w3Start) &&
              session.date.isBefore(w2Start)) {
              volW3 += session.totalVolumeLifted;
            countW3++;
              }
    }
  }

  int todayExerciseCount = 0;
  if (todayScheduled != null && todayScheduled.routineId.isNotEmpty) {
    final routineExercises = await exerciseRepo.getExercisesForRoutine(
      todayScheduled.routineId,
    );
    todayExerciseCount = routineExercises.length;
  }

  return DashboardData(
    completedThisWeek: completedThisWeek,
    scheduledThisWeek: scheduledThisWeek,
    routineCount: routines.length,
    exerciseCount: exercises.length,
    todaySession: todayScheduled,
    lastCompletedSession: lastCompleted,
    weeklyVolume: volW0,
    todayExerciseCount: todayExerciseCount,
    last4WeeksVolume: [volW3, volW2, volW1, volW0],
    last4WeeksWorkouts: [countW3, countW2, countW1, countW0],
    totalWorkoutsEver: allSessions
    .where((s) => s.status == WorkoutStatus.completed)
    .length,
    totalVolumeEver: totalVolumeEver,
  );
});

class UsernameNotifier extends Notifier<String> {
  @override
  String build() {
    final prefs = ref.read(sharedPreferencesProvider);
    return prefs.getString('username') ?? 'User';
  }

  void updateUsername(String newName) {
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setString('username', newName);
    state = newName;
  }
}

final usernameProvider = NotifierProvider<UsernameNotifier, String>(
  UsernameNotifier.new,
);

final activeChartMetricProvider = StateProvider<ChartMetric>(
  (ref) => ChartMetric.volume,
);
