import 'package:flutter/material.dart';
import 'package:stronger/models/enums.dart';
import 'package:stronger/models/workout_session.dart';
import 'package:stronger/services/database_helper.dart';
import 'package:stronger/theme/app_colors.dart';
import 'active_workout_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _completedThisWeek = 0;
  int _scheduledThisWeek = 0;
  int _routineCount = 0;
  int _exerciseCount = 0;
  WorkoutSession? _todaySession;
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

    if (!mounted) return;
    setState(() {
      _completedThisWeek = completed;
      _scheduledThisWeek = scheduled;
      _routineCount = routines;
      _exerciseCount = exercises;
      _todaySession = todayScheduled;
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
                  const Icon(Icons.access_time, size: 16, color: Colors.black87),
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
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
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
    );
  }
}
