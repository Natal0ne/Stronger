import 'package:stronger/models/routine.dart';
import 'package:stronger/models/routine_exercise.dart';
import 'package:stronger/models/enums.dart';

final List<Routine> defaultRoutinesList = [
  // 1. FULL BODY BEGINNER
  Routine(
    id: 'routine_full_body_beginner',
    name: 'Full Body Foundations',
    description:
        'A perfect starting point focusing on fundamental movements to build base strength.',
    goal: RoutineGoal.strength,
    estimatedDurationMinutes: '45',
    exercises: [
      RoutineExercise(
        exerciseId: 'default_leg_press',
        name: 'Machine Leg Press',
        sets: 3,
        reps: 12,
      ),
      RoutineExercise(
        exerciseId: 'default_pushup',
        name: 'Push-Up',
        sets: 3,
        reps: 15,
      ),
      RoutineExercise(
        exerciseId: 'default_lat_pulldown',
        name: 'Cable Lat Pulldown',
        sets: 3,
        reps: 10,
      ),
      RoutineExercise(
        exerciseId: 'default_shoulder_press',
        name: 'Dumbbell Shoulder Press',
        sets: 3,
        reps: 10,
      ),
      RoutineExercise(
        exerciseId: 'default_plank',
        name: 'Plank',
        sets: 3,
        reps: 60,
      ),
    ],
  ),

  // 2. UPPER BODY POWER
  Routine(
    id: 'routine_upper_body_power',
    name: 'Upper Body Blast',
    description:
        'Target your chest, back, and shoulders with high-impact compound lifts.',
    goal: RoutineGoal.hypertrophy,
    estimatedDurationMinutes: '60',
    exercises: [
      RoutineExercise(
        exerciseId: 'default_bench_press',
        name: 'Barbell Bench Press',
        sets: 4,
        reps: 8,
      ),
      RoutineExercise(
        exerciseId: 'default_barbell_row',
        name: 'Bent-Over Barbell Row',
        sets: 4,
        reps: 8,
      ),
      RoutineExercise(
        exerciseId: 'default_pullup',
        name: 'Pull-Up',
        sets: 3,
        reps: 8,
      ),
      RoutineExercise(
        exerciseId: 'default_incline_press',
        name: 'Incline Dumbbell Press',
        sets: 3,
        reps: 10,
      ),
      RoutineExercise(
        exerciseId: 'default_lateral_raise',
        name: 'Dumbbell Lateral Raise',
        sets: 3,
        reps: 15,
      ),
      RoutineExercise(
        exerciseId: 'default_triceps_pushdown',
        name: 'Cable Triceps Pushdown',
        sets: 3,
        reps: 12,
      ),
    ],
  ),

  // 3. LEGS & CORE
  Routine(
    id: 'routine_legs_core',
    name: 'Legs & Core Strength',
    description:
        'Intense lower body session paired with functional core stability.',
    goal: RoutineGoal.strength,
    estimatedDurationMinutes: '55',
    exercises: [
      RoutineExercise(
        exerciseId: 'default_squat',
        name: 'Barbell Back Squat',
        sets: 4,
        reps: 6,
      ),
      RoutineExercise(
        exerciseId: 'default_romanian_deadlift',
        name: 'Barbell Romanian Deadlift',
        sets: 3,
        reps: 10,
      ),
      RoutineExercise(
        exerciseId: 'default_lunge',
        name: 'Dumbbell Lunge',
        sets: 3,
        reps: 12,
      ),
      RoutineExercise(
        exerciseId: 'default_calf_raise',
        name: 'Standing Calf Raise',
        sets: 4,
        reps: 15,
      ),
      RoutineExercise(
        exerciseId: 'default_leg_raise',
        name: 'Hanging Leg Raise',
        sets: 3,
        reps: 10,
      ),
      RoutineExercise(
        exerciseId: 'default_russian_twist',
        name: 'Russian Twist',
        sets: 3,
        reps: 20,
      ),
    ],
  ),
];
