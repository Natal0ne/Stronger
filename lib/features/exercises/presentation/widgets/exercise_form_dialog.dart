import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronger/core/models/enums.dart';
import 'package:stronger/core/models/exercise.dart';
import 'package:stronger/core/theme/app_colors.dart';
import 'package:stronger/features/exercises/presentation/exercises_controller.dart';

class ExerciseFormDialog extends ConsumerStatefulWidget {
  final Exercise? exercise;

  const ExerciseFormDialog({super.key, this.exercise});

  @override
  ConsumerState<ExerciseFormDialog> createState() => _ExerciseFormDialogState();
}

class _ExerciseFormDialogState extends ConsumerState<ExerciseFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _repsController;
  late TextEditingController _restController; // <--- Aggiunto
  late TextEditingController _notesController;

  MuscleGroup? _selectedMuscle;
  Difficulty? _selectedDifficulty;
  Equipment? _selectedEquipment;
  bool _autoValidate = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.exercise?.name);
    _descriptionController = TextEditingController(text: widget.exercise?.description);
    _repsController = TextEditingController(text: widget.exercise != null ? widget.exercise!.recommendedReps.toString() : '');
    _restController = TextEditingController(text: widget.exercise != null ? widget.exercise!.defaultRestSeconds.toString() : '60'); // <--- Aggiunto
    _notesController = TextEditingController(text: widget.exercise?.notes);

    _selectedMuscle = widget.exercise?.primaryMuscleGroup;
    _selectedDifficulty = widget.exercise?.difficulty;
    _selectedEquipment = widget.exercise?.equipment;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _repsController.dispose();
    _restController.dispose(); // <--- Aggiunto
    _notesController.dispose();
    super.dispose();
  }

  Color _getDifficultyColor(Difficulty level) {
    switch (level) {
      case Difficulty.beginner: return Colors.greenAccent;
      case Difficulty.intermediate: return Colors.orangeAccent;
      case Difficulty.advanced: return Colors.redAccent;
    }
  }

  Color _getEquipmentColor(Equipment tool) {
    switch (tool) {
      case Equipment.bodyweight: return Colors.cyanAccent;
      case Equipment.dumbbell: return Colors.purpleAccent;
      case Equipment.barbell: return Colors.blueAccent;
      case Equipment.machine: return Colors.amberAccent;
      case Equipment.cable: return Colors.pinkAccent;
    }
  }

  Color _getMuscleColor(MuscleGroup muscle) => AppColors.accent;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      title: Text(widget.exercise != null ? 'Edit Exercise' : 'New Exercise', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(labelText: 'Exercise Name', prefixIcon: Icon(Icons.fitness_center, color: AppColors.accent)),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter an exercise name' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  maxLines: 3,
                  minLines: 1,
                  decoration: const InputDecoration(labelText: 'Description', prefixIcon: Icon(Icons.description_outlined, color: AppColors.accent)),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter description/instructions' : null,
                ),
                const SizedBox(height: 24),
                const Text('Muscle Group', style: TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: MuscleGroup.values.map((type) {
                    final isSelected = _selectedMuscle == type;
                    final color = _getMuscleColor(type);
                    return GestureDetector(
                      onTap: () => setState(() => _selectedMuscle = type),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? color.withAlpha(50) : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: isSelected ? color : Colors.grey.withAlpha(80), width: isSelected ? 2 : 1),
                        ),
                        child: Text(type.name.toUpperCase(), style: TextStyle(color: isSelected ? color : Colors.grey, fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                      ),
                    );
                  }).toList(),
                ),
                if (_autoValidate && _selectedMuscle == null)
                  const Padding(padding: EdgeInsets.only(top: 6), child: Text('Please select a muscle group', style: TextStyle(color: Colors.redAccent, fontSize: 12))),
                  const SizedBox(height: 20),
                  const Text('Difficulty', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: Difficulty.values.map((level) {
                      final isSelected = _selectedDifficulty == level;
                      final color = _getDifficultyColor(level);
                      return GestureDetector(
                        onTap: () => setState(() => _selectedDifficulty = level),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? color.withAlpha(50) : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: isSelected ? color : Colors.grey.withAlpha(80), width: isSelected ? 2 : 1),
                          ),
                          child: Text(level.name.toUpperCase(), style: TextStyle(color: isSelected ? color : Colors.grey, fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                        ),
                      );
                    }).toList(),
                  ),
                  if (_autoValidate && _selectedDifficulty == null)
                    const Padding(padding: EdgeInsets.only(top: 6), child: Text('Please select a difficulty level', style: TextStyle(color: Colors.redAccent, fontSize: 12))),
                    const SizedBox(height: 20),
                    const Text('Equipment', style: TextStyle(color: Colors.grey, fontSize: 13)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: Equipment.values.map((tool) {
                        final isSelected = _selectedEquipment == tool;
                        final color = _getEquipmentColor(tool);
                        return GestureDetector(
                          onTap: () => setState(() => _selectedEquipment = tool),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected ? color.withAlpha(50) : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: isSelected ? color : Colors.grey.withAlpha(80), width: isSelected ? 2 : 1),
                            ),
                            child: Text(tool.name.toUpperCase(), style: TextStyle(color: isSelected ? color : Colors.grey, fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                          ),
                        );
                      }).toList(),
                    ),
                    if (_autoValidate && _selectedEquipment == null)
                      const Padding(padding: EdgeInsets.only(top: 6), child: Text('Please select required equipment', style: TextStyle(color: Colors.redAccent, fontSize: 12))),
                      const SizedBox(height: 24),
                      const Row(
                        children: [
                          Icon(Icons.tune_outlined, color: AppColors.accent, size: 18),
                          SizedBox(width: 8),
                          Text('Details', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // RIGA DETTAGLI: REPS E TEMPO DI RECUPERO DEFAULT
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _repsController,
                              style: const TextStyle(color: AppColors.textPrimary),
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Rec. Reps', prefixIcon: Icon(Icons.repeat, color: AppColors.accent, size: 18)),
                              validator: (v) => (v == null || int.tryParse(v) == null) ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _restController, // <--- CAMPO INSERIMENTO SECONDI DI RECUPERO
                              style: const TextStyle(color: AppColors.textPrimary),
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Rest (seconds)', prefixIcon: Icon(Icons.timer_outlined, color: AppColors.accent, size: 18)),
                              validator: (v) => (v == null || int.tryParse(v) == null) ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _notesController,
                        style: const TextStyle(color: AppColors.textPrimary),
                        maxLines: 2,
                        minLines: 1,
                        decoration: const InputDecoration(labelText: 'Optional Notes', prefixIcon: Icon(Icons.notes_outlined, color: AppColors.accent, size: 20)),
                      ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
          onPressed: () {
            if (!_formKey.currentState!.validate() || _selectedMuscle == null || _selectedDifficulty == null || _selectedEquipment == null) {
              setState(() => _autoValidate = true);
              return;
            }

            final newExercise = Exercise(
              id: widget.exercise?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
              name: _nameController.text,
              description: _descriptionController.text,
              primaryMuscleGroup: _selectedMuscle!,
              difficulty: _selectedDifficulty!,
              equipment: _selectedEquipment!,
              recommendedReps: int.parse(_repsController.text),
              defaultRestSeconds: int.parse(_restController.text), // <--- SALVATO NEL DB!
                notes: _notesController.text,
            );

            ref.read(exercisesProvider.notifier).addExercise(newExercise);
            Navigator.pop(context);
          },
          child: const Text('Save', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
