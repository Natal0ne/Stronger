import 'package:flutter/material.dart';
import 'package:stronger/core/theme/app_colors.dart';

class RestTimerCard extends StatelessWidget {
  final int secondsRemaining;
  final double progressValue;
  final VoidCallback onAdd10s;
  final VoidCallback onSkip;
  final VoidCallback onEditDefaultRest;

  const RestTimerCard({
    super.key,
    required this.secondsRemaining,
    required this.progressValue,
    required this.onAdd10s,
    required this.onSkip,
    required this.onEditDefaultRest,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Positioned.fill(
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: progressValue,
                  heightFactor: 1.0,
                  child: Container(
                    color: Colors.green.withOpacity(0.35),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
              child: Row(
                children: [
                  const Icon(Icons.hourglass_top, color: AppColors.accent, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: onEditDefaultRest,
                      behavior: HitTestBehavior.translucent,
                      child: Row(
                        children: [
                          Text(
                            'Rest: ${secondsRemaining}s',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 14),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.edit_outlined, size: 14, color: AppColors.accent),
                        ],
                      ),
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      minimumSize: Size.zero,
                    ),
                    onPressed: onAdd10s,
                    child: const Text(
                      '+10s',
                      style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: onSkip,
                    child: const Text(
                      'Skip',
                      style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
