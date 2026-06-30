import 'package:flutter/material.dart';
import 'package:stronger/theme/app_colors.dart';

class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> mockHistory = [
      {
        'id': 'sess_1',
        'title': 'Leg Day - Hypertrophy',
        'date': 'Yesterday, 18:30',
        'durationMinutes': 65,
        'status': 'Completed',
        'fatigueLevel': 4,
        'totalVolume': '8,450 kg',
      },
      {
        'id': 'sess_2',
        'title': 'Push Day - Heavy Chest',
        'date': 'Oct 24, 2023',
        'durationMinutes': 50,
        'status': 'Completed',
        'fatigueLevel': 3,
        'totalVolume': '6,120 kg',
      },
      {
        'id': 'sess_3',
        'title': 'Cardio & Core',
        'date': 'Oct 21, 2023',
        'durationMinutes': 40,
        'status': 'Skipped',
        'fatigueLevel': 0,
        'totalVolume': '0 kg',
      },
    ];

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
          children: [
            Padding(
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
                      onTap: () {},
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
                        onPressed: () {},
                        child: const Text(
                          'Plan New',
                          style: TextStyle(color: AppColors.accent),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 32.0),
                      child: Text(
                        'No other sessions scheduled for this week.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: mockHistory.length,
              itemBuilder: (context, index) {
                final log = mockHistory[index];
                final isCompleted = log['status'] == 'Completed';

                return Card(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    title: Text(
                      log['title'],
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
                            log['date'],
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
                                  'Volume: ${log['totalVolume']}',
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
                                  '${log['durationMinutes']} mins',
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? Colors.green.withValues(alpha: 0.15)
                            : AppColors.advanced.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        log['status'].toUpperCase(),
                        style: TextStyle(
                          color: isCompleted
                              ? Colors.greenAccent
                              : AppColors.advanced,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
