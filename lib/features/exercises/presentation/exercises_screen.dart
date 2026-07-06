import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:stronger/core/theme/app_colors.dart';
import 'package:stronger/core/models/enums.dart';
import 'package:stronger/core/theme/enum_theme_extensions.dart';
import 'package:stronger/features/sessions/presentation/sessions_controller.dart';

// I provider di Riverpod e i widget dei dettagli
import 'exercises_controller.dart';
import 'widgets/exercise_form_dialog.dart';
import 'widgets/exercise_details_sheet.dart';

class ExercisesScreen extends ConsumerWidget {
  const ExercisesScreen({super.key});

  // --- Helper dei Colori originali ---
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

  // --- Costruttore dei Dropdown arrotondati (PULITI SENZA BORDI) ---
  Widget _buildRoundedDropdown<T extends Enum>({
    required BuildContext context,
    required String hint,
    required T? value,
    required List<T> items,
    required void Function(T?) onChanged,
  }) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        // Sfondo leggermente più chiaro per staccare dal fondo nero (0.08 di opacità bianca)
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(hint, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          dropdownColor: Theme.of(context).colorScheme.surfaceContainerHigh,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500),
          borderRadius: BorderRadius.circular(16),
          icon: const Padding(
            padding: EdgeInsets.only(left: 6),
            child: Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.grey),
          ),
          items: items.map((e) => DropdownMenuItem<T>(value: e, child: Text(e.name.toUpperCase()))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // --- Tasto Clear personalizzato ---
  Widget _buildClearButton({required VoidCallback onPressed}) {
    return InkWell(
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
        child: const Icon(Icons.filter_alt_off, color: Colors.redAccent, size: 18),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredExercisesState = ref.watch(filteredExercisesProvider);

    final currentMuscle = ref.watch(muscleFilterProvider);
    final currentDifficulty = ref.watch(difficultyFilterProvider);
    final currentEquipment = ref.watch(equipmentFilterProvider);
    final searchControllerText = ref.watch(searchFilterProvider);

    final hasActiveFilters = currentMuscle != null ||
    currentDifficulty != null ||
    currentEquipment != null ||
    searchControllerText.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercises', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      ),
      floatingActionButton: Padding(
        // Sposta il pulsante + sù di 60px se c'è un workout attivo!
        padding: EdgeInsets.only(
          bottom: ref.watch(activeWorkoutProvider) != null ? 60.0 : 0.0,
        ),
        child: FloatingActionButton(
          heroTag: 'exercises_fab',
          onPressed: () {
            HapticFeedback.lightImpact();
            // Mostra il tuo dialog di creazione esercizio
            showDialog(
              context: context,
              builder: (_) => const ExerciseFormDialog(), // Assicurati che l'import del tuo dialog sia corretto in cima
            );
          },
          backgroundColor: AppColors.accent,
          child: const Icon(Icons.add),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // BARRA DI RICERCA SENZA BORDO E COERENTE AI FILTRI (fillColor = white.withOpacity(0.08))
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              onChanged: (value) => ref.read(searchFilterProvider.notifier).state = value,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search exercise or descriptions...',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: searchControllerText.isNotEmpty
                ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () => ref.read(searchFilterProvider.notifier).state = '',
                )
                : null,
                filled: true,
                fillColor: Colors.white.withOpacity(0.08), // <--- ORA AGGIORNATO E COERENTE AI FILTRI!
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // FILTRI ORIZZONTALI SCORREVOLI PULITI (SENZA BORDO)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildRoundedDropdown<MuscleGroup>(
                    context: context,
                    hint: 'Muscle',
                    value: currentMuscle,
                    items: MuscleGroup.values,
                    onChanged: (val) => ref.read(muscleFilterProvider.notifier).state = val,
                  ),
                  const SizedBox(width: 8),
                  _buildRoundedDropdown<Difficulty>(
                    context: context,
                    hint: 'Difficulty',
                    value: currentDifficulty,
                    items: Difficulty.values,
                    onChanged: (val) => ref.read(difficultyFilterProvider.notifier).state = val,
                  ),
                  const SizedBox(width: 8),
                  _buildRoundedDropdown<Equipment>(
                    context: context,
                    hint: 'Equipment',
                    value: currentEquipment,
                    items: Equipment.values,
                    onChanged: (val) => ref.read(equipmentFilterProvider.notifier).state = val,
                  ),
                  if (hasActiveFilters) ...[
                    const SizedBox(width: 8),
                    _buildClearButton(onPressed: () {
                      ref.read(searchFilterProvider.notifier).state = '';
                    ref.read(muscleFilterProvider.notifier).state = null;
                  ref.read(difficultyFilterProvider.notifier).state = null;
                  ref.read(equipmentFilterProvider.notifier).state = null;
                    }),
                  ],
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: Colors.white10),

          // LISTA CON CARDS DETTAGLIATE
          Expanded(
            child: filteredExercisesState.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accent)),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (exercises) {
                if (exercises.isEmpty) {
                  return Center(
                    child: Text(
                      hasActiveFilters
                      ? 'No exercises match your criteria.'
                    : 'No exercises saved yet.\nTap the + button to add one!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 15),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: exercises.length,
                  itemBuilder: (context, index) {
                    final ex = exercises[index];
                    final diffColor = ex.difficulty.color;
                    final equipColor = ex.equipment.color;

                    return Card(
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => ExerciseDetailsSheet(exercise: ex),
                          );
                        },
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        title: Text(
                          ex.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 16),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ex.description, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 6, runSpacing: 4,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.accent.withAlpha(25),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      ex.primaryMuscleGroup.name.toUpperCase(),
                                      style: const TextStyle(color: AppColors.accent, fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                   Container(
                                     padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                     decoration: BoxDecoration(
                                       color: equipColor.withAlpha(25),
                                       borderRadius: BorderRadius.circular(4),
                                     ),
                                     child: Text(
                                       ex.equipment.name.toUpperCase(),
                                       style: TextStyle(color: equipColor, fontSize: 10, fontWeight: FontWeight.bold),
                                     ),
                                   ),
                                   Container(
                                     padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                     decoration: BoxDecoration(
                                       color: diffColor.withAlpha(25),
                                       borderRadius: BorderRadius.circular(4),
                                     ),
                                     child: Text(
                                       ex.difficulty.name.toUpperCase(),
                                       style: TextStyle(color: diffColor, fontSize: 10, fontWeight: FontWeight.bold),
                                     ),
                                   ),
                                ],
                              ),
                              if (ex.notes.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Notes: ${ex.notes}',
                                  style: const TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic),
                                ),
                              ],
                            ],
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
