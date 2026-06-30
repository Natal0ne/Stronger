import 'package:flutter/material.dart';
import 'package:stronger/models/enums.dart';
import 'package:stronger/models/workout_session.dart';
import 'package:stronger/services/database_helper.dart';
import 'package:stronger/theme/app_colors.dart';
import 'active_workout_screen.dart';
import 'workout_screen.dart';

class HomeScreen extends StatefulWidget {
  final void Function(int tabIndex)? onNavigateToTab;

  const HomeScreen({super.key, this.onNavigateToTab});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _completedThisWeek = 0;
  int _scheduledThisWeek = 0;
  int _routineCount = 0;
  int _exerciseCount = 0;
  WorkoutSession? _todaySession;
  WorkoutSession? _lastCompletedSession;
  double _weeklyVolume = 0;
  int _todayExerciseCount = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    reloadDashboard();
  }

  /// Called when the Home tab becomes visible again.
  Future<void> reloadDashboard() async {
    setState(() => _loading = true);

    final db = DatabaseHelper.instance;
    final completed = await db.countCompletedWorkoutsThisWeek();
    final scheduled = await db.countScheduledSessionsThisWeek();
    final routines = await db.countRoutines();
    final exercises = await db.countExercises();
    final todaySessions = await db.getSessionsForDay(DateTime.now());

    WorkoutSession? todayScheduled;
    for (var session in todaySessions) {
      if (session.status == WorkoutStatus.scheduled) {
        todayScheduled = session;
        break;
      }
    }

    WorkoutSession? lastCompleted;
    double weeklyVolume = 0;
    final weekStart = DateTime.now().subtract(
      Duration(days: DateTime.now().weekday - 1),
    );
    final weekStartMidnight = DateTime(
      weekStart.year,
      weekStart.month,
      weekStart.day,
    );
    final weekEnd = weekStartMidnight.add(const Duration(days: 7));

    final allSessions = await db.getWorkoutSessions();
    for (final session in allSessions) {
      if (session.status == WorkoutStatus.completed) {
        lastCompleted ??= session;
        if (!session.date.isBefore(weekStartMidnight) &&
            session.date.isBefore(weekEnd)) {
          weeklyVolume += session.totalVolumeLifted;
        }
      }
    }

    int todayExerciseCount = 0;
    if (todayScheduled != null && todayScheduled.routineId.isNotEmpty) {
      final routineExercises = await db.getExercisesForRoutine(
        todayScheduled.routineId,
      );
      todayExerciseCount = routineExercises.length;
    }

    if (!mounted) return;
    setState(() {
      _completedThisWeek = completed;
      _scheduledThisWeek = scheduled;
      _routineCount = routines;
      _exerciseCount = exercises;
      _todaySession = todayScheduled;
      _lastCompletedSession = lastCompleted;
      _weeklyVolume = weeklyVolume;
      _todayExerciseCount = todayExerciseCount;
      _loading = false;
    });
  }

  Future<void> _startTodayWorkout() async {
    if (_todaySession == null) return;
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ActiveWorkoutScreen(
          existingSession: _todaySession,
          routineId: _todaySession!.routineId,
          initialTitle: _todaySession!.title,
        ),
      ),
    );
    if (saved == true) reloadDashboard();
  }

  Future<void> _openLastSessionDetail() async {
    final session = _lastCompletedSession;
    if (session == null) return;

    final exercises = await DatabaseHelper.instance.getExercises();
    if (!mounted) return;
    final exerciseNames = {for (var ex in exercises) ex.id: ex.name};

    showSessionDetailSheet(
      context,
      session,
      exerciseNames,
      onEdit: () async {
        Navigator.pop(context);
        final saved = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => ActiveWorkoutScreen(existingSession: session),
          ),
        );
        if (saved == true) reloadDashboard();
      },
      onDelete: () async {
        Navigator.pop(context);
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
            title: const Text('Delete workout?'),
            content: Text('This will permanently remove "${session.title}".'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
          ),
        );
        if (confirmed == true) {
          await DatabaseHelper.instance.deleteWorkoutSession(session.id);
          reloadDashboard();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Be Stronger Everyday!',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.account_circle,
              color: AppColors.textPrimary,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: reloadDashboard,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeHeader(context, _completedThisWeek),
                    const SizedBox(height: 16),
                    _buildWeekProgressCard(context),
                    const SizedBox(height: 24),
                    const Text(
                      'Today\'s Workout',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildTodayWorkoutCard(context),
                    if (_lastCompletedSession != null) ...[
                      const SizedBox(height: 24),
                      const Text(
                        'Last Session',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildLastSessionCard(context),
                    ],
                    const SizedBox(height: 24),
                    const Text(
                      'Your Progress',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildStatsGrid(context),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildWelcomeHeader(BuildContext context, int completed) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hello! 👋',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            completed > 0
                ? 'You have completed $completed workout${completed == 1 ? '' : 's'} this week. Keep it up!'
                : 'No workouts completed yet this week. Plan your sessions and get started!',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekProgressCard(BuildContext context) {
    final total = _scheduledThisWeek > 0 ? _scheduledThisWeek : 1;
    final progress = (_completedThisWeek / total).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Weekly Overview',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '$_completedThisWeek / $_scheduledThisWeek',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withAlpha(20),
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildMiniStat(
                icon: Icons.fitness_center,
                label: 'Volume',
                value: _weeklyVolume >= 1000
                    ? '${(_weeklyVolume / 1000).toStringAsFixed(1)}t'
                    : '${_weeklyVolume.toStringAsFixed(0)} kg',
              ),
              const SizedBox(width: 16),
              _buildMiniStat(
                icon: Icons.event_available,
                label: 'Planned',
                value: '$_scheduledThisWeek',
              ),
              const SizedBox(width: 16),
              _buildMiniStat(
                icon: Icons.check_circle_outline,
                label: 'Done',
                value: '$_completedThisWeek',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayWorkoutCard(BuildContext context) {
    if (_todaySession == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'No workout planned for today',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Head to Workout → Plan New to schedule your week.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
      );
    }

    final session = _todaySession!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFD4FC79), AppColors.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'SCHEDULED',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.black87,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${session.durationMinutes} min',
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            session.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          if (_todayExerciseCount > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.fitness_center,
                  size: 14,
                  color: Colors.black54,
                ),
                const SizedBox(width: 4),
                Text(
                  '$_todayExerciseCount exercise${_todayExerciseCount == 1 ? '' : 's'} planned',
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _startTodayWorkout,
              icon: const Icon(Icons.play_arrow, color: Colors.white),
              label: const Text(
                'START WORKOUT',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLastSessionCard(BuildContext context) {
    final session = _lastCompletedSession!;
    final dateStr =
        '${session.date.day}/${session.date.month}/${session.date.year}';

    return Material(
      color: Theme.of(context).colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: _openLastSessionDetail,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.history,
                  color: AppColors.accent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$dateStr · ${session.durationMinutes} min · ${session.performedExercises.length} exercises',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (session.totalVolumeLifted > 0) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${session.totalVolumeLifted.toStringAsFixed(0)} kg total volume',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.accent,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  label: 'Completed',
                  subtitle: 'This week',
                  value: '$_completedThisWeek',
                  icon: Icons.check_circle_outline,
                  iconColor: AppColors.accent,
                  onTap: () => widget.onNavigateToTab?.call(1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  context,
                  label: 'Planned',
                  subtitle: 'This week',
                  value: '$_scheduledThisWeek',
                  icon: Icons.event_available,
                  iconColor: Colors.blueAccent,
                  onTap: () => widget.onNavigateToTab?.call(1),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  label: 'Routines',
                  subtitle: 'Created',
                  value: '$_routineCount',
                  icon: Icons.fitness_center,
                  iconColor: AppColors.advanced,
                  onTap: () => widget.onNavigateToTab?.call(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  context,
                  label: 'Exercises',
                  subtitle: 'Saved',
                  value: '$_exerciseCount',
                  icon: Icons.list_alt,
                  iconColor: Colors.purpleAccent,
                  onTap: () => widget.onNavigateToTab?.call(3),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required String label,
    required String subtitle,
    required String value,
    required IconData icon,
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(height: 10),
              Text(
                value,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
