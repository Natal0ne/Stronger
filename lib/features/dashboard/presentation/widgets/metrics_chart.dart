import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronger/core/theme/app_colors.dart';
import 'package:stronger/features/dashboard/presentation/dashboard_controller.dart';

class MetricsChart extends ConsumerWidget {
  final List<double> volumes;
  final List<double> workouts;

  const MetricsChart({
    super.key,
    required this.volumes,
    required this.workouts,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeMetric = ref.watch(activeChartMetricProvider);
    final activeData = activeMetric == ChartMetric.volume ? volumes : workouts;
    final maxVal = activeData.reduce((a, b) => a > b ? a : b);

    // BILANCIAMENTO METRICO PERFETTO ED ESENTE DA OVERFLOW (170px total canvas!)
    const double chartMaxHeight = 95.0;
    const double canvasHeight = 170.0; // <--- RIGIDAMENTE IMPOSTATO A 170PX!

    final weekLabels = ['3 wks ago', '2 wks ago', 'Last week', 'This week'];
    final themeColor = activeMetric == ChartMetric.volume
        ? Colors.purpleAccent
        : Colors.cyanAccent;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Weekly Progress',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              // SLIDER COMPATTO
              Container(
                width: 160,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    AnimatedAlign(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      alignment: activeMetric == ChartMetric.volume
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      child: FractionallySizedBox(
                        widthFactor: 0.5,
                        heightFactor: 1.0,
                        child: Container(
                          margin: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: activeMetric == ChartMetric.volume
                                ? Colors.purpleAccent
                                : Colors.cyanAccent,
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                ref
                                    .read(activeChartMetricProvider.notifier)
                                    .state = ChartMetric
                                    .volume,
                            behavior: HitTestBehavior.translucent,
                            child: Center(
                              child: Text(
                                'Volume',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: activeMetric == ChartMetric.volume
                                      ? Colors.black
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                ref
                                    .read(activeChartMetricProvider.notifier)
                                    .state = ChartMetric
                                    .workouts,
                            behavior: HitTestBehavior.translucent,
                            child: Center(
                              child: Text(
                                'Workouts',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: activeMetric == ChartMetric.workouts
                                      ? Colors.black
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: canvasHeight,
            child: Stack(
              children: [
                // Grid lines posizionate a top: 25
                Positioned(
                  top: 25,
                  left: 0,
                  right: 0,
                  height: chartMaxHeight,
                  child: Column(
                    children: [
                      for (var i = 0; i < 3; i++) ...[
                        SizedBox(
                          height: chartMaxHeight / 3,
                          child: const Divider(
                            height: 1,
                            color: Colors.white10,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        for (var i = 0; i < 4; i++) ...[
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                activeMetric == ChartMetric.volume
                                    ? (activeData[i] >= 1000
                                          ? '${(activeData[i] / 1000).toStringAsFixed(1)}t'
                                          : '${activeData[i].toStringAsFixed(0)}')
                                    : '${activeData[i].round()}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeOutQuart,
                                width: 24,
                                height: maxVal > 0
                                    ? (activeData[i] / maxVal) * chartMaxHeight
                                    : 0,
                                decoration: BoxDecoration(
                                  gradient: activeMetric == ChartMetric.volume
                                      ? const LinearGradient(
                                          colors: [
                                            Color(0xFFE0C3FC),
                                            Colors.purpleAccent,
                                          ],
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                        )
                                      : const LinearGradient(
                                          colors: [
                                            Color(0xFF00F2FE),
                                            Colors.cyanAccent,
                                          ],
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                        ),
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(6),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                weekLabels[i],
                                style: TextStyle(
                                  fontSize: 10,
                                  color: i == 3
                                      ? themeColor
                                      : AppColors.textSecondary,
                                  fontWeight: i == 3
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
