import 'package:flutter/material.dart';
import 'package:stronger/theme/app_colors.dart';
import 'package:stronger/models/workout_session.dart';
import 'package:stronger/models/enums.dart';
import 'package:stronger/services/database_helper.dart';
import 'active_workout_screen.dart';
import 'workout_planning_screen.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => WorkoutScreenState();
}

class WorkoutScreenState extends State<WorkoutScreen> {
  late Future<List<WorkoutSession>> _historyFuture;
  late Future<List<WorkoutSession>> _scheduledFuture;
  Map<String, String> _exerciseNames = {};

  @override
  void initState() {
    super.initState();
    _refreshAll();
    _loadExerciseNames();
  }

  void refreshAll() {
    setState(() {
      _historyFuture = DatabaseHelper.instance.getWorkoutSessions().then(
        (sessions) =>
            sessions.where((s) => s.status != WorkoutStatus.scheduled).toList(),
      );
      _scheduledFuture = DatabaseHelper.instance.getScheduledSessionsForWeek(
        DateTime.now(),
      );
    });
  }

  void _refreshAll() => refreshAll();

  void _refreshHistory() => _refreshAll();

  Future<void> _loadExerciseNames() async {
    final exercises = await DatabaseHelper.instance.getExercises();
    if (!mounted) return;

    setState(() {
      _exerciseNames = {for (var ex in exercises) ex.id: ex.name};
    });
  }

  Future<void> _startEmptyWorkout() async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const ActiveWorkoutScreen()),
    );
    if (saved == true) _refreshAll();
  }

  Future<void> _startScheduledWorkout(WorkoutSession session) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ActiveWorkoutScreen(
          existingSession: session,
          routineId: session.routineId,
          initialTitle: session.title,
        ),
      ),
    );
    if (saved == true) _refreshAll();
  }

  Future<void> _editWorkout(WorkoutSession session) async {
    Navigator.pop(context);
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ActiveWorkoutScreen(existingSession: session),
      ),
    );
    if (saved == true) _refreshAll();
  }

  Future<void> _confirmDelete(WorkoutSession session) async {
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
      _refreshAll();
    }
  }

  void _showSessionDetail(WorkoutSession session) {
    showSessionDetailSheet(
      context,
      session,
      _exerciseNames,
      onEdit: () => _editWorkout(session),
      onDelete: () {
        Navigator.pop(context);
        _confirmDelete(session);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Workout Track',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          bottom: const TabBar(
            indicatorColor: AppColors.accent,
            labelColor: AppColors.accent,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: [
              Tab(text: 'START WORKOUT', icon: Icon(Icons.play_arrow)),
              Tab(text: 'HISTORY / LOGS', icon: Icon(Icons.history)),
            ],
          ),
        ),
        body: TabBarView(
          children: [_buildStartTab(context), _buildHistoryTab(context)],
        ),
      ),
    );
  }

  Widget _buildStartTab(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => _refreshAll(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Start',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              color: Theme.of(context).colorScheme.surfaceContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: const CircleAvatar(
                  backgroundColor: AppColors.accent,
                  child: Icon(Icons.flash_on, color: Colors.black),
                ),
                title: const Text(
                  'Start an Empty Workout',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: const Text(
                  'Log a freestyle workout without a predefined routine',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                trailing: const Icon(
                  Icons.keyboard_arrow_right,
                  color: AppColors.textSecondary,
                ),
                onTap: _startEmptyWorkout,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Scheduled Sessions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const WorkoutPlanningScreen(),
                      ),
                    );
                    _refreshAll();
                  },
                  child: const Text(
                    'Plan New',
                    style: TextStyle(color: AppColors.accent),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            FutureBuilder<List<WorkoutSession>>(
              future: _scheduledFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final scheduled = snapshot.data ?? [];
                if (scheduled.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 32.0),
                      child: Text(
                        'No sessions scheduled for this week.\nTap "Plan New" to assign routines.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  );
                }

                return Column(
                  children: scheduled.map((session) {
                    final isToday = _isSameDay(session.date, DateTime.now());
                    return Card(
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: isToday
                            ? const BorderSide(color: AppColors.accent)
                            : BorderSide.none,
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: isToday
                              ? AppColors.accent.withAlpha(50)
                              : Colors.white.withAlpha(15),
                          child: Icon(
                            Icons.calendar_today,
                            color: isToday ? AppColors.accent : Colors.grey,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          session.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          '${session.date.weekday == 7 ? 'Sun' : ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][session.date.weekday - 1]} ${session.date.day}/${session.date.month} · ${session.durationMinutes} min',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        trailing: ElevatedButton(
                          onPressed: () => _startScheduledWorkout(session),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            minimumSize: const Size(0, 36),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Start',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Widget _buildHistoryTab(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => _refreshHistory(),
      child: FutureBuilder<List<WorkoutSession>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Could not load workout history.',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            );
          }

          final history = snapshot.data ?? [];
          if (history.isEmpty) {
            return ListView(
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 64.0),
                  child: Center(
                    child: Text(
                      'No workouts logged yet.\nStart an empty workout to begin tracking.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ),
              ],
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final session = history[index];
              return _HistoryCard(
                session: session,
                onTap: () => _showSessionDetail(session),
                onDelete: () => _confirmDelete(session),
              );
            },
          );
        },
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final WorkoutSession session;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _HistoryCard({
    required this.session,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = session.status == WorkoutStatus.completed;

    return Dismissible(
      key: ValueKey(session.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.redAccent),
      ),
      confirmDismiss: (_) async {
        onDelete();
        return false; // deletion is handled (with confirmation) by onDelete
      },
      child: Card(
        color: Theme.of(context).colorScheme.surfaceContainer,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          title: Text(
            session.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${session.date.day}/${session.date.month}/${session.date.year}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                if (isCompleted)
                  Row(
                    children: [
                      const Icon(
                        Icons.bar_chart,
                        size: 14,
                        color: Colors.purpleAccent,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Volume: ${session.totalVolumeLifted.toStringAsFixed(0)} kg',
                        style: const TextStyle(
                          color: Colors.purpleAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.timer,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${session.durationMinutes} mins',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isCompleted
                  ? Colors.green.withValues(alpha: 0.15)
                  : AppColors.advanced.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              session.status.name.toUpperCase(),
              style: TextStyle(
                color: isCompleted ? Colors.greenAccent : AppColors.advanced,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Color _sessionRpeColor(int rpe) {
  if (rpe <= 2) return Colors.greenAccent;
  if (rpe == 3) return Colors.amberAccent;
  return Colors.redAccent;
}

/// Shared bottom-sheet detail view for a workout session.
/// Used by both the History tab and the Home screen's "Last Session" card,
/// so tapping a session always opens the same detailed overview.
void showSessionDetailSheet(
  BuildContext context,
  WorkoutSession session,
  Map<String, String> exerciseNames, {
  VoidCallback? onEdit,
  VoidCallback? onDelete,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      final isCompleted = session.status == WorkoutStatus.completed;
      return Container(
        height: MediaQuery.of(context).size.height * 0.8,
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
                    session.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                if (isCompleted && onEdit != null)
                  IconButton(
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: AppColors.accent,
                    ),
                    tooltip: 'Edit workout',
                    onPressed: onEdit,
                  ),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                    ),
                    onPressed: onDelete,
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${session.date.day}/${session.date.month}/${session.date.year}',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.timer_outlined,
                      size: 18,
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${session.durationMinutes} min',
                      style: const TextStyle(color: AppColors.textPrimary),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.fitness_center,
                      size: 18,
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${session.performedExercises.length} exercises',
                      style: const TextStyle(color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? Colors.green.withAlpha(40)
                        : AppColors.advanced.withAlpha(40),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    session.status.name.toUpperCase(),
                    style: TextStyle(
                      color: isCompleted
                          ? Colors.greenAccent
                          : AppColors.advanced,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.purpleAccent.withAlpha(40),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${session.totalVolumeLifted.toStringAsFixed(0)} KG VOLUME',
                      style: const TextStyle(
                        color: Colors.purpleAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _sessionRpeColor(session.fatigueLevel).withAlpha(40),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'RPE ${session.fatigueLevel}/5',
                    style: TextStyle(
                      color: _sessionRpeColor(session.fatigueLevel),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 32, color: Colors.white10),
            Expanded(
              child: session.performedExercises.isEmpty
                  ? const Center(
                      child: Text(
                        'No exercises logged for this session.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                  : ListView(
                      children: [
                        for (var ex in session.performedExercises)
                          Card(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHigh,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.fitness_center,
                                        size: 16,
                                        color: AppColors.accent,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          exerciseNames[ex.exerciseId] ??
                                              ex.exerciseId,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  for (var s in ex.sets)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 6),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 22,
                                            height: 22,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: AppColors.accent.withAlpha(
                                                30,
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Text(
                                              '${s.setNumber}',
                                              style: const TextStyle(
                                                color: AppColors.accent,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            '${s.weightKg}kg × ${s.reps} reps',
                                            style: const TextStyle(
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          if (!s.isCompleted)
                                            const Text(
                                              '(not completed)',
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 11,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            )
                                          else
                                            const Icon(
                                              Icons.check_circle,
                                              size: 14,
                                              color: Colors.greenAccent,
                                            ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        if (session.notes.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          const Text(
                            'Notes',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            session.notes,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      );
    },
  );
}
