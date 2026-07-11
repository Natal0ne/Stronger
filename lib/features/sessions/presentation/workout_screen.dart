import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronger/core/theme/app_colors.dart';
import 'package:stronger/core/models/workout_session.dart';
import 'package:stronger/core/models/enums.dart';
import 'package:stronger/features/sessions/presentation/sessions_controller.dart';
import 'package:stronger/features/sessions/presentation/widgets/history_card.dart';
import 'package:stronger/features/sessions/presentation/widgets/session_detail_sheet.dart';
import 'active_workout_screen.dart';
import 'workout_planning_screen.dart';

class WorkoutScreen extends ConsumerWidget {
  const WorkoutScreen({super.key});

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> _startEmptyWorkout(BuildContext context, WidgetRef ref) async {
    final saved = await Navigator.of(context).push<bool>(
      ActiveWorkoutScreen.route(),
    );
    if (saved == true) {
      ref.invalidate(historySessionsProvider);
      ref.invalidate(scheduledSessionsProvider);
    }
  }

  Future<void> _startScheduledWorkout(BuildContext context, WidgetRef ref, WorkoutSession session) async {
    final saved = await Navigator.of(context).push<bool>(
      ActiveWorkoutScreen.route(
      existingSession: session,
      routineId: session.routineId,
      initialTitle: session.title,
      ),
    );
    if (saved == true) {
      ref.invalidate(historySessionsProvider);
      ref.invalidate(scheduledSessionsProvider);
    }
  }

  Future<void> _editWorkout(BuildContext context, WidgetRef ref, WorkoutSession session) async {
    Navigator.pop(context);
    final saved = await Navigator.of(context).push<bool>(
      ActiveWorkoutScreen.route(existingSession: session),
    );
    if (saved == true) {
      ref.invalidate(historySessionsProvider);
      ref.invalidate(scheduledSessionsProvider);
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, WorkoutSession session) async {
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
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      ref.read(historySessionsProvider.notifier).deleteSession(session.id);
    }
  }

  void _showSessionDetail(BuildContext context, WidgetRef ref, WorkoutSession session, Map<String, String> exerciseNames) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SessionDetailSheet(
        session: session,
        exerciseNames: exerciseNames,
        onEdit: () => _editWorkout(context, ref, session),
        onDelete: () {
          Navigator.pop(context);
          _confirmDelete(context, ref, session);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Workout Track',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
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
          children: [_buildStartTab(context, ref), _buildHistoryTab(context, ref)],
        ),
      ),
    );
  }

  Widget _buildStartTab(BuildContext context, WidgetRef ref) {
    final scheduledState = ref.watch(scheduledSessionsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(scheduledSessionsProvider);
        ref.invalidate(historySessionsProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Start',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            Card(
              color: Theme.of(context).colorScheme.surfaceContainer,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: const CircleAvatar(
                  backgroundColor: AppColors.accent,
                  child: Icon(Icons.flash_on, color: Colors.black),
                ),
                title: const Text('Start an Empty Workout', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                subtitle: const Text('Log a freestyle workout without a predefined routine', style: TextStyle(color: AppColors.textSecondary)),
                trailing: const Icon(Icons.keyboard_arrow_right, color: AppColors.textSecondary),
                onTap: () => _startEmptyWorkout(context, ref),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Scheduled Sessions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                ),
                TextButton(
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const WorkoutPlanningScreen()),
                    );
                    ref.invalidate(scheduledSessionsProvider);
                  },
                  child: const Text('Plan New', style: TextStyle(color: AppColors.accent)),
                ),
              ],
            ),
            const SizedBox(height: 8),

            scheduledState.when(
              loading: () => const Center(child: Padding(padding: EdgeInsets.all(32.0), child: CircularProgressIndicator(color: AppColors.accent))),
              error: (err, stack) => Center(child: Text('Error loading schedule: $err')),
              data: (scheduled) {
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
                        side: isToday ? const BorderSide(color: AppColors.accent) : BorderSide.none,
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          backgroundColor: isToday ? AppColors.accent.withAlpha(50) : Colors.white.withAlpha(15),
                          child: Icon(Icons.calendar_today, color: isToday ? AppColors.accent : Colors.grey, size: 20),
                        ),
                        title: Text(session.title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        subtitle: Text(
                          '${session.date.weekday == 7 ? 'Sun' : ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][session.date.weekday - 1]} ${session.date.day}/${session.date.month} · ${session.durationMinutes} min',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                        trailing: ElevatedButton(
                          onPressed: () => _startScheduledWorkout(context, ref, session),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            minimumSize: const Size(0, 36),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Start', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
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

  Widget _buildHistoryTab(BuildContext context, WidgetRef ref) {
    final historyState = ref.watch(historySessionsProvider);
    final exerciseNamesState = ref.watch(exerciseNamesProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(historySessionsProvider);
      },
      child: historyState.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accent)),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (history) {
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

          return exerciseNamesState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
            data: (exerciseNames) {
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final session = history[index];
                  return HistoryCard(
                    session: session,
                    onTap: () => _showSessionDetail(context, ref, session, exerciseNames),
                    onDelete: () => _confirmDelete(context, ref, session),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
