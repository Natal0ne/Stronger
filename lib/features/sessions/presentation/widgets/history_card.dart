import 'package:flutter/material.dart';
import 'package:stronger/core/models/workout_session.dart';
import 'package:stronger/core/models/enums.dart';
import 'package:stronger/core/theme/app_colors.dart';

class HistoryCard extends StatelessWidget {
  final WorkoutSession session;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const HistoryCard({
    super.key,
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
        return false;
      },
      child: Card(
        color: Theme.of(context).colorScheme.surfaceContainer,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Text(
            session.title,
            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${session.date.day}/${session.date.month}/${session.date.year}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 6),
                if (isCompleted)
                  Row(
                    children: [
                      const Icon(Icons.bar_chart, size: 14, color: Colors.purpleAccent),
                      const SizedBox(width: 4),
                      Text(
                        'Volume: ${session.totalVolumeLifted.toStringAsFixed(0)} kg',
                        style: const TextStyle(color: Colors.purpleAccent, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.timer, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        '${session.durationMinutes} mins',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
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
