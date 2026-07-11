import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stronger/core/theme/app_colors.dart';

class FatigueSelector extends StatelessWidget {
  final int fatigueLevel;
  final ValueChanged<double> onChanged;

  const FatigueSelector({
    super.key,
    required this.fatigueLevel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.bolt, color: AppColors.accent, size: 18),
            SizedBox(width: 8),
            Text(
              'Perceived Fatigue (RPE)',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.accent,
                    thumbColor: AppColors.accent,
                    inactiveTrackColor: Colors.grey.withAlpha(60),
                    overlayColor: AppColors.accent.withAlpha(40),
                  ),
                  child: Slider(
                    value: fatigueLevel.toDouble(),
                    min: 1,
                    max: 5,
                    divisions: 4,
                    label: '$fatigueLevel',
                    onChanged: (v) {

                      if (v.round() != fatigueLevel) {
                        HapticFeedback.selectionClick();
                      }
                      onChanged(v);
                    },
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent.withAlpha(40),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$fatigueLevel/5',
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
