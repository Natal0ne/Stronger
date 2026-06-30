import 'package:flutter/material.dart';
import 'package:stronger/models/routine.dart';
import 'package:stronger/models/routine_exercise.dart';
import 'package:stronger/models/exercise.dart';
import 'package:stronger/models/enums.dart';
import 'package:stronger/services/database_helper.dart';
import 'package:stronger/theme/app_colors.dart';

class RoutineEditorScreen extends StatefulWidget {
  final Routine? routine;

  const RoutineEditorScreen({super.key, this.routine});

  @override
  State<RoutineEditorScreen> createState() => _RoutineEditorScreenState();
}

class _RoutineEditorScreenState extends State<RoutineEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _durationController;

  RoutineGoal? _selectedGoal;
  List<RoutineExercise> _selectedExercises = [];

  bool _autoValidate = false;
  bool _autoValidateExercises = false;
  List<Exercise> _allExercises = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.routine?.name);
    _descController = TextEditingController(text: widget.routine?.description);
    _durationController = TextEditingController(
      text: widget.routine?.estimatedDurationMinutes ?? '60',
    );
    _selectedGoal = widget.routine?.goal;

    if (widget.routine != null) {
      _selectedExercises = List.from(
        widget.routine!.exercises.map(
          (re) => RoutineExercise(
            exerciseId: re.exerciseId,
            name: re.name,
            sets: re.sets,
            reps: re.reps,
          ),
        ),
      );
    }

    _loadExercises();
  }

  Future<void> _loadExercises() async {
    final exercises = await DatabaseHelper.instance.getExercises();
    setState(() {
      _allExercises = exercises;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Color _getGoalColor(RoutineGoal goal) {
    switch (goal) {
      case RoutineGoal.hypertrophy:
        return Colors.amberAccent;
      case RoutineGoal.strength:
        return Colors.redAccent;
      case RoutineGoal.endurance:
        return Colors.lightGreenAccent;
      case RoutineGoal.powerlifting:
        return Colors.deepPurpleAccent;
      default:
        return Colors.white;
    }
  }

  Color _getMuscleColor(MuscleGroup muscle) => AppColors.accent;

  Color _getEquipmentColor(Equipment tool) {
    switch (tool) {
      case Equipment.bodyweight:
        return Colors.cyanAccent;
      case Equipment.dumbbell:
        return Colors.purpleAccent;
      case Equipment.barbell:
        return Colors.blueAccent;
      case Equipment.machine:
        return Colors.amberAccent;
      case Equipment.cable:
        return Colors.pinkAccent;
      default:
        return Colors.white;
    }
  }

  Color _getDifficultyColor(Difficulty level) {
    switch (level) {
      case Difficulty.beginner:
        return Colors.greenAccent;
      case Difficulty.intermediate:
        return Colors.orangeAccent;
      case Difficulty.advanced:
        return Colors.redAccent;
      default:
        return Colors.white;
    }
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(40),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 9,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Costruisce i menu a tendina arrotondati e compatti
  Widget _buildRoundedDropdown<T extends Enum>({
    required String hint,
    required T? value,
    required List<T> items,
    required void Function(T?) onChanged,
  }) {
    return Container(
      height: 36, // Altezza fissa e compatta
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(
            hint,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          dropdownColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          borderRadius: BorderRadius.circular(16),
          icon: const Padding(
            padding: EdgeInsets.only(left: 6),
            child: Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: Colors.grey,
            ),
          ),
          items: items
              .map(
                (e) => DropdownMenuItem<T>(
                  value: e,
                  child: Text(e.name.toUpperCase()),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // Tasto Clear filtri, stessa altezza dei dropdown, ora come icona
  Widget _buildClearButton({required VoidCallback onPressed}) {
    return Tooltip(
      message: 'Clear filters',
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 36,
          width: 36,
          decoration: BoxDecoration(
            color: Colors.redAccent.withAlpha(20),
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.filter_alt_off,
            color: Colors.redAccent,
            size: 18,
          ),
        ),
      ),
    );
  }

  Future<void> _showAddExercisesDialog() async {
    final searchController = TextEditingController();
    MuscleGroup? filterMuscle;
    Difficulty? filterDifficulty;
    Equipment? filterEquipment;
    bool showFilters = false;

    List<RoutineExercise> tempSelected = List.from(
      _selectedExercises.map(
        (re) => RoutineExercise(
          exerciseId: re.exerciseId,
          name: re.name,
          sets: re.sets,
          reps: re.reps,
        ),
      ),
    );

    final result = await showDialog<List<RoutineExercise>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setPickerState) {
          final query = searchController.text.toLowerCase();
          final filteredExercises = _allExercises.where((ex) {
            final matchesSearch =
                ex.name.toLowerCase().contains(query) ||
                ex.description.toLowerCase().contains(query);
            final matchesMuscle =
                filterMuscle == null || ex.primaryMuscleGroup == filterMuscle;
            final matchesDifficulty =
                filterDifficulty == null || ex.difficulty == filterDifficulty;
            final matchesEquipment =
                filterEquipment == null || ex.equipment == filterEquipment;
            return matchesSearch &&
                matchesMuscle &&
                matchesDifficulty &&
                matchesEquipment;
          }).toList();

          filteredExercises.sort((a, b) => a.name.compareTo(b.name));

          return AlertDialog(
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 24,
            ),
            title: const Text(
              'Add Exercises',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: searchController,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      hintStyle: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.accent,
                        size: 18,
                      ),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (searchController.text.isNotEmpty)
                            IconButton(
                              icon: const Icon(
                                Icons.clear,
                                color: Colors.grey,
                                size: 16,
                              ),
                              onPressed: () {
                                searchController.clear();
                                setPickerState(() {});
                              },
                            ),
                          IconButton(
                            icon: Icon(
                              showFilters
                                  ? Icons.filter_alt
                                  : Icons.filter_alt_outlined,
                              color:
                                  (filterMuscle != null ||
                                      filterDifficulty != null ||
                                      filterEquipment != null)
                                  ? AppColors.accent
                                  : Colors.grey,
                              size: 20,
                            ),
                            onPressed: () => setPickerState(
                              () => showFilters = !showFilters,
                            ),
                          ),
                        ],
                      ),
                      filled: true,
                      fillColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHigh,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 8,
                      ),
                    ),
                    onChanged: (val) => setPickerState(() {}),
                  ),
                  if (showFilters) ...[
                    const SizedBox(height: 12),
                    // Filtri orizzontali per non occupare spazio verticale
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _buildRoundedDropdown<MuscleGroup>(
                            hint: 'Muscle',
                            value: filterMuscle,
                            items: MuscleGroup.values,
                            onChanged: (val) =>
                                setPickerState(() => filterMuscle = val),
                          ),
                          const SizedBox(width: 8),
                          _buildRoundedDropdown<Difficulty>(
                            hint: 'Difficulty',
                            value: filterDifficulty,
                            items: Difficulty.values,
                            onChanged: (val) =>
                                setPickerState(() => filterDifficulty = val),
                          ),
                          const SizedBox(width: 8),
                          _buildRoundedDropdown<Equipment>(
                            hint: 'Equipment',
                            value: filterEquipment,
                            items: Equipment.values,
                            onChanged: (val) =>
                                setPickerState(() => filterEquipment = val),
                          ),
                          if (filterMuscle != null ||
                              filterDifficulty != null ||
                              filterEquipment != null) ...[
                            const SizedBox(width: 8),
                            _buildClearButton(
                              onPressed: () {
                                setPickerState(() {
                                  filterMuscle = null;
                                  filterDifficulty = null;
                                  filterEquipment = null;
                                });
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Flexible(
                    child: Container(
                      height: 400,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.withAlpha(50)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: filteredExercises.isEmpty
                          ? const Center(
                              child: Text(
                                'No exercises match your criteria.',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: filteredExercises.length,
                              itemBuilder: (context, index) {
                                final ex = filteredExercises[index];
                                final isSelected = tempSelected.any(
                                  (re) => re.exerciseId == ex.id,
                                );

                                return ListTile(
                                  dense: true,
                                  leading: Checkbox(
                                    value: isSelected,
                                    onChanged: (checked) {
                                      setPickerState(() {
                                        if (checked == true) {
                                          tempSelected.add(
                                            RoutineExercise(
                                              exerciseId: ex.id,
                                              name: ex.name,
                                              sets: 0,
                                              reps: 0,
                                            ),
                                          );
                                        } else {
                                          tempSelected.removeWhere(
                                            (re) => re.exerciseId == ex.id,
                                          );
                                        }
                                      });
                                    },
                                  ),
                                  title: Text(
                                    ex.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  subtitle: Wrap(
                                    spacing: 4,
                                    runSpacing: 4,
                                    children: [
                                      _buildTag(
                                        ex.primaryMuscleGroup.name
                                            .toUpperCase(),
                                        _getMuscleColor(ex.primaryMuscleGroup),
                                      ),
                                      _buildTag(
                                        ex.equipment.name.toUpperCase(),
                                        _getEquipmentColor(ex.equipment),
                                      ),
                                      _buildTag(
                                        ex.difficulty.name.toUpperCase(),
                                        _getDifficultyColor(ex.difficulty),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                ),
                onPressed: () => Navigator.pop(context, tempSelected),
                child: Text(
                  'Done (${tempSelected.length})',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    // Aspetta che l'animazione del dialog finisca prima di distruggere il controller
    Future.delayed(const Duration(milliseconds: 500), () {
      searchController.dispose();
    });
    if (result != null) {
      setState(() {
        _selectedExercises = result;
      });
    }
  }

  Future<void> _saveRoutine() async {
    if (!_formKey.currentState!.validate() || _selectedGoal == null) {
      setState(() => _autoValidate = true);
      _formKey.currentState?.validate();
      return;
    }

    if (_selectedExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one exercise.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    bool exercisesValid = true;
    for (final re in _selectedExercises) {
      if (re.sets <= 0 || re.reps <= 0) exercisesValid = false;
    }
    if (!exercisesValid) {
      setState(() => _autoValidateExercises = true);
      return;
    }

    final newRoutine = Routine(
      id:
          widget.routine?.id ??
          'routine_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text,
      description: _descController.text,
      goal: _selectedGoal!,
      estimatedDurationMinutes: _durationController.text,
      exercises: _selectedExercises,
    );

    await DatabaseHelper.instance.insertRoutine(newRoutine);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.routine != null ? 'Edit Routine' : 'New Routine'),
          actions: [
            TextButton(
              onPressed: _saveRoutine,
              child: const Text(
                'Save',
                style: TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(
                    Icons.view_list_outlined,
                    color: AppColors.accent,
                    size: 20,
                  ),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty)
                    return 'Please enter a routine name';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _descController,
                style: const TextStyle(color: AppColors.textPrimary),
                maxLines: 3,
                minLines: 1,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  labelStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(
                    Icons.description_outlined,
                    color: AppColors.accent,
                    size: 20,
                  ),
                ),
                validator: (v) {
                  return null;
                },
              ),
              const SizedBox(height: 24),
              const Row(
                children: [
                  Icon(
                    Icons.emoji_events_outlined,
                    color: AppColors.accent,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Goal',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: RoutineGoal.values.map((g) {
                  final isSelected = _selectedGoal == g;
                  final color = _getGoalColor(g);
                  return GestureDetector(
                    onTap: () => setState(() => _selectedGoal = g),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.withAlpha(50)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? color : Colors.grey.withAlpha(80),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Text(
                        g.name.toUpperCase(),
                        style: TextStyle(
                          color: isSelected ? color : Colors.grey,
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (_autoValidate && _selectedGoal == null)
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text(
                    'Please select a goal',
                    style: TextStyle(color: Colors.redAccent, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _durationController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Estimated Duration (minutes)',
                  labelStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(
                    Icons.timer_outlined,
                    color: AppColors.accent,
                    size: 20,
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty)
                    return 'Please enter estimated duration';
                  if (int.tryParse(v) == null)
                    return 'Please enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  const Icon(
                    Icons.fitness_center_outlined,
                    color: AppColors.accent,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Exercises (${_selectedExercises.length})',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Rendering degli esercizi molto più staccato e visibile
              ..._selectedExercises.map((re) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white10,
                    ), // Bordo leggero per staccarlo dallo sfondo
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              re.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withAlpha(20),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              iconSize: 18,
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.redAccent,
                              ),
                              tooltip: 'Remove exercise',
                              onPressed: () {
                                setState(() {
                                  _selectedExercises.removeWhere(
                                    (e) => e.exerciseId == re.exerciseId,
                                  );
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              key: ValueKey('${re.exerciseId}_sets'),
                              initialValue: re.sets > 0
                                  ? re.sets.toString()
                                  : '',
                              decoration: InputDecoration(
                                labelText: 'Sets',
                                labelStyle: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                                prefixIcon: const Icon(
                                  Icons.layers_outlined,
                                  size: 16,
                                  color: AppColors.accent,
                                ),
                                isDense: true,
                                filled: true,
                                fillColor: Colors.white.withAlpha(20),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                errorText:
                                    _autoValidateExercises && re.sets <= 0
                                    ? 'Required'
                                    : null,
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (val) => setState(
                                () => re.sets = int.tryParse(val) ?? 0,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              key: ValueKey('${re.exerciseId}_reps'),
                              initialValue: re.reps > 0
                                  ? re.reps.toString()
                                  : '',
                              decoration: InputDecoration(
                                labelText: 'Reps',
                                labelStyle: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                                prefixIcon: const Icon(
                                  Icons.repeat,
                                  size: 16,
                                  color: AppColors.accent,
                                ),
                                isDense: true,
                                filled: true,
                                fillColor: Colors.white.withAlpha(20),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                errorText:
                                    _autoValidateExercises && re.reps <= 0
                                    ? 'Required'
                                    : null,
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (val) => setState(
                                () => re.reps = int.tryParse(val) ?? 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 8),
              Card(
                margin: const EdgeInsets.only(bottom: 24),
                color: AppColors.accent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InkWell(
                  onTap: _showAddExercisesDialog,
                  borderRadius: BorderRadius.circular(16),
                  child: const SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: Icon(Icons.add, color: Colors.black, size: 28),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
