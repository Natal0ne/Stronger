import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:stronger/core/theme/app_colors.dart';
import 'package:stronger/features/dashboard/presentation/dashboard_controller.dart';

class StatsGrid extends StatelessWidget {
  final DashboardData data;
  final void Function(int tabIndex)? onNavigateToTab;

  const StatsGrid({super.key, required this.data, this.onNavigateToTab});

  @override
  Widget build(BuildContext context) {
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
                  value: '${data.completedThisWeek}',
                  icon: Icons.check_circle_outline,
                  iconColor: AppColors.accent,
                  onTap: () => onNavigateToTab?.call(1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  context,
                  label: 'Planned',
                  subtitle: 'This week',
                  value: '${data.scheduledThisWeek}',
                  icon: Icons.event_available,
                  iconColor: Colors.blueAccent,
                  onTap: () => onNavigateToTab?.call(1),
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
                  value: '${data.routineCount}',
                  icon: Icons.list_alt,
                  iconColor: AppColors.advanced,
                  onTap: () => onNavigateToTab?.call(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  context,
                  label: 'Exercises',
                  subtitle: 'Saved',
                  value: '${data.exerciseCount}',
                  icon: Icons.fitness_center,
                  iconColor: Colors.purpleAccent,
                  onTap: () => onNavigateToTab?.call(3),
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
