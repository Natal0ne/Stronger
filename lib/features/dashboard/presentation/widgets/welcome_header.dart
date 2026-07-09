import 'package:flutter/material.dart';
import 'package:stronger/core/theme/app_colors.dart';

class WelcomeHeader extends StatelessWidget {
  final String username;
  final int completedThisWeek;

  const WelcomeHeader({
    super.key,
    required this.username,
    required this.completedThisWeek,
  });

  @override
  Widget build(BuildContext context) {
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
          Text(
            'Hello, $username! 👋',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            completedThisWeek > 0
                ? 'You have completed $completedThisWeek workout${completedThisWeek == 1 ? '' : 's'} this week. Keep it up!'
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
}
