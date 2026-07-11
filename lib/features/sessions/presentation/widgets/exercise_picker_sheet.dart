import 'package:flutter/material.dart';
import 'package:stronger/core/models/enums.dart';
import 'package:stronger/core/models/exercise.dart';
import 'package:stronger/core/theme/app_colors.dart';
import 'package:stronger/core/theme/enum_theme_extensions.dart';
import 'package:stronger/features/sessions/presentation/sessions_controller.dart';

class ExercisePickerSheet extends StatefulWidget {
  final List<Exercise> availableExercises;
  final List<PerformedExerciseDraft> alreadyPerformed;

  const ExercisePickerSheet({
    super.key,
    required this.availableExercises,
    required this.alreadyPerformed,
  });

  @override
  State<ExercisePickerSheet> createState() => _ExercisePickerSheetState();
}

class _ExercisePickerSheetState extends State<ExercisePickerSheet> {
  final _searchController = TextEditingController();
  MuscleGroup? _filterMuscle;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.toLowerCase();
    final filtered = widget.availableExercises.where((ex) {
      final alreadyAdded = widget.alreadyPerformed.any((p) => p.exercise.id == ex.id);
      if (alreadyAdded) return false;
      final matchesSearch = ex.name.toLowerCase().contains(query) || ex.description.toLowerCase().contains(query);
      final matchesMuscle = _filterMuscle == null || ex.primaryMuscleGroup == _filterMuscle;
      return matchesSearch && matchesMuscle;
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Row(
              children: [
                const Expanded(
                  child: Text('Add Exercise', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: AppColors.textPrimary),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search exercises...',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: AppColors.accent),
                suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () => setState(() => _searchController.clear()),
                )
                : null,
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                for (var muscle in MuscleGroup.values) ...[
                  GestureDetector(
                    onTap: () => setState(() => _filterMuscle = _filterMuscle == muscle ? null : muscle),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _filterMuscle == muscle ? AppColors.accent.withValues(alpha: 0.15) : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _filterMuscle == muscle ? AppColors.accent : Colors.grey.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        muscle.name.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _filterMuscle == muscle ? AppColors.accent : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: Colors.white10),
          Expanded(
            child: filtered.isEmpty
            ? const Center(child: Text('No matching exercises found.', style: TextStyle(color: AppColors.textSecondary)))
            : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final ex = filtered[index];
                return Card(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    title: Text(ex.name, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Wrap(
                        spacing: 6, runSpacing: 4,
                        children: [
                          _buildTag(ex.primaryMuscleGroup.name, AppColors.accent),
                          _buildTag(ex.equipment.name, ex.equipment.color),
                          _buildTag(ex.difficulty.name, ex.difficulty.color),
                        ],
                      ),
                    ),
                    trailing: const Icon(Icons.add_circle_outline, color: AppColors.accent),
                    onTap: () => Navigator.of(context).pop(ex),
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
