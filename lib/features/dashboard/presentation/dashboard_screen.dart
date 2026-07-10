import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronger/core/theme/app_colors.dart';
import 'package:stronger/features/dashboard/presentation/dashboard_controller.dart';
import 'package:stronger/features/dashboard/presentation/widgets/welcome_header.dart';
import 'package:stronger/features/dashboard/presentation/widgets/today_workout_card.dart';
import 'package:stronger/features/dashboard/presentation/widgets/week_progress_card.dart';
import 'package:stronger/features/dashboard/presentation/widgets/metrics_chart.dart';
import 'package:stronger/features/dashboard/presentation/widgets/last_session_card.dart';
import 'package:stronger/features/dashboard/presentation/widgets/stats_grid.dart';
import 'package:stronger/features/dashboard/presentation/widgets/lifetime_stats_row.dart';

class DashboardScreen extends ConsumerWidget {
  final void Function(int tabIndex)? onNavigateToTab;

  const DashboardScreen({super.key, this.onNavigateToTab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardProvider);
    final username = ref.watch(usernameProvider);

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
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) {
                  final ctrl = TextEditingController(text: username);
                  return AlertDialog(
                    title: const Text('Edit Profile'),
                    content: TextField(
                      controller: ctrl,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(labelText: 'Your Name'),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                        ),
                        onPressed: () {
                          if (ctrl.text.trim().isNotEmpty) {
                            ref
                            .read(usernameProvider.notifier)
                            .updateUsername(ctrl.text.trim());
                          }
                          Navigator.pop(ctx);
                        },
                        child: const Text(
                          'Save',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: dashboardState.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
        error: (err, stack) =>
        Center(child: Text('Error loading Dashboard: $err')),
        data: (data) {
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(dashboardProvider),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WelcomeHeader(
                    username: username,
                    completedThisWeek: data.completedThisWeek,
                  ),

                  const SizedBox(height: 16),
                  const Text(
                    'Today\'s Workout',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 10),
                  TodayWorkoutCard(
                    todaySession: data.todaySession,
                    todayExerciseCount: data.todayExerciseCount,
                  ),

                  const SizedBox(height: 24),
                  WeekProgressCard(data: data),

                  const SizedBox(height: 24),
                  MetricsChart(
                    volumes: data.last4WeeksVolume,
                    workouts: data.last4WeeksWorkouts,
                  ),

                  const SizedBox(height: 24),
                  if (data.lastCompletedSession != null) ...[
                    const Text(
                      'Last Session',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 10),
                    LastSessionCard(session: data.lastCompletedSession!),
                  ],

                  const SizedBox(height: 24),
                  const Text(
                    'Lifetime Stats',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  LifetimeStatsRow(
                    totalWorkouts: data.totalWorkoutsEver,
                    totalVolume: data.totalVolumeEver,
                  ),

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
                  StatsGrid(data: data, onNavigateToTab: onNavigateToTab),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
