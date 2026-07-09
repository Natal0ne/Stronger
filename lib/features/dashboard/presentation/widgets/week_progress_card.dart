import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:stronger/core/theme/app_colors.dart';
import 'package:stronger/features/dashboard/presentation/dashboard_controller.dart';

class WeekProgressCard extends StatelessWidget {
  final DashboardData data;

  const WeekProgressCard({super.key, required this.data});

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

  @override
  Widget build(BuildContext context) {
    final displayScheduled =
        data.scheduledThisWeek == 0 && data.completedThisWeek > 0
        ? data.completedThisWeek
        : data.scheduledThisWeek;

    final total = displayScheduled > 0 ? displayScheduled : 1;
    final progress = (data.completedThisWeek / total).clamp(0.0, 1.0);

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
                '${data.completedThisWeek} / $displayScheduled',
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
                icon: Symbols.trending_up,
                label: 'Volume',
                value: data.weeklyVolume >= 1000
                    ? '${(data.weeklyVolume / 1000).toStringAsFixed(1)}t'
                    : '${data.weeklyVolume.toStringAsFixed(0)} kg',
              ),
              const SizedBox(width: 16),
              _buildMiniStat(
                icon: Icons.event_available,
                label: 'Planned',
                value: '${data.scheduledThisWeek}',
              ),
              const SizedBox(width: 16),
              _buildMiniStat(
                icon: Icons.check_circle_outline,
                label: 'Done',
                value: '${data.completedThisWeek}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
