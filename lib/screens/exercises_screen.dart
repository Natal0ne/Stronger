import 'package:flutter/material.dart';
import 'package:stronger/models/exercise.dart';
import 'package:stronger/models/enums.dart';
import 'package:stronger/services/database_helper.dart';
import 'package:stronger/theme/app_colors.dart';

class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key});

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  List<Exercise> _allExercises = [];
  List<Exercise> _filteredExercises = [];
  bool _isLoading = true;

  final TextEditingController _searchController = TextEditingController();
  MuscleGroup? _filterMuscle;
  Difficulty? _filterDifficulty;
  Equipment? _filterEquipment;

  @override
  void initState() {
    super.initState();
    _loadExercises();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadExercises() async {
    setState(() => _isLoading = true);
    try {
      final exercises = await DatabaseHelper.instance.getExercises();
      setState(() {
        _allExercises = exercises;
        _isLoading = false;
      });
      _applyFilters();
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading exercises: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredExercises = _allExercises.where((exercise) {
        final matchesSearch =
            exercise.name.toLowerCase().contains(query) ||
            exercise.description.toLowerCase().contains(query);
        final matchesMuscle =
            _filterMuscle == null ||
            exercise.primaryMuscleGroup == _filterMuscle;
        final matchesDifficulty =
            _filterDifficulty == null ||
            exercise.difficulty == _filterDifficulty;
        final matchesEquipment =
            _filterEquipment == null || exercise.equipment == _filterEquipment;

        return matchesSearch &&
            matchesMuscle &&
            matchesDifficulty &&
            matchesEquipment;
      }).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _filterMuscle = null;
      _filterDifficulty = null;
      _filterEquipment = null;
    });
    _applyFilters();
  }

  Color _getDifficultyColor(Difficulty level) {
    switch (level) {
      case Difficulty.beginner:
        return Colors.greenAccent;
      case Difficulty.intermediate:
        return Colors.orangeAccent;
      case Difficulty.advanced:
        return Colors.redAccent;
    }
  }

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
    }
  }

  Color _getMuscleColor(MuscleGroup muscle) {
    return AppColors.accent;
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
      height: 36, // Altezza fissa per occupare meno spazio
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

  // Tasto Clear personalizzato, allineato verticalmente con i Dropdown
  Widget _buildClearButton({required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 36, // Stessa identica altezza dei dropdown
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.redAccent.withAlpha(20),
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: const Text(
          'Clear',
          style: TextStyle(
            color: Colors.redAccent,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showExerciseDetails(Exercise exercise) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.65,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    exercise.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: AppColors.accent,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _showNewExerciseDialog(exercise);
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete Exercise'),
                        content: Text(
                          'Are you sure you want to delete "${exercise.name}"? This will also remove it from any routines using it.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                            ),
                            onPressed: () async {
                              await DatabaseHelper.instance.deleteExercise(
                                exercise.id,
                              );
                              _loadExercises();
                              if (ctx.mounted) Navigator.pop(ctx);
                              if (context.mounted) Navigator.pop(context);
                            },
                            child: const Text(
                              'Delete',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _buildTag(
                  exercise.primaryMuscleGroup.name.toUpperCase(),
                  _getMuscleColor(exercise.primaryMuscleGroup),
                ),
                _buildTag(
                  exercise.equipment.name.toUpperCase(),
                  _getEquipmentColor(exercise.equipment),
                ),
                _buildTag(
                  exercise.difficulty.name.toUpperCase(),
                  _getDifficultyColor(exercise.difficulty),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Recommended Reps',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${exercise.recommendedReps} Reps',
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Description / Instructions',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.description,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                    if (exercise.notes.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      const Text(
                        'Notes',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        exercise.notes,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNewExerciseDialog([Exercise? exercise]) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: exercise?.name);
    final descriptionController = TextEditingController(
      text: exercise?.description,
    );
    final repsController = TextEditingController(
      text: exercise != null ? exercise.recommendedReps.toString() : '',
    );
    final notesController = TextEditingController(text: exercise?.notes);

    MuscleGroup? selectedMuscle = exercise?.primaryMuscleGroup;
    Difficulty? selectedDifficulty = exercise?.difficulty;
    Equipment? selectedEquipment = exercise?.equipment;
    bool autoValidate = false;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          title: Text(
            exercise != null ? 'Edit Exercise' : 'New Exercise',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: nameController,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        labelText: 'Exercise Name',
                        labelStyle: TextStyle(color: Colors.grey),
                        prefixIcon: Icon(
                          Icons.fitness_center,
                          color: AppColors.accent,
                          size: 20,
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return 'Please enter an exercise name';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: descriptionController,
                      style: const TextStyle(color: AppColors.textPrimary),
                      maxLines: 3,
                      minLines: 1,
                      decoration: const InputDecoration(
                        labelText: 'Description / Instructions',
                        labelStyle: TextStyle(color: Colors.grey),
                        prefixIcon: Icon(
                          Icons.description_outlined,
                          color: AppColors.accent,
                          size: 20,
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return 'Please enter description/instructions';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    const Row(
                      children: [
                        Icon(
                          Icons.category_outlined,
                          color: AppColors.accent,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Classification',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Muscle Group',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: MuscleGroup.values.map((type) {
                        final isSelected = selectedMuscle == type;
                        final color = _getMuscleColor(type);
                        return GestureDetector(
                          onTap: () =>
                              setDialogState(() => selectedMuscle = type),
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
                                color: isSelected
                                    ? color
                                    : Colors.grey.withAlpha(80),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Text(
                              type.name.toUpperCase(),
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
                    if (autoValidate && selectedMuscle == null)
                      const Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: Text(
                          'Please select a muscle group',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    const Text(
                      'Difficulty',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: Difficulty.values.map((level) {
                        final isSelected = selectedDifficulty == level;
                        final color = _getDifficultyColor(level);
                        return GestureDetector(
                          onTap: () =>
                              setDialogState(() => selectedDifficulty = level),
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
                                color: isSelected
                                    ? color
                                    : Colors.grey.withAlpha(80),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Text(
                              level.name.toUpperCase(),
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
                    if (autoValidate && selectedDifficulty == null)
                      const Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: Text(
                          'Please select a difficulty level',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    const Text(
                      'Equipment',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: Equipment.values.map((tool) {
                        final isSelected = selectedEquipment == tool;
                        final color = _getEquipmentColor(tool);
                        return GestureDetector(
                          onTap: () =>
                              setDialogState(() => selectedEquipment = tool),
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
                                color: isSelected
                                    ? color
                                    : Colors.grey.withAlpha(80),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Text(
                              tool.name.toUpperCase(),
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
                    if (autoValidate && selectedEquipment == null)
                      const Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: Text(
                          'Please select required equipment',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                    const Row(
                      children: [
                        Icon(
                          Icons.tune_outlined,
                          color: AppColors.accent,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Details',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: repsController,
                      style: const TextStyle(color: AppColors.textPrimary),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Recommended Reps',
                        labelStyle: TextStyle(color: Colors.grey),
                        prefixIcon: Icon(
                          Icons.repeat,
                          color: AppColors.accent,
                          size: 20,
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return 'Please enter recommended reps';
                        if (int.tryParse(v) == null)
                          return 'Please enter a valid number';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: notesController,
                      style: const TextStyle(color: AppColors.textPrimary),
                      maxLines: 2,
                      minLines: 1,
                      decoration: const InputDecoration(
                        labelText: 'Optional Notes',
                        labelStyle: TextStyle(color: Colors.grey),
                        prefixIcon: Icon(
                          Icons.notes_outlined,
                          color: AppColors.accent,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
              ),
              onPressed: () async {
                if (!formKey.currentState!.validate() ||
                    selectedMuscle == null ||
                    selectedDifficulty == null ||
                    selectedEquipment == null) {
                  setDialogState(() => autoValidate = true);
                  formKey.currentState!.validate();
                  return;
                }

                final reps = int.parse(repsController.text);
                final newExercise = Exercise(
                  id:
                      exercise?.id ??
                      DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text,
                  description: descriptionController.text,
                  primaryMuscleGroup: selectedMuscle!,
                  difficulty: selectedDifficulty!,
                  equipment: selectedEquipment!,
                  recommendedReps: reps,
                  notes: notesController.text,
                );

                await DatabaseHelper.instance.insertExercise(newExercise);
                _loadExercises();
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text(
                'Save',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    nameController.dispose();
    descriptionController.dispose();
    repsController.dispose();
    notesController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasActiveFilters =
        _filterMuscle != null ||
        _filterDifficulty != null ||
        _filterEquipment != null ||
        _searchController.text.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Exercises',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'exercises_fab',
        onPressed: _showNewExerciseDialog,
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search exercise or descriptions...',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: AppColors.accent),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Filtri orizzontali scorrevoli su riga singola (occupano meno spazio)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildRoundedDropdown<MuscleGroup>(
                    hint: 'Muscle',
                    value: _filterMuscle,
                    items: MuscleGroup.values,
                    onChanged: (val) {
                      setState(() => _filterMuscle = val);
                      _applyFilters();
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildRoundedDropdown<Difficulty>(
                    hint: 'Difficulty',
                    value: _filterDifficulty,
                    items: Difficulty.values,
                    onChanged: (val) {
                      setState(() => _filterDifficulty = val);
                      _applyFilters();
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildRoundedDropdown<Equipment>(
                    hint: 'Equipment',
                    value: _filterEquipment,
                    items: Equipment.values,
                    onChanged: (val) {
                      setState(() => _filterEquipment = val);
                      _applyFilters();
                    },
                  ),
                  if (hasActiveFilters) ...[
                    const SizedBox(width: 8),
                    _buildClearButton(onPressed: _clearFilters),
                  ],
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: Colors.white10),

          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.accent),
                  )
                : _filteredExercises.isEmpty
                ? Center(
                    child: Text(
                      hasActiveFilters
                          ? 'No exercises match your criteria.'
                          : 'No exercises saved yet.\nTap the + button to add one!',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 15,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredExercises.length,
                    itemBuilder: (context, index) {
                      final ex = _filteredExercises[index];
                      final diffColor = _getDifficultyColor(ex.difficulty);
                      final equipColor = _getEquipmentColor(ex.equipment);

                      return Card(
                        color: Theme.of(context).colorScheme.surfaceContainer,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          onTap: () => _showExerciseDetails(ex),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          title: Text(
                            ex.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ex.description,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 7,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.accent.withAlpha(25),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        ex.primaryMuscleGroup.name
                                            .toUpperCase(),
                                        style: const TextStyle(
                                          color: AppColors.accent,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 7,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: equipColor.withAlpha(25),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        ex.equipment.name.toUpperCase(),
                                        style: TextStyle(
                                          color: equipColor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 7,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: diffColor.withAlpha(25),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        ex.difficulty.name.toUpperCase(),
                                        style: TextStyle(
                                          color: diffColor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (ex.notes.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Notes: ${ex.notes}',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
