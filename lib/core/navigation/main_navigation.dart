import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronger/core/theme/app_colors.dart';

import 'package:stronger/features/sessions/presentation/sessions_controller.dart';
import 'package:stronger/features/sessions/presentation/active_workout_screen.dart';

import 'package:stronger/features/routines/presentation/routines_screen.dart';
import 'package:stronger/features/sessions/presentation/workout_screen.dart';
import 'package:stronger/features/exercises/presentation/exercises_screen.dart';
import 'package:stronger/features/dashboard/presentation/dashboard_screen.dart';
import 'package:stronger/features/goals/presentation/goals_screen.dart';

import 'package:stronger/features/sessions/presentation/widgets/mini_workout_bar.dart';

class MainNavigation extends ConsumerStatefulWidget {
  const MainNavigation({super.key});

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _panelAnimationController;

  late final List<Widget> _screens = [
    DashboardScreen(onNavigateToTab: _onDestinationSelected),
    const WorkoutScreen(),
    const RoutinesScreen(),
    const ExercisesScreen(),
    const GoalsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _panelAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _panelAnimationController.dispose();
    super.dispose();
  }

  void _onDestinationSelected(int index) {
    HapticFeedback.lightImpact();
    setState(() => _currentIndex = index);
  }

  void _handleDragUpdate(
    DragUpdateDetails details,
    double collapsedTop,
    double screenHeight,
  ) {
    final double dragRange = collapsedTop;
    if (dragRange <= 0) return;

    _panelAnimationController.value -= details.primaryDelta! / dragRange;
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_panelAnimationController.value > 0.45) {
      ref.read(workoutPanelExpandedProvider.notifier).state = true;
      _panelAnimationController.forward();
    } else {
      ref.read(workoutPanelExpandedProvider.notifier).state = false;
      _panelAnimationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeWorkout = ref.watch(activeWorkoutProvider);
    final isExpanded = ref.watch(workoutPanelExpandedProvider);

    ref.listen<bool>(workoutPanelExpandedProvider, (previous, next) {
      if (next) {
        _panelAnimationController.forward();
      } else {
        _panelAnimationController.reverse();
      }
    });

    final screenHeight = MediaQuery.of(context).size.height;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    final double navBarHeight = 80.0 + bottomPadding;
    final double collapsedHeight = 60.0;

    final double collapsedTop = screenHeight - navBarHeight - collapsedHeight;
    const double expandedTop = 0.0;

    return Stack(
      children: [
        Scaffold(
          body: IndexedStack(index: _currentIndex, children: _screens),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: _onDestinationSelected,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
            indicatorColor: AppColors.accent,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.play_circle_outline),
                selectedIcon: Icon(Icons.play_circle_filled),
                label: 'Workout',
              ),
              NavigationDestination(
                icon: Icon(Icons.list_alt_rounded),
                selectedIcon: Icon(Icons.list_alt),
                label: 'Routines',
              ),
              NavigationDestination(
                icon: Icon(Icons.fitness_center_outlined),
                selectedIcon: Icon(Icons.fitness_center),
                label: 'Exercises',
              ),
              NavigationDestination(
                icon: Icon(Icons.emoji_events_outlined),
                selectedIcon: Icon(Icons.emoji_events),
                label: 'Goals',
              ),
            ],
          ),
        ),

        if (activeWorkout != null)
          AnimatedBuilder(
            animation: _panelAnimationController,
            builder: (context, child) {
              final double value = _panelAnimationController.value;

              final double currentTop = lerpDouble(
                collapsedTop,
                expandedTop,
                value,
              )!;
              final double currentHeight = lerpDouble(
                collapsedHeight,
                screenHeight,
                value,
              )!;

              return Positioned(
                top: currentTop,
                left: 0,
                right: 0,
                height: currentHeight,
                child: GestureDetector(
                  onVerticalDragUpdate: (details) =>
                      _handleDragUpdate(details, collapsedTop, screenHeight),
                  onVerticalDragEnd: _handleDragEnd,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      boxShadow: [
                        if (value < 0.95)
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, -3),
                          ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        if (value < 0.9)
                          Opacity(
                            opacity: (1.0 - (value * 1.2)).clamp(0.0, 1.0),
                            child: const IgnorePointer(
                              ignoring: false,
                              child: MiniWorkoutBar(),
                            ),
                          ),

                        if (value > 0.1)
                          Opacity(
                            opacity: ((value - 0.1) * 1.2).clamp(0.0, 1.0),
                            child: IgnorePointer(
                              ignoring: value < 0.85,
                              child: const ActiveWorkoutScreen(),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
