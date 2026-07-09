import 'package:stronger/core/models/exercise.dart';
import 'package:stronger/core/models/enums.dart';

final List<Exercise> defaultExercisesList = [

  Exercise(
    id: 'ex_bench_press_barbell',
    name: 'Barbell Bench Press',
    description:
        'Lie flat on a bench, grip the barbell slightly wider than shoulder-width. Lower the barbell slowly until it touches your chest, then push up with force.',
    primaryMuscleGroup: MuscleGroup.chest,
    difficulty: Difficulty.intermediate,
    equipment: Equipment.barbell,
    recommendedReps: 8,
    defaultRestSeconds: 120,
    notes: 'Keep your feet flat on the floor and contract your glutes.',
  ),
  Exercise(
    id: 'ex_bench_press_dumbbell',
    name: 'Dumbbell Bench Press',
    description:
        'Lie flat on a bench holding two dumbbells at chest level. Press the dumbbells straight up over your chest, bringing them close together at the top without touching.',
    primaryMuscleGroup: MuscleGroup.chest,
    difficulty: Difficulty.intermediate,
    equipment: Equipment.dumbbell,
    recommendedReps: 10,
    defaultRestSeconds: 90,
  ),
  Exercise(
    id: 'ex_chest_press_machine',
    name: 'Machine Chest Press',
    description:
        'Sit at the Chest Press machine. Adjust the seat height so the handles align with your mid-chest. Push forward, extending your arms in a guided path.',
    primaryMuscleGroup: MuscleGroup.chest,
    difficulty: Difficulty.beginner,
    equipment: Equipment.machine,
    recommendedReps: 10,
    defaultRestSeconds: 90,
  ),

  Exercise(
    id: 'ex_incline_bench_press_barbell',
    name: 'Incline Barbell Bench Press',
    description:
        'Lie on an inclined bench (30-45 degrees). Lower the barbell in a controlled movement to your upper chest, then press it back up to the starting position.',
    primaryMuscleGroup: MuscleGroup.chest,
    difficulty: Difficulty.intermediate,
    equipment: Equipment.barbell,
    recommendedReps: 8,
    defaultRestSeconds: 120,
  ),
  Exercise(
    id: 'ex_incline_dumbbell',
    name: 'Incline Dumbbell Press',
    description:
        'Sit on a bench inclined at 30-45 degrees. Push the dumbbells upward starting from chest height, fully extending your arms without locking your elbows.',
    primaryMuscleGroup: MuscleGroup.chest,
    difficulty: Difficulty.intermediate,
    equipment: Equipment.dumbbell,
    recommendedReps: 10,
    defaultRestSeconds: 90,
    notes: 'Excellent for targeting the upper portion of the pectoralis major.',
  ),
  Exercise(
    id: 'ex_incline_chest_press_machine',
    name: 'Machine Incline Chest Press',
    description:
        'Sit at the incline chest press machine. Push the handles up and away in a guided path to isolate the upper chest fibers.',
    primaryMuscleGroup: MuscleGroup.chest,
    difficulty: Difficulty.beginner,
    equipment: Equipment.machine,
    recommendedReps: 10,
    defaultRestSeconds: 90,
  ),

  Exercise(
    id: 'ex_decline_bench_press',
    name: 'Decline Barbell Bench Press',
    description:
        'Lie on a decline bench. Lower the barbell in a controlled manner to the lower chest, then push up with force.',
    primaryMuscleGroup: MuscleGroup.chest,
    difficulty: Difficulty.advanced,
    equipment: Equipment.barbell,
    recommendedReps: 8,
    defaultRestSeconds: 120,
    notes: 'Great for isolating the lower/abdominal portion of the chest.',
  ),
  Exercise(
    id: 'ex_decline_dumbbell_press',
    name: 'Decline Dumbbell Press',
    description:
        'Lie on a decline bench with a dumbbell in each hand. Press the weights straight up over your lower chest, maintaining control throughout.',
    primaryMuscleGroup: MuscleGroup.chest,
    difficulty: Difficulty.intermediate,
    equipment: Equipment.dumbbell,
    recommendedReps: 10,
    defaultRestSeconds: 90,
  ),
  Exercise(
    id: 'ex_decline_chest_press_machine',
    name: 'Machine Decline Chest Press',
    description:
        'Sit at the decline chest press machine and push the handles forward and downward in a guided trajectory.',
    primaryMuscleGroup: MuscleGroup.chest,
    difficulty: Difficulty.beginner,
    equipment: Equipment.machine,
    recommendedReps: 10,
    defaultRestSeconds: 90,
  ),

  Exercise(
    id: 'ex_dumbbell_fly',
    name: 'Dumbbell Chest Fly',
    description:
        'Lie flat on a bench with dumbbells. Open your arms outward in a wide arc until you feel a stretch in your chest, then close them back to the starting position.',
    primaryMuscleGroup: MuscleGroup.chest,
    difficulty: Difficulty.beginner,
    equipment: Equipment.dumbbell,
    recommendedReps: 12,
    defaultRestSeconds: 60,
  ),
  Exercise(
    id: 'ex_pec_deck',
    name: 'Pec Deck Fly',
    description:
        'Sit at the Pec Deck machine, rest your elbows or grab the handles. Bring your arms together, squeezing your chest at the peak contraction.',
    primaryMuscleGroup: MuscleGroup.chest,
    difficulty: Difficulty.beginner,
    equipment: Equipment.machine,
    recommendedReps: 12,
    defaultRestSeconds: 60,
  ),
  Exercise(
    id: 'ex_incline_dumbbell_fly',
    name: 'Incline Dumbbell Fly',
    description:
        'Lie on an incline bench with dumbbells. Lower your arms out in an arc until you feel a deep stretch in your upper chest, then squeeze them back together.',
    primaryMuscleGroup: MuscleGroup.chest,
    difficulty: Difficulty.intermediate,
    equipment: Equipment.dumbbell,
    recommendedReps: 12,
    defaultRestSeconds: 75,
  ),
  Exercise(
    id: 'ex_cable_crossover',
    name: 'Cable Crossover',
    description:
        'Stand in the middle of a high cable crossover station. Grab the handles and bring your arms forward and down, crossing them slightly while strongly contracting your chest.',
    primaryMuscleGroup: MuscleGroup.chest,
    difficulty: Difficulty.intermediate,
    equipment: Equipment.cable,
    recommendedReps: 12,
    defaultRestSeconds: 60,
  ),
  Exercise(
    id: 'ex_low_to_high_cable_fly',
    name: 'Low-to-High Cable Fly',
    description:
        'Set the cables at the bottom position. Grab the handles and bring your hands up and together in front of your upper chest, focusing on the upper pectoral fibers.',
    primaryMuscleGroup: MuscleGroup.chest,
    difficulty: Difficulty.intermediate,
    equipment: Equipment.cable,
    recommendedReps: 12,
    defaultRestSeconds: 60,
  ),

  Exercise(
    id: 'ex_pushups',
    name: 'Push-ups',
    description:
        'Classic floor push-ups. Keep your body straight like a plank (core engaged) and lower yourself until your chest almost touches the floor.',
    primaryMuscleGroup: MuscleGroup.chest,
    difficulty: Difficulty.beginner,
    equipment: Equipment.bodyweight,
    recommendedReps: 15,
    defaultRestSeconds: 60,
  ),
  Exercise(
    id: 'ex_weighted_dips_chest',
    name: 'Chest Dips',
    description:
        'On parallel bars, lean your torso slightly forward and flare your elbows outward. Lower your body until your shoulders are below your elbows, then press up.',
    primaryMuscleGroup: MuscleGroup.chest,
    difficulty: Difficulty.advanced,
    equipment: Equipment.bodyweight,
    recommendedReps: 8,
    defaultRestSeconds: 90,
  ),

  Exercise(
    id: 'ex_pullups',
    name: 'Pull-ups',
    description:
        'Grab the bar with a prone grip (palms facing away) wider than shoulder-width. Pull yourself up by squeezing your shoulder blades until your chin clears the bar.',
    primaryMuscleGroup: MuscleGroup.back,
    difficulty: Difficulty.advanced,
    equipment: Equipment.bodyweight,
    recommendedReps: 6,
    defaultRestSeconds: 120,
  ),
  Exercise(
    id: 'ex_chinups',
    name: 'Chin-ups',
    description:
        'Pull-ups with a supinated grip (palms facing you) at shoulder-width. Pull yourself up, focusing on contracting your biceps and latissimus dorsi.',
    primaryMuscleGroup: MuscleGroup.back,
    difficulty: Difficulty.intermediate,
    equipment: Equipment.bodyweight,
    recommendedReps: 8,
    defaultRestSeconds: 90,
  ),
  Exercise(
    id: 'ex_lat_pulldown',
    name: 'Lat Pulldown',
    description:
        'Sit at the Lat Machine, grab the bar with a wide grip and pull it down to the upper chest, contracting your lats.',
    primaryMuscleGroup: MuscleGroup.back,
    difficulty: Difficulty.beginner,
    equipment: Equipment.machine,
    recommendedReps: 10,
    defaultRestSeconds: 90,
  ),

  Exercise(
    id: 'ex_barbell_row',
    name: 'Barbell Bent-Over Row',
    description:
        'Stand and bend your torso forward at a 45-degree angle with a straight back. Pull the barbell toward your lower abdomen, skimming your thighs.',
    primaryMuscleGroup: MuscleGroup.back,
    difficulty: Difficulty.intermediate,
    equipment: Equipment.barbell,
    recommendedReps: 8,
    defaultRestSeconds: 120,
  ),
  Exercise(
    id: 'ex_bent_over_dumbbell_row',
    name: 'Bent-Over Dumbbell Row',
    description:
        'Bend your torso forward with flat back holding two dumbbells. Pull both dumbbells to your sides, bringing your elbows high.',
    primaryMuscleGroup: MuscleGroup.back,
    difficulty: Difficulty.intermediate,
    equipment: Equipment.dumbbell,
    recommendedReps: 10,
    defaultRestSeconds: 90,
  ),
  Exercise(
    id: 'ex_dumbbell_row',
    name: 'One-Arm Dumbbell Row',
    description:
        'Place one knee and hand on a flat bench. Grip a dumbbell with the opposite hand and pull it toward your hip, keeping your elbow close to your side.',
    primaryMuscleGroup: MuscleGroup.back,
    difficulty: Difficulty.beginner,
    equipment: Equipment.dumbbell,
    recommendedReps: 10,
    defaultRestSeconds: 90,
  ),
  Exercise(
    id: 'ex_cable_row',
    name: 'Cable Row',
    description:
        'Seated at a low pulley with a straight back. Pull the handle toward your abdomen, bringing your elbows back and squeezing your shoulder blades together.',
    primaryMuscleGroup: MuscleGroup.back,
    difficulty: Difficulty.beginner,
    equipment: Equipment.cable,
    recommendedReps: 10,
    defaultRestSeconds: 90,
  ),
  Exercise(
    id: 'ex_seated_machine_row',
    name: 'Machine Seated Row',
    description:
        'Sit at the rowing machine, place your chest against the pad, and pull the handles toward your torso using your upper back muscles.',
    primaryMuscleGroup: MuscleGroup.back,
    difficulty: Difficulty.beginner,
    equipment: Equipment.machine,
    recommendedReps: 10,
    defaultRestSeconds: 90,
  ),

  Exercise(
    id: 'ex_chest_supported_db_row',
    name: 'Chest-Supported Dumbbell Row',
    description:
        'Lie chest-down on an incline bench. Let your arms hang straight down, then pull the dumbbells upward by pulling your elbows toward your hips.',
    primaryMuscleGroup: MuscleGroup.back,
    difficulty: Difficulty.beginner,
    equipment: Equipment.dumbbell,
    recommendedReps: 10,
    defaultRestSeconds: 90,
  ),
  Exercise(
    id: 'ex_t_bar_row',
    name: 'Machine T-Bar Row',
    description:
        'Step onto the platform, bend your torso, grip the handles, and pull the weight toward your chest while resting against the padded support.',
    primaryMuscleGroup: MuscleGroup.back,
    difficulty: Difficulty.intermediate,
    equipment: Equipment.machine,
    recommendedReps: 10,
    defaultRestSeconds: 90,
  ),
  Exercise(
    id: 'ex_barbell_t_bar_row',
    name: 'Barbell T-Bar Row (Landmine)',
    description:
        'Straddle a barbell anchored at one end. Grip a V-handle placed under the collar of the bar and pull the weight up towards your torso.',
    primaryMuscleGroup: MuscleGroup.back,
    difficulty: Difficulty.intermediate,
    equipment: Equipment.barbell,
    recommendedReps: 8,
    defaultRestSeconds: 100,
  ),

  Exercise(
    id: 'ex_deadlift',
    name: 'Barbell Deadlift',
    description:
        'Position the barbell at mid-shin height. Grip the bar, keep your back flat and tight, and lift the weight by pushing through your legs and extending your hips.',
    primaryMuscleGroup: MuscleGroup.back,
    difficulty: Difficulty.advanced,
    equipment: Equipment.barbell,
    recommendedReps: 5,
    defaultRestSeconds: 180,
  ),
  Exercise(
    id: 'ex_dumbbell_deadlift',
    name: 'Dumbbell Deadlift',
    description:
        'Stand with feet hip-width apart holding dumbbells. Keep your back flat as you lower the weights along your shins by hinging at the hips, then stand up.',
    primaryMuscleGroup: MuscleGroup.back,
    difficulty: Difficulty.intermediate,
    equipment: Equipment.dumbbell,
    recommendedReps: 10,
    defaultRestSeconds: 90,
  ),

  Exercise(
    id: 'ex_lat_pullover_db',
    name: 'Dumbbell Pull-over',
    description:
        'Lie flat across a bench with your upper back supported. Hold a single dumbbell overhead and lower it backward behind your head, then pull it back over your chest.',
    primaryMuscleGroup: MuscleGroup.back,
    difficulty: Difficulty.intermediate,
    equipment: Equipment.dumbbell,
    recommendedReps: 10,
    defaultRestSeconds: 90,
  ),
  Exercise(
    id: 'ex_barbell_pullover',
    name: 'Barbell Pull-over',
    description:
        'Lie flat on a bench, hold an EZ bar or straight bar over your chest. Lower the bar backward over your head in a controlled arc and pull it back using your lats.',
    primaryMuscleGroup: MuscleGroup.back,
    difficulty: Difficulty.intermediate,
    equipment: Equipment.barbell,
    recommendedReps: 10,
    defaultRestSeconds: 90,
  ),
  Exercise(
    id: 'ex_straight_arm_pulldown',
    name: 'Straight-Arm Cable Pulldown',
    description:
        'Stand facing the cable machine, grasp the bar with arms extended. Keeping your arms straight, pull the bar down to your thighs, squeezing your lats.',
    primaryMuscleGroup: MuscleGroup.back,
    difficulty: Difficulty.beginner,
    equipment: Equipment.cable,
    recommendedReps: 12,
    defaultRestSeconds: 60,
  ),

  Exercise(
    id: 'ex_barbell_shrugs',
    name: 'Barbell Shrugs',
    description:
        'Hold a barbell in front of your thighs. Raise your shoulders as high as possible, hold for a moment, and lower under control.',
    primaryMuscleGroup: MuscleGroup.back,
    difficulty: Difficulty.beginner,
    equipment: Equipment.barbell,
    recommendedReps: 12,
    defaultRestSeconds: 75,
  ),
  Exercise(
    id: 'ex_shrugs',
    name: 'Dumbbell Shrugs',
    description:
        'Stand with dumbbells at your sides. Lift your shoulders toward your ears, contracting your traps hard at the top.',
    primaryMuscleGroup: MuscleGroup.back,
    difficulty: Difficulty.beginner,
    equipment: Equipment.dumbbell,
    recommendedReps: 15,
    defaultRestSeconds: 60,
  ),
  Exercise(
    id: 'ex_machine_shrugs',
    name: 'Machine/Smith Shrugs',
    description:
        'Hold the handles of a shrug machine or a Smith machine bar. Lift your shoulders vertically toward your ears to target the upper traps.',
    primaryMuscleGroup: MuscleGroup.back,
    difficulty: Difficulty.beginner,
    equipment: Equipment.machine,
    recommendedReps: 12,
    defaultRestSeconds: 60,
  ),

  Exercise(
    id: 'ex_squat',
    name: 'Barbell Squat',
    description:
        'Position the barbell on your upper back. Descend by pushing your hips back as if sitting down, going below parallel, then rise back up.',
    primaryMuscleGroup: MuscleGroup.legs,
    difficulty: Difficulty.intermediate,
    equipment: Equipment.barbell,
    recommendedReps: 8,
    defaultRestSeconds: 150,
  ),
  Exercise(
    id: 'ex_dumbbell_squat',
    name: 'Dumbbell Squat',
    description:
        'Hold a dumbbell in each hand at your sides or on top of your shoulders. Lower into a squat, keeping your chest up and knees aligned over your toes.',
    primaryMuscleGroup: MuscleGroup.legs,
    difficulty: Difficulty.beginner,
    equipment: Equipment.dumbbell,
    recommendedReps: 10,
    defaultRestSeconds: 90,
  ),
  Exercise(
    id: 'ex_goblet_squat',
    name: 'Dumbbell Goblet Squat',
    description:
        'Hold a single dumbbell vertically in front of your chest. Keep your torso upright as you squat deep, pushing your knees outward.',
    primaryMuscleGroup: MuscleGroup.legs,
    difficulty: Difficulty.beginner,
    equipment: Equipment.dumbbell,
    recommendedReps: 12,
    defaultRestSeconds: 75,
  ),
  Exercise(
    id: 'ex_hack_squat_machine',
    name: 'Machine Hack Squat',
    description:
        'Position your back and shoulders against the machine pads. Step onto the platform, release the safety handles, and lower your hips to perform a squat.',
    primaryMuscleGroup: MuscleGroup.legs,
    difficulty: Difficulty.intermediate,
    equipment: Equipment.machine,
    recommendedReps: 10,
    defaultRestSeconds: 120,
  ),

  Exercise(
    id: 'ex_front_squat',
    name: 'Barbell Front Squat',
    description:
        'Position the barbell on your front shoulders/clavicles, crossing your arms or using a clean grip. Squat down while keeping your torso upright.',
    primaryMuscleGroup: MuscleGroup.legs,
    difficulty: Difficulty.advanced,
    equipment: Equipment.barbell,
    recommendedReps: 6,
    defaultRestSeconds: 120,
  ),
  Exercise(
    id: 'ex_dumbbell_front_squat',
    name: 'Dumbbell Front Squat',
    description:
        'Hold two dumbbells resting on the front of your shoulders. Perform a squat while maintaining a vertical torso.',
    primaryMuscleGroup: MuscleGroup.legs,
    difficulty: Difficulty.intermediate,
    equipment: Equipment.dumbbell,
    recommendedReps: 10,
    defaultRestSeconds: 90,
  ),

  Exercise(
    id: 'ex_leg_press',
    name: 'Machine Leg Press',
    description:
        'Sit at a 45-degree leg press machine, placing feet shoulder-width apart on the platform. Release the safety, bend knees to 90 degrees, and push the platform back up.',
    primaryMuscleGroup: MuscleGroup.legs,
    difficulty: Difficulty.beginner,
    equipment: Equipment.machine,
    recommendedReps: 10,
    defaultRestSeconds: 90,
  ),

  Exercise(
    id: 'ex_barbell_romanian_deadlift',
    name: 'Barbell Romanian Deadlift',
    description:
        'Hold a barbell with an overhand grip. Push your hips back, keeping your back flat, and lower the bar along your legs until you feel a deep stretch in your hamstrings.',
    primaryMuscleGroup: MuscleGroup.legs,
    difficulty: Difficulty.intermediate,
    equipment: Equipment.barbell,
    recommendedReps: 8,
    defaultRestSeconds: 90,
  ),
  Exercise(
    id: 'ex_romanian_deadlift',
    name: 'Dumbbell Romanian Deadlift',
    description:
        'Stand with two dumbbells. Push your hips back while keeping your back straight and knees slightly bent, lowering the weights to mid-shin height.',
    primaryMuscleGroup: MuscleGroup.legs,
    difficulty: Difficulty.intermediate,
    equipment: Equipment.dumbbell,
    recommendedReps: 10,
    defaultRestSeconds: 90,
  ),
  Exercise(
    id: 'ex_smith_machine_romanian_deadlift',
    name: 'Machine Romanian Deadlift (Smith Machine)',
    description:
        'Stand in front of a Smith machine bar. Perform a Romanian deadlift following the guided vertical track to emphasize hamstrings and glutes.',
    primaryMuscleGroup: MuscleGroup.legs,
    difficulty: Difficulty.intermediate,
    equipment: Equipment.machine,
    recommendedReps: 10,
    defaultRestSeconds: 90,
  ),

  Exercise(
    id: 'ex_barbell_bulgarian_split_squat',
    name: 'Barbell Bulgarian Split Squat',
    description:
        'Set up a barbell on your upper back. Place one foot behind you on a bench, and perform a single-leg squat with your front leg.',
    primaryMuscleGroup: MuscleGroup.legs,
    difficulty: Difficulty.advanced,
    equipment: Equipment.barbell,
    recommendedReps: 6,
    defaultRestSeconds: 90,
  ),
  Exercise(
    id: 'ex_bulgarian_split_squat',
    name: 'Dumbbell Bulgarian Split Squat',
    description:
        'Place one foot behind you on a bench, hold two dumbbells at your sides, and perform a single-leg squat with your front leg.',
    primaryMuscleGroup: MuscleGroup.legs,
    difficulty: Difficulty.intermediate,
    equipment: Equipment.dumbbell,
    recommendedReps: 8,
    defaultRestSeconds: 90,
  ),
  Exercise(
    id: 'ex_smith_machine_bulgarian_split_squat',
    name: 'Machine Bulgarian Split Squat (Smith Machine)',
    description:
        'Set up inside a Smith machine. Place one foot on a bench behind you, rest the bar on your shoulders, and squat down vertically.',
    primaryMuscleGroup: MuscleGroup.legs,
    difficulty: Difficulty.intermediate,
    equipment: Equipment.machine,
    recommendedReps: 8,
    defaultRestSeconds: 90,
  ),

  Exercise(
    id: 'ex_barbell_walking_lunges',
    name: 'Barbell Walking Lunges',
    description:
        'Support a barbell on your upper back. Take a large step forward, drop your hips until your rear knee almost touches the floor, and repeat in a walking motion.',
    primaryMuscleGroup: MuscleGroup.legs,
    difficulty: Difficulty.advanced,
    equipment: Equipment.barbell,
    recommendedReps: 10,
    defaultRestSeconds: 90,
  ),
  Exercise(
    id: 'ex_lunges',
    name: 'Dumbbell Walking Lunges',
    description:
        'Hold dumbbells at your sides. Step forward and lower your hips until your back knee nearly touches the floor, then step forward into the next lunge.',
    primaryMuscleGroup: MuscleGroup.legs,
    difficulty: Difficulty.intermediate,
    equipment: Equipment.dumbbell,
    recommendedReps: 10,
    defaultRestSeconds: 90,
  ),

  Exercise(
    id: 'ex_hip_thrust',
    name: 'Barbell Hip Thrust',
    description:
        'Sit with your upper back against a bench, place a padded barbell across your hips, and drive your hips upward, squeezing your glutes at the top.',
    primaryMuscleGroup: MuscleGroup.legs,
    difficulty: Difficulty.intermediate,
    equipment: Equipment.barbell,
    recommendedReps: 10,
    defaultRestSeconds: 120,
  ),
  Exercise(
    id: 'ex_dumbbell_hip_thrust',
    name: 'Dumbbell Hip Thrust',
    description:
        'Lie with your back against a bench. Place a heavy dumbbell on your pelvis and push your hips up toward the ceiling, contracting your glutes.',
    primaryMuscleGroup: MuscleGroup.legs,
    difficulty: Difficulty.beginner,
    equipment: Equipment.dumbbell,
    recommendedReps: 12,
    defaultRestSeconds: 90,
  ),
  Exercise(
    id: 'ex_machine_hip_thrust',
    name: 'Machine Hip Thrust',
    description:
        'Secure yourself in a hip thrust machine with the padded belt/lever over your hips. Push the weight platform up, squeezing your glutes at maximum hip extension.',
    primaryMuscleGroup: MuscleGroup.legs,
    difficulty: Difficulty.beginner,
    equipment: Equipment.machine,
    recommendedReps: 10,
    defaultRestSeconds: 90,
  ),

  Exercise(
    id: 'ex_barbell_standing_calf_raises',
    name: 'Barbell Standing Calf Raises',
    description:
        'Hold a barbell on your upper back. Stand on a flat surface or a block and raise up onto the balls of your feet, squeezing your calves.',
    primaryMuscleGroup: MuscleGroup.legs,
    difficulty: Difficulty.intermediate,
    equipment: Equipment.barbell,
    recommendedReps: 15,
    defaultRestSeconds: 60,
  ),
  Exercise(
    id: 'ex_dumbbell_standing_calf_raises',
    name: 'Dumbbell Standing Calf Raises',
    description:
        'Hold a dumbbell in each hand at your sides. Elevate your heels up off the ground by contracting your calves.',
    primaryMuscleGroup: MuscleGroup.legs,
    difficulty: Difficulty.beginner,
    equipment: Equipment.dumbbell,
    recommendedReps: 15,
    defaultRestSeconds: 60,
  ),
  Exercise(
    id: 'ex_calf_raises',
    name: 'Bodyweight Standing Calf Raises',
    description:
        'Stand and rise onto the balls of your feet, contracting your calves hard, hold for one second, and slowly lower down.',
    primaryMuscleGroup: MuscleGroup.legs,
    difficulty: Difficulty.beginner,
    equipment: Equipment.bodyweight,
    recommendedReps: 15,
    defaultRestSeconds: 60,
  ),
  Exercise(
    id: 'ex_machine_standing_calf_raises',
    name: 'Machine Standing Calf Raises',
    description:
        'Position your shoulders under the pads of a standing calf raise machine. Push up through your toes, squeezing your calves at the top of the movement.',
    primaryMuscleGroup: MuscleGroup.legs,
    difficulty: Difficulty.beginner,
    equipment: Equipment.machine,
    recommendedReps: 12,
    defaultRestSeconds: 60,
  ),

  Exercise(
    id: 'ex_barbell_seated_calf_raises',
    name: 'Barbell Seated Calf Raises',
    description:
        'Sit on a bench, place a padded barbell across your knees (with feet on a block). Lift your heels upward by flexing your calves.',
    primaryMuscleGroup: MuscleGroup.legs,
    difficulty: Difficulty.intermediate,
    equipment: Equipment.barbell,
    recommendedReps: 15,
    defaultRestSeconds: 60,
  ),
  Exercise(
    id: 'ex_dumbbell_seated_calf_raises',
    name: 'Dumbbell Seated Calf Raises',
    description:
        'Sit on a bench, place a dumbbell on top of each knee. Raise your heels as high as possible, contracting your calves.',
    primaryMuscleGroup: MuscleGroup.legs,
    difficulty: Difficulty.beginner,
    equipment: Equipment.dumbbell,
    recommendedReps: 15,
    defaultRestSeconds: 60,
  ),
  Exercise(
    id: 'ex_seated_calf_raises',
    name: 'Machine Seated Calf Raises',
    description:
        'Sit at the seated calf raise machine, place the pad on your thighs, and push up by raising your heels.',
    primaryMuscleGroup: MuscleGroup.legs,
    difficulty: Difficulty.beginner,
    equipment: Equipment.machine,
    recommendedReps: 15,
    defaultRestSeconds: 60,
  ),

  Exercise(
    id: 'ex_leg_extension',
    name: 'Machine Leg Extension',
    description:
        'Sit at the leg extension machine. Push the roller pad upward by fully extending your legs to isolate the quadriceps.',
    primaryMuscleGroup: MuscleGroup.legs,
    difficulty: Difficulty.beginner,
    equipment: Equipment.machine,
    recommendedReps: 12,
    defaultRestSeconds: 60,
  ),
  Exercise(
    id: 'ex_leg_curl',
    name: 'Machine Lying Leg Curl',
    description:
        'Lie face down on the leg curl machine. Bend your knees to pull the roller pad toward your glutes, isolating the hamstrings.',
    primaryMuscleGroup: MuscleGroup.legs,
    difficulty: Difficulty.beginner,
    equipment: Equipment.machine,
    recommendedReps: 12,
    defaultRestSeconds: 60,
  ),
  Exercise(
    id: 'ex_seated_leg_curl',
    name: 'Machine Seated Leg Curl',
    description:
        'Sit in the machine and secure the thigh pad. Flex your knees to pull the lever backward toward your glutes, isolating the hamstrings.',
    primaryMuscleGroup: MuscleGroup.legs,
    difficulty: Difficulty.beginner,
    equipment: Equipment.machine,
    recommendedReps: 12,
    defaultRestSeconds: 60,
  ),

  Exercise(
    id: 'ex_overhead_press',
    name: 'Barbell Overhead Press',
    description:
        'Stand and press the barbell overhead starting from your collarbones. Contract your core and glutes to maintain torso stability.',
    primaryMuscleGroup: MuscleGroup.shoulders,
    difficulty: Difficulty.intermediate,
    equipment: Equipment.barbell,
    recommendedReps: 8,
    defaultRestSeconds: 120,
  ),
  Exercise(
    id: 'ex_dumbbell_press',
    name: 'Dumbbell Shoulder Press',
    description:
        'Sit on a utility bench with dumbbells. Press the dumbbells upward from ear level until your arms are extended.',
    primaryMuscleGroup: MuscleGroup.shoulders,
    difficulty: Difficulty.beginner,
    equipment: Equipment.dumbbell,
    recommendedReps: 10,
    defaultRestSeconds: 90,
  ),
  Exercise(
    id: 'ex_machine_shoulder_press',
    name: 'Machine Shoulder Press',
    description:
        'Sit at the shoulder press machine, grasp the handles and push vertically in a guided upward path.',
    primaryMuscleGroup: MuscleGroup.shoulders,
    difficulty: Difficulty.beginner,
    equipment: Equipment.machine,
    recommendedReps: 10,
    defaultRestSeconds: 90,
  ),
  Exercise(
    id: 'ex_arnold_press',
    name: 'Dumbbell Arnold Press',
    description:
        'Sit and press the dumbbells overhead while rotating your palms 180 degrees, starting with palms facing you at chest level.',
    primaryMuscleGroup: MuscleGroup.shoulders,
    difficulty: Difficulty.intermediate,
    equipment: Equipment.dumbbell,
    recommendedReps: 10,
    defaultRestSeconds: 90,
  ),

  Exercise(
    id: 'ex_lateral_raises',
    name: 'Dumbbell Lateral Raise',
    description:
        'Stand holding a dumbbell in each hand. Raise your arms out to the sides until they are parallel to the floor, keeping a slight bend in your elbows.',
    primaryMuscleGroup: MuscleGroup.shoulders,
    difficulty: Difficulty.beginner,
    equipment: Equipment.dumbbell,
    recommendedReps: 12,
    defaultRestSeconds: 60,
  ),
  Exercise(
    id: 'ex_cable_lateral_raises',
    name: 'Cable Lateral Raise',
    description:
        'Hold the low pulley cable handle. Raise your arm outward to the side, maintaining continuous tension on the lateral deltoid.',
    primaryMuscleGroup: MuscleGroup.shoulders,
    difficulty: Difficulty.intermediate,
    equipment: Equipment.cable,
    recommendedReps: 12,
    defaultRestSeconds: 60,
  ),
  Exercise(
    id: 'ex_machine_lateral_raises',
    name: 'Machine Lateral Raise',
    description:
        'Sit at the lateral raise machine, rest your outer arms against the pads, and lift your elbows outward to a horizontal position.',
    primaryMuscleGroup: MuscleGroup.shoulders,
    difficulty: Difficulty.beginner,
    equipment: Equipment.machine,
    recommendedReps: 12,
    defaultRestSeconds: 60,
  ),

  Exercise(
    id: 'ex_barbell_front_raise',
    name: 'Barbell Front Raise',
    description:
        'Hold a barbell with an overhand grip resting against your thighs. Raise the bar straight in front of you until your arms are parallel to the floor.',
    primaryMuscleGroup: MuscleGroup.shoulders,
    difficulty: Difficulty.intermediate,
    equipment: Equipment.barbell,
    recommendedReps: 10,
    defaultRestSeconds: 60,
  ),
  Exercise(
    id: 'ex_front_raises_dumbbell',
    name: 'Dumbbell Front Raise',
    description:
        'Stand with dumbbells at your thighs. Raise one dumbbell (or both) straight in front of you to shoulder level, then lower slowly.',
    primaryMuscleGroup: MuscleGroup.shoulders,
    difficulty: Difficulty.beginner,
    equipment: Equipment.dumbbell,
    recommendedReps: 12,
    defaultRestSeconds: 60,
  ),
  Exercise(
    id: 'ex_cable_front_raise',
    name: 'Cable Front Raise',
    description:
        'Attach a straight bar or single D-handle to a low pulley. Face away from the machine and lift your arms forward and up to shoulder level.',
    primaryMuscleGroup: MuscleGroup.shoulders,
    difficulty: Difficulty.beginner,
    equipment: Equipment.cable,
    recommendedReps: 12,
    defaultRestSeconds: 60,
  ),

  Exercise(
    id: 'ex_dumbbell_rear_delt_fly',
    name: 'Dumbbell Rear Delt Fly',
    description:
        'Bend forward at your hips with your back flat. Raise the dumbbells out to your sides, keeping a slight bend in your elbows, targeting the rear delts.',
    primaryMuscleGroup: MuscleGroup.shoulders,
    difficulty: Difficulty.beginner,
    equipment: Equipment.dumbbell,
    recommendedReps: 12,
    defaultRestSeconds: 60,
  ),
  Exercise(
    id: 'ex_machine_rear_delt_fly',
    name: 'Machine Rear Delt Fly (Reverse Pec Deck)',
    description:
        'Sit facing the chest pad on a reverse fly machine. Grip the handles and pull your arms backward in a wide horizontal arc to contract the rear delts.',
    primaryMuscleGroup: MuscleGroup.shoulders,
    difficulty: Difficulty.beginner,
    equipment: Equipment.machine,
    recommendedReps: 12,
    defaultRestSeconds: 60,
  ),
  Exercise(
    id: 'ex_face_pulls',
    name: 'Cable Face Pulls',
    description:
        'Grab the rope attached to a high pulley. Pull the rope toward your face while flaring your elbows outward to isolate the rear deltoids.',
    primaryMuscleGroup: MuscleGroup.shoulders,
    difficulty: Difficulty.beginner,
    equipment: Equipment.cable,
    recommendedReps: 12,
    defaultRestSeconds: 60,
  ),

  Exercise(
    id: 'ex_upright_row_barbell',
    name: 'Barbell Upright Row',
    description:
        'Hold a barbell with a narrow grip. Pull the bar straight up along your chest toward your chin, leading with your elbows.',
    primaryMuscleGroup: MuscleGroup.shoulders,
    difficulty: Difficulty.intermediate,
    equipment: Equipment.barbell,
    recommendedReps: 10,
    defaultRestSeconds: 90,
  ),
  Exercise(
    id: 'ex_upright_row_dumbbell',
    name: 'Dumbbell Upright Row',
    description:
        'Hold a dumbbell in each hand in front of your thighs. Pull the dumbbells straight up to chest height, pulling your elbows high and outward.',
    primaryMuscleGroup: MuscleGroup.shoulders,
    difficulty: Difficulty.intermediate,
    equipment: Equipment.dumbbell,
    recommendedReps: 10,
    defaultRestSeconds: 90,
  ),
  Exercise(
    id: 'ex_upright_row_cable',
    name: 'Cable Upright Row',
    description:
        'Attach a straight bar or EZ-bar to a low pulley. Pull the bar up toward your upper chest, flaring your elbows outward.',
    primaryMuscleGroup: MuscleGroup.shoulders,
    difficulty: Difficulty.beginner,
    equipment: Equipment.cable,
    recommendedReps: 12,
    defaultRestSeconds: 75,
  ),

  Exercise(
    id: 'ex_barbell_curl',
    name: 'Barbell Bicep Curl',
    description:
        'Stand and grip an EZ-bar or straight barbell with an underhand grip. Flex your elbows to bring the bar toward your chest, contracting your biceps.',
    primaryMuscleGroup: MuscleGroup.arms,
    difficulty: Difficulty.beginner,
    equipment: Equipment.barbell,
    recommendedReps: 10,
    defaultRestSeconds: 75,
  ),
  Exercise(
    id: 'ex_bicep_curl',
    name: 'Dumbbell Bicep Curl',
    description:
        'Stand with dumbbells at your sides. Flex your elbows while rotating your wrists upward (supination) and squeeze your biceps at the top.',
    primaryMuscleGroup: MuscleGroup.arms,
    difficulty: Difficulty.beginner,
    equipment: Equipment.dumbbell,
    recommendedReps: 12,
    defaultRestSeconds: 60,
  ),
  Exercise(
    id: 'ex_cable_bicep_curl_straight',
    name: 'Cable Bicep Curl',
    description:
        'Stand facing the cable machine, grasp the straight bar connected to the low pulley, and perform a bicep curl under continuous tension.',
    primaryMuscleGroup: MuscleGroup.arms,
    difficulty: Difficulty.beginner,
    equipment: Equipment.cable,
    recommendedReps: 12,
    defaultRestSeconds: 60,
  ),
  Exercise(
    id: 'ex_machine_bicep_curl',
    name: 'Machine Bicep Curl',
    description:
        'Sit at the bicep curl machine, adjust the seat so your elbows rest on the pad, grab the handles and curl them up towards your face.',
    primaryMuscleGroup: MuscleGroup.arms,
    difficulty: Difficulty.beginner,
    equipment: Equipment.machine,
    recommendedReps: 12,
    defaultRestSeconds: 60,
  ),

  Exercise(
    id: 'ex_hammer_curl',
    name: 'Dumbbell Hammer Curl',
    description:
        'Stand with dumbbells, flex your elbows while maintaining a neutral grip (palms facing each other).',
    primaryMuscleGroup: MuscleGroup.arms,
    difficulty: Difficulty.beginner,
    equipment: Equipment.dumbbell,
    recommendedReps: 12,
    defaultRestSeconds: 60,
  ),
  Exercise(
    id: 'ex_cable_hammer_curl',
    name: 'Cable Rope Hammer Curl',
    description:
        'Attach a rope to the low pulley. Hold the ends with a neutral grip and curl up, keeping your elbows locked at your sides.',
    primaryMuscleGroup: MuscleGroup.arms,
    difficulty: Difficulty.beginner,
    equipment: Equipment.cable,
    recommendedReps: 12,
    defaultRestSeconds: 60,
  ),

  Exercise(
    id: 'ex_preacher_curl',
    name: 'Preacher EZ-Bar Curl',
    description:
        'Position your arms on the preacher bench pad. Flex your elbows to bring the bar up, contracting your biceps hard at the peak.',
    primaryMuscleGroup: MuscleGroup.arms,
    difficulty: Difficulty.intermediate,
    equipment: Equipment.barbell,
    recommendedReps: 10,
    defaultRestSeconds: 75,
  ),
  Exercise(
    id: 'ex_dumbbell_preacher_curl',
    name: 'Dumbbell Preacher Curl',
    description:
        'Sit at a preacher bench and curl a single dumbbell in one hand, allowing for unilateral control and isolation.',
    primaryMuscleGroup: MuscleGroup.arms,
    difficulty: Difficulty.intermediate,
    equipment: Equipment.dumbbell,
    recommendedReps: 10,
    defaultRestSeconds: 75,
  ),
  Exercise(
    id: 'ex_machine_preacher_curl',
    name: 'Machine Preacher Curl',
    description:
        'Sit at the preacher curl machine, place your arms on the angled support pad, and pull the handles up through the guided path.',
    primaryMuscleGroup: MuscleGroup.arms,
    difficulty: Difficulty.beginner,
    equipment: Equipment.machine,
    recommendedReps: 10,
    defaultRestSeconds: 75,
  ),

  Exercise(
    id: 'ex_barbell_overhead_tricep_extension',
    name: 'Barbell Overhead Tricep Extension',
    description:
        'Hold an EZ-bar or barbell overhead with your arms straight. Bend your elbows to lower the weight behind your head, then extend your arms back up.',
    primaryMuscleGroup: MuscleGroup.arms,
    difficulty: Difficulty.intermediate,
    equipment: Equipment.barbell,
    recommendedReps: 10,
    defaultRestSeconds: 75,
  ),
  Exercise(
    id: 'ex_overhead_tricep_extension',
    name: 'Dumbbell Overhead Tricep Extension',
    description:
        'Seated or standing, hold a dumbbell overhead with both hands. Lower the weight behind your head, then extend your arms to push it up.',
    primaryMuscleGroup: MuscleGroup.arms,
    difficulty: Difficulty.beginner,
    equipment: Equipment.dumbbell,
    recommendedReps: 12,
    defaultRestSeconds: 60,
  ),
  Exercise(
    id: 'ex_cable_overhead_tricep_extension',
    name: 'Cable Overhead Tricep Extension',
    description:
        'Attach a rope to the high pulley, turn your back to the machine, and press the rope forward and upward by extending your elbows.',
    primaryMuscleGroup: MuscleGroup.arms,
    difficulty: Difficulty.beginner,
    equipment: Equipment.cable,
    recommendedReps: 12,
    defaultRestSeconds: 60,
  ),

  Exercise(
    id: 'ex_skull_crushers',
    name: 'EZ-Bar Skull Crushers',
    description:
        'Lie on a flat bench with an EZ-bar. Bend your elbows to lower the bar toward your forehead, then extend your arms.',
    primaryMuscleGroup: MuscleGroup.arms,
    difficulty: Difficulty.intermediate,
    equipment: Equipment.barbell,
    recommendedReps: 10,
    defaultRestSeconds: 75,
  ),
  Exercise(
    id: 'ex_dumbbell_skull_crushers',
    name: 'Dumbbell Skull Crushers',
    description:
        'Lie on a bench with a dumbbell in each hand, palms facing each other. Lower the weights toward your temples, then extend your arms.',
    primaryMuscleGroup: MuscleGroup.arms,
    difficulty: Difficulty.intermediate,
    equipment: Equipment.dumbbell,
    recommendedReps: 10,
    defaultRestSeconds: 75,
  ),

  Exercise(
    id: 'ex_tricep_pushdown',
    name: 'Tricep Cable Pushdown',
    description:
        'Grip the rope attached to a high pulley. Push downward by extending your arms and flaring the rope outward at the bottom.',
    primaryMuscleGroup: MuscleGroup.arms,
    difficulty: Difficulty.beginner,
    equipment: Equipment.cable,
    recommendedReps: 12,
    defaultRestSeconds: 60,
  ),
  Exercise(
    id: 'ex_close_grip_bench_press',
    name: 'Barbell Close-Grip Bench Press',
    description:
        'Lie on a flat bench, grip the barbell at shoulder-width or slightly closer. Lower the bar to your chest while keeping your elbows close to your torso, then press up.',
    primaryMuscleGroup: MuscleGroup.arms,
    difficulty: Difficulty.intermediate,
    equipment: Equipment.barbell,
    recommendedReps: 8,
    defaultRestSeconds: 90,
  ),
  Exercise(
    id: 'ex_bench_dips',
    name: 'Bench Dips',
    description:
        'Place your hands on the edge of a bench behind you. Lower your hips by bending your elbows to 90 degrees, then push back up.',
    primaryMuscleGroup: MuscleGroup.arms,
    difficulty: Difficulty.beginner,
    equipment: Equipment.bodyweight,
    recommendedReps: 12,
    defaultRestSeconds: 60,
  ),

  Exercise(
    id: 'ex_wrist_curl',
    name: 'Barbell Wrist Curl',
    description:
        'Sit on a bench with your forearms resting on your thighs, palms up. Flex your wrists to lift the barbell.',
    primaryMuscleGroup: MuscleGroup.arms,
    difficulty: Difficulty.beginner,
    equipment: Equipment.barbell,
    recommendedReps: 15,
    defaultRestSeconds: 60,
  ),
  Exercise(
    id: 'ex_dumbbell_wrist_curl',
    name: 'Dumbbell Wrist Curl',
    description:
        'Sit on a bench with forearms on your thighs holding dumbbells with palms up. Curl your wrists upward to isolate the forearm flexors.',
    primaryMuscleGroup: MuscleGroup.arms,
    difficulty: Difficulty.beginner,
    equipment: Equipment.dumbbell,
    recommendedReps: 15,
    defaultRestSeconds: 60,
  ),
  Exercise(
    id: 'ex_cable_wrist_curl',
    name: 'Cable Wrist Curl',
    description:
        'Rest your forearms on your thighs or on a flat bench while holding a straight bar attached to a low pulley. Curl your wrists upward under tension.',
    primaryMuscleGroup: MuscleGroup.arms,
    difficulty: Difficulty.beginner,
    equipment: Equipment.cable,
    recommendedReps: 15,
    defaultRestSeconds: 60,
  ),

  Exercise(
    id: 'ex_reverse_wrist_curl',
    name: 'Barbell Reverse Wrist Curl',
    description:
        'Sit on a bench with your forearms resting on your thighs, palms down. Extend your wrists to lift the barbell.',
    primaryMuscleGroup: MuscleGroup.arms,
    difficulty: Difficulty.beginner,
    equipment: Equipment.barbell,
    recommendedReps: 15,
    defaultRestSeconds: 60,
  ),
  Exercise(
    id: 'ex_dumbbell_reverse_wrist_curl',
    name: 'Dumbbell Reverse Wrist Curl',
    description:
        'Place your forearms on your thighs while holding dumbbells with palms down. Extend your wrists upward to work the forearm extensors.',
    primaryMuscleGroup: MuscleGroup.arms,
    difficulty: Difficulty.beginner,
    equipment: Equipment.dumbbell,
    recommendedReps: 15,
    defaultRestSeconds: 60,
  ),
  Exercise(
    id: 'ex_cable_reverse_wrist_curl',
    name: 'Cable Reverse Wrist Curl',
    description:
        'Hold a straight bar attached to a low pulley with a prone grip (palms down). Keep your forearms steady and extend your wrists upward.',
    primaryMuscleGroup: MuscleGroup.arms,
    difficulty: Difficulty.beginner,
    equipment: Equipment.cable,
    recommendedReps: 15,
    defaultRestSeconds: 60,
  ),
  Exercise(
    id: 'ex_reverse_barbell_curl',
    name: 'Reverse Barbell Bicep Curl',
    description:
        'Stand and perform a standard bicep curl using an overhand grip (palms down). Heavily engages the brachioradialis.',
    primaryMuscleGroup: MuscleGroup.arms,
    difficulty: Difficulty.intermediate,
    equipment: Equipment.barbell,
    recommendedReps: 12,
    defaultRestSeconds: 75,
  ),

  Exercise(
    id: 'ex_plank',
    name: 'Abdominal Plank',
    description:
        'Support your weight on your forearms and toes. Keep your body in a straight line, squeezing your core and glutes without letting your hips sag.',
    primaryMuscleGroup: MuscleGroup.core,
    difficulty: Difficulty.beginner,
    equipment: Equipment.bodyweight,
    recommendedReps: 60,
    defaultRestSeconds: 60,
  ),
  Exercise(
    id: 'ex_crunches',
    name: 'Abdominal Crunches',
    description:
        'Lie on your back with knees bent. Lift your shoulder blades off the floor by contracting your upper abdominal wall.',
    primaryMuscleGroup: MuscleGroup.core,
    difficulty: Difficulty.beginner,
    equipment: Equipment.bodyweight,
    recommendedReps: 20,
    defaultRestSeconds: 45,
  ),
  Exercise(
    id: 'ex_weighted_crunches_db',
    name: 'Dumbbell Weighted Crunches',
    description:
        'Perform standard abdominal crunches while holding a dumbbell over your chest or behind your head to increase resistance.',
    primaryMuscleGroup: MuscleGroup.core,
    difficulty: Difficulty.intermediate,
    equipment: Equipment.dumbbell,
    recommendedReps: 15,
    defaultRestSeconds: 60,
  ),
  Exercise(
    id: 'ex_cable_crunch',
    name: 'Kneeling Cable Crunch',
    description:
        'Kneel in front of a high pulley cable machine. Hold the rope attachment behind your neck, bend forward and pull down, contracting your abs.',
    primaryMuscleGroup: MuscleGroup.core,
    difficulty: Difficulty.intermediate,
    equipment: Equipment.cable,
    recommendedReps: 12,
    defaultRestSeconds: 60,
  ),
  Exercise(
    id: 'ex_leg_raises',
    name: 'Hanging Leg Raises',
    description:
        'Hang from a pull-up bar. Lift your legs straight in front of you until they are parallel to the ground using core strength.',
    primaryMuscleGroup: MuscleGroup.core,
    difficulty: Difficulty.advanced,
    equipment: Equipment.bodyweight,
    recommendedReps: 10,
    defaultRestSeconds: 75,
  ),
  Exercise(
    id: 'ex_woodchopper',
    name: 'Cable Woodchopper',
    description:
        'Grab the high pulley cable with both hands. Pull the cable diagonally downward across your body while rotating your core.',
    primaryMuscleGroup: MuscleGroup.core,
    difficulty: Difficulty.intermediate,
    equipment: Equipment.cable,
    recommendedReps: 12,
    defaultRestSeconds: 60,
  ),
  Exercise(
    id: 'ex_russian_twist',
    name: 'Dumbbell Russian Twists',
    description:
        'Sit with your knees slightly bent and feet off the ground. Rotate your torso side to side, holding a weight or dumbbell.',
    primaryMuscleGroup: MuscleGroup.core,
    difficulty: Difficulty.beginner,
    equipment: Equipment.dumbbell,
    recommendedReps: 15,
    defaultRestSeconds: 45,
  ),
  Exercise(
    id: 'ex_barbell_russian_twist',
    name: 'Barbell Russian Twist (Landmine)',
    description:
        'Grip the end of an anchored barbell with both hands. Stand and rotate the barbell from hip to hip in an arc, engaging your obliques.',
    primaryMuscleGroup: MuscleGroup.core,
    difficulty: Difficulty.advanced,
    equipment: Equipment.barbell,
    recommendedReps: 12,
    defaultRestSeconds: 60,
  ),
  Exercise(
    id: 'ex_side_plank',
    name: 'Side Plank',
    description:
        'Lie on your side, supporting your weight on your forearm and the edge of your foot. Hold your body in a straight line.',
    primaryMuscleGroup: MuscleGroup.core,
    difficulty: Difficulty.beginner,
    equipment: Equipment.bodyweight,
    recommendedReps: 45,
    defaultRestSeconds: 60,
  ),
  Exercise(
    id: 'ex_seated_adduction_machine',
    name: 'Machine Seated Adduction',
    description:
        'Sit at the thigh adductor machine with your knees positioned on the outside of the pads. Squeeze your thighs together against the resistance to work your inner thighs.',
    primaryMuscleGroup: MuscleGroup.legs,
    difficulty: Difficulty.beginner,
    equipment: Equipment.machine,
    recommendedReps: 15,
    defaultRestSeconds: 60,
    notes: 'Maintain a controlled tempo and avoid using momentum.',
  ),
  Exercise(
    id: 'ex_seated_abduction_machine',
    name: 'Machine Seated Abduction',
    description:
        'Sit at the thigh abductor machine with your knees positioned on the inside of the pads. Push your legs outward against the resistance to work your outer thighs and gluteus medius.',
    primaryMuscleGroup: MuscleGroup.legs,
    difficulty: Difficulty.beginner,
    equipment: Equipment.machine,
    recommendedReps: 15,
    defaultRestSeconds: 60,
  ),
  Exercise(
    id: 'ex_cable_hip_adduction',
    name: 'Cable Hip Adduction',
    description:
        'Stand sideways next to a low pulley cable machine and attach the ankle strap to the leg closest to the machine. Swing your leg across the front of your body under control.',
    primaryMuscleGroup: MuscleGroup.legs,
    difficulty: Difficulty.intermediate,
    equipment: Equipment.cable,
    recommendedReps: 12,
    defaultRestSeconds: 60,
  ),
  Exercise(
    id: 'ex_cable_hip_abduction',
    name: 'Cable Hip Abduction',
    description:
        'Stand sideways next to a low pulley cable machine and attach the ankle strap to the leg furthest from the machine. Lift your outer leg away from your body against the tension.',
    primaryMuscleGroup: MuscleGroup.legs,
    difficulty: Difficulty.intermediate,
    equipment: Equipment.cable,
    recommendedReps: 12,
    defaultRestSeconds: 60,
  ),
  Exercise(
    id: 'ex_copenhagen_plank',
    name: 'Copenhagen Plank',
    description:
        'Place your top leg on a bench or elevated platform while supporting your body on your forearm. Lift your lower leg and hold the plank position to build intense inner thigh strength.',
    primaryMuscleGroup: MuscleGroup.legs,
    difficulty: Difficulty.advanced,
    equipment: Equipment.bodyweight,
    recommendedReps: 30, 
    defaultRestSeconds: 75,
    notes:
        'Keep your hips elevated and aligned with your torso throughout the hold.',
  ),
  Exercise(
    id: 'ex_bodyweight_clamshells',
    name: 'Bodyweight Clamshells',
    description:
        'Lie on your side with your hips and knees bent at 45 degrees. Keeping your feet touching, raise your top knee as high as possible without shifting your pelvis.',
    primaryMuscleGroup: MuscleGroup.legs,
    difficulty: Difficulty.beginner,
    equipment: Equipment.bodyweight,
    recommendedReps: 15,
    defaultRestSeconds: 45,
    notes: 'Excellent for gluteus medius activation and hip rehabilitation.',
  ),
];