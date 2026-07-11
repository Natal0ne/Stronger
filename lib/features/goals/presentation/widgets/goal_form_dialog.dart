import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronger/core/models/enums.dart';
import 'package:stronger/core/models/goal.dart';
import 'package:stronger/core/theme/enum_theme_extensions.dart';
import 'package:stronger/core/theme/app_colors.dart';
import 'package:stronger/features/goals/presentation/goals_controller.dart';

class GoalFormDialog extends ConsumerStatefulWidget {
  final Goal? goal;

  const GoalFormDialog({super.key, this.goal});

  @override
  ConsumerState<GoalFormDialog> createState() => _GoalFormDialogState();
}

class _GoalFormDialogState extends ConsumerState<GoalFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _startingController;
  late TextEditingController _targetController;
  late TextEditingController _currentController;
  late TextEditingController _notesController;

  GoalCategory _selectedCategory = GoalCategory.strength;
  GoalStatus _selectedStatus = GoalStatus.active;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _autoValidate = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.goal?.title);
    _descController = TextEditingController(text: widget.goal?.description);
    _startingController = TextEditingController(
      text: widget.goal?.startingValue.toString() ?? '85',
    );
    _targetController = TextEditingController(
      text: widget.goal?.targetValue.toString() ?? '75',
    );
    _currentController = TextEditingController(
      text: widget.goal?.currentValue.toString() ?? '85',
    );
    _notesController = TextEditingController(text: widget.goal?.notes);

    if (widget.goal != null) {
      _selectedCategory = widget.goal!.category;
      _selectedStatus = widget.goal!.status;
      _startDate = widget.goal!.startDate;
      _endDate = widget.goal!.endDate;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _startingController.dispose();
    _targetController.dispose();
    _currentController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      title: Text(
        widget.goal != null ? 'Edit Goal' : 'New Goal',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
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
                  controller: _titleController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Goal Title',
                    prefixIcon: Icon(
                      Icons.emoji_events,
                      color: AppColors.accent,
                    ),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Please enter a title'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    prefixIcon: Icon(
                      Icons.description,
                      color: AppColors.accent,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  'Category',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: GoalCategory.values.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    final color = cat.color; 
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat),
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
                          cat.label.toUpperCase(),
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
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _startingController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Start',
                          labelStyle: TextStyle(fontSize: 12),
                        ),
                        validator: (v) =>
                            (v == null || double.tryParse(v) == null)
                            ? 'Required'
                            : null,
                        onChanged: (val) {
                          if (widget.goal == null &&
                              double.tryParse(val) != null) {
                            _currentController.text = val;
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _currentController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Current',
                          labelStyle: TextStyle(fontSize: 12),
                        ),
                        validator: (v) =>
                            (v == null || double.tryParse(v) == null)
                            ? 'Required'
                            : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _targetController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Target',
                          labelStyle: TextStyle(fontSize: 12),
                        ),
                        validator: (v) =>
                            (v == null || double.tryParse(v) == null)
                            ? 'Required'
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.calendar_month,
                    color: AppColors.accent,
                  ),
                  title: const Text(
                    'Deadline (Optional)',
                    style: TextStyle(fontSize: 14),
                  ),
                  subtitle: Text(
                    _endDate != null
                        ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                        : 'No deadline set',
                  ),
                  trailing: TextButton(
                    onPressed: _selectEndDate,
                    child: const Text(
                      'Set Date',
                      style: TextStyle(color: AppColors.accent),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                if (widget.goal != null) ...[
                  const Text(
                    'Status',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: GoalStatus.values.map((stat) {
                      final isSelected = _selectedStatus == stat;
                      final color = stat.color; 
                      return GestureDetector(
                        onTap: () => setState(() => _selectedStatus = stat),
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
                            stat.name.toUpperCase(),
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
                  const SizedBox(height: 16),
                ],

                TextFormField(
                  controller: _notesController,
                  maxLines: 2,
                  minLines: 1,
                  decoration: const InputDecoration(
                    labelText: 'Optional Notes',
                    prefixIcon: Icon(
                      Icons.notes_outlined,
                      color: AppColors.accent,
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
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
          onPressed: () {
            if (!_formKey.currentState!.validate() ||
                _selectedCategory == null ||
                _selectedStatus == null) {
              setState(() => _autoValidate = true);
              _formKey.currentState!.validate();
              return;
            }

            final wasCompleted = widget.goal?.status == GoalStatus.completed;
            final isCompletedNow = _selectedStatus == GoalStatus.completed;
            if (!wasCompleted && isCompletedNow) {
              HapticFeedback.vibrate();
            }

            final newGoal = Goal(
              id:
                  widget.goal?.id ??
                  DateTime.now().millisecondsSinceEpoch.toString(),
              title: _titleController.text.trim(),
              description: _descController.text.trim(),
              category: _selectedCategory,
              startingValue: double.parse(_startingController.text),
              currentValue: double.parse(_currentController.text),
              targetValue: double.parse(_targetController.text),
              startDate: _startDate,
              endDate: _endDate,
              status: widget.goal != null ? _selectedStatus : GoalStatus.active,
              notes: _notesController.text.trim(),
            );

            ref.read(goalsProvider.notifier).addGoal(newGoal);
            Navigator.pop(context);
          },
          child: const Text(
            'Save',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}