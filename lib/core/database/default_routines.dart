import 'package:stronger/core/models/routine.dart';
import 'package:stronger/core/models/routine_exercise.dart';
import 'package:stronger/core/models/enums.dart';

final List<Routine> defaultRoutinesList = [
  Routine(
    id: 'rt_chest_triceps',
    name: 'A: Chest & Triceps Blast',
    description:
        'A hypertrophy session focused on developing the pectoralis major and triceps pushing strength, ideal for building upper body muscle mass.',
    goal: RoutineGoal.hypertrophy,
    estimatedDurationMinutes: '60',
    exercises: [
      RoutineExercise(
        exerciseId: 'ex_bench_press_barbell',
        name: 'Barbell Bench Press',
        sets: 4,
        reps: 8,
      ),
      RoutineExercise(
        exerciseId: 'ex_incline_dumbbell',
        name: 'Incline Dumbbell Press',
        sets: 3,
        reps: 10,
      ),
      RoutineExercise(
        exerciseId: 'ex_pushups',
        name: 'Push-ups',
        sets: 3,
        reps: 12,
      ),
      RoutineExercise(
        exerciseId: 'ex_tricep_pushdown',
        name: 'Tricep Cable Pushdown',
        sets: 3,
        reps: 12,
      ),
    ],
  ),

  Routine(
    id: 'rt_back_biceps',
    name: 'B: Back & Biceps Pull',
    description:
        'A pulling routine dedicated to back width and thickness, paired with bicep isolation for strong arms and a V-taper back.',
    goal: RoutineGoal.hypertrophy,
    estimatedDurationMinutes: '60',
    exercises: [
      RoutineExercise(
        exerciseId: 'ex_pullups',
        name: 'Pull-ups',
        sets: 4,
        reps: 6,
      ),
      RoutineExercise(
        exerciseId: 'ex_lat_pulldown',
        name: 'Lat Pulldown',
        sets: 3,
        reps: 10,
      ),
      RoutineExercise(
        exerciseId: 'ex_cable_row',
        name: 'Cable Row',
        sets: 3,
        reps: 10,
      ),
      RoutineExercise(
        exerciseId: 'ex_bicep_curl',
        name: 'Dumbbell Bicep Curl',
        sets: 3,
        reps: 12,
      ),
    ],
  ),

  Routine(
    id: 'rt_legs_shoulders',
    name: 'C: Legs & Shoulders Power',
    description:
        'An intense lower body workout centered around the squat, combined with vertical pressing and lateral shoulder isolation.',
    goal: RoutineGoal.hypertrophy,
    estimatedDurationMinutes: '75',
    exercises: [
      RoutineExercise(
        exerciseId: 'ex_squat',
        name: 'Barbell Squat',
        sets: 4,
        reps: 8,
      ),
      RoutineExercise(
        exerciseId: 'ex_leg_press',
        name: 'Machine Leg Press',
        sets: 3,
        reps: 10,
      ),
      RoutineExercise(
        exerciseId: 'ex_overhead_press',
        name: 'Barbell Overhead Press',
        sets: 4,
        reps: 8,
      ),
      RoutineExercise(
        exerciseId: 'ex_lateral_raises',
        name: 'Dumbbell Lateral Raise',
        sets: 3,
        reps: 12,
      ),
    ],
  ),

  Routine(
    id: 'rt_max_strength',
    name: 'Full Body Max Strength',
    description:
        'A full-body routine focused on the three big compound lifts: Squat, Bench Press, and Deadlift. Designed for neural strength and muscle density.',
    goal: RoutineGoal.strength,
    estimatedDurationMinutes: '80',
    exercises: [
      RoutineExercise(
        exerciseId: 'ex_deadlift',
        name: 'Barbell Deadlift',
        sets: 5,
        reps: 5,
      ),
      RoutineExercise(
        exerciseId: 'ex_bench_press_barbell',
        name: 'Barbell Bench Press',
        sets: 5,
        reps: 5,
      ),
      RoutineExercise(
        exerciseId: 'ex_squat',
        name: 'Barbell Squat',
        sets: 5,
        reps: 5,
      ),
    ],
  ),

  Routine(
    id: 'rt_endurance_burner',
    name: 'Cardio, Core & Calisthenics',
    description:
        'A high-rep circuit with short rest periods, structured to improve cardiovascular endurance, muscle conditioning, and core stability.',
    goal: RoutineGoal.endurance,
    estimatedDurationMinutes: '45',
    exercises: [
      RoutineExercise(
        exerciseId: 'ex_pushups',
        name: 'Push-ups',
        sets: 4,
        reps: 15,
      ),
      RoutineExercise(
        exerciseId: 'ex_plank',
        name: 'Abdominal Plank',
        sets: 3,
        reps: 60,
      ), // 60 seconds
      RoutineExercise(
        exerciseId: 'ex_bicep_curl',
        name: 'Dumbbell Bicep Curl',
        sets: 3,
        reps: 15,
      ),
    ],
  ),

  Routine(
    id: 'rt_powerlifting_peak',
    name: 'SBD Competition Peak',
    description:
        'An advanced peaking template focused on the primary lifts (Squat, Bench Press, Deadlift), designed for powerlifters with near-maximal intensity and low reps.',
    goal: RoutineGoal.powerlifting,
    estimatedDurationMinutes: '90',
    exercises: [
      RoutineExercise(
        exerciseId: 'ex_squat',
        name: 'Barbell Squat',
        sets: 3,
        reps: 3,
      ),
      RoutineExercise(
        exerciseId: 'ex_bench_press_barbell',
        name: 'Barbell Bench Press',
        sets: 3,
        reps: 3,
      ),
      RoutineExercise(
        exerciseId: 'ex_deadlift',
        name: 'Barbell Deadlift',
        sets: 3,
        reps: 3,
      ),
    ],
  ),
];
