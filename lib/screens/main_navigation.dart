import 'package:flutter/material.dart';
import 'package:stronger/theme/app_colors.dart';
import 'package:stronger/screens/home_screen.dart';
import 'package:stronger/screens/workout_screen.dart';
import 'package:stronger/screens/routines_screen.dart';
import 'package:stronger/screens/exercises_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  final _homeKey = GlobalKey<HomeScreenState>();
  final _workoutKey = GlobalKey<WorkoutScreenState>();

  late final List<Widget> _screens = [
    HomeScreen(key: _homeKey),
    WorkoutScreen(key: _workoutKey),
    const RoutinesScreen(),
    const ExercisesScreen(),
  ];

  void _onDestinationSelected(int index) {
    setState(() => _currentIndex = index);
    if (index == 0) {
      _homeKey.currentState?.reloadDashboard();
    } else if (index == 1) {
      _workoutKey.currentState?.refreshAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center),
            label: 'Routines',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'Exercises',
          ),
        ],
      ),
    );
  }
}
