import 'package:flutter/material.dart';
import 'package:stronger/core/models/exercise_set.dart';
import 'package:stronger/core/theme/app_colors.dart';

class SetRow extends StatelessWidget {
  final int setIndex;
  final ExerciseSet set;
  final ExerciseSet? previousSet;
  final int exerciseRecommendedReps;
  final VoidCallback onRemove;
  final void Function({int? reps, double? weightKg, bool? isCompleted})
  onUpdate;

  const SetRow({
    super.key,
    required this.setIndex,
    required this.set,
    this.previousSet,
    required this.exerciseRecommendedReps,
    required this.onRemove,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final isPR =
    set.isCompleted &&
    previousSet != null &&
    (set.weightKg > previousSet!.weightKg ||
    (set.weightKg == previousSet!.weightKg &&
    set.reps > previousSet!.reps));

    return TweenAnimationBuilder<double>(
      key: ValueKey(set.isCompleted),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutBack,
      tween: Tween<double>(begin: 0.94, end: 1.0),
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: set.isCompleted
          ? Colors.green[900]!.withOpacity(
            0.45,
          )
          : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '${set.setNumber}',
                    style: TextStyle(
                      color: set.isCompleted
                      ? Colors.greenAccent
                      : AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  if (isPR) ...[
                    const SizedBox(height: 2),
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutBack,
                      tween: Tween<double>(begin: 0.0, end: 1.0),
                      builder: (context, scale, child) {
                        return Transform.scale(scale: scale, child: child);
                      },
                      child: const Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                        size: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _NumberField(
                key: ValueKey('weight_${set.setNumber}_$setIndex'),
                label: 'Weight',
                icon: Icons.fitness_center_outlined,
                value: set.weightKg,
                hintValue: previousSet?.weightKg,
                isCompleted: set.isCompleted,
                onChanged: (v) => onUpdate(weightKg: v),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _NumberField(
                key: ValueKey('reps_${set.setNumber}_$setIndex'),
                label: 'Reps',
                icon: Icons.repeat,
                value: set.reps.toDouble(),
                hintValue: previousSet != null
                ? previousSet!.reps.toDouble()
                : exerciseRecommendedReps.toDouble(),
                isInt: true,
                isCompleted: set.isCompleted,
                onChanged: (v) => onUpdate(reps: v.round()),
              ),
            ),
            const SizedBox(width: 10),
            _CompletionToggle(
              isCompleted: set.isCompleted,
              onChanged: (v) => onUpdate(isCompleted: v),
            ),
          ],
        ),
      ),
    );
  }
}

class _NumberField extends StatefulWidget {
  final String label;
  final double value;
  final double? hintValue;
  final IconData icon;
  final bool isInt;
  final bool isCompleted;
  final void Function(double) onChanged;

  const _NumberField({
    super.key,
    required this.label,
    required this.value,
    this.hintValue,
    required this.icon,
    required this.onChanged,
    this.isCompleted = false,
    this.isInt = false,
  });

  @override
  State<_NumberField> createState() => _NumberFieldState();
}

class _NumberFieldState extends State<_NumberField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _formatValue(widget.value));
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(_NumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final currentTextVal =
    double.tryParse(_controller.text.replaceAll(',', '.')) ?? 0.0;

    final justCompleted = widget.isCompleted && !oldWidget.isCompleted;
    if (justCompleted ||
      (oldWidget.value != widget.value &&
      !_focusNode.hasFocus &&
      currentTextVal != widget.value)) {
      _controller.text = _formatValue(widget.value);
      }
  }

  String _formatValue(double val) {
    if (val <= 0) return '';
    if (val == val.roundToDouble()) {
      return val.round().toString();
    }
    return val.toString().replaceAll('.', ',');
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasHint = widget.hintValue != null && widget.hintValue! > 0;
    final hintTextStr = hasHint
    ? (widget.isInt
    ? widget.hintValue!.round().toString()
    : widget.hintValue!.toString().replaceAll('.', ','))
    : widget.label;

    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      enabled: !widget.isCompleted,
      keyboardType: TextInputType.numberWithOptions(decimal: !widget.isInt),
      style: TextStyle(
        color: widget.isCompleted ? Colors.greenAccent : AppColors.textPrimary,
        fontSize: 13,
        fontWeight: widget.isCompleted ? FontWeight.bold : FontWeight.normal,
      ),
      onTap: () {
        if (widget.value == 0) {
          _controller.clear();
        }
      },
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: TextStyle(
          fontSize: 11,
          color: widget.isCompleted
          ? Colors.greenAccent.withOpacity(0.6)
          : Colors.grey,
        ),
        hintText: hasHint ? hintTextStr : null,
        hintStyle: const TextStyle(
          color: Colors.white24,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        prefixIcon: Icon(
          widget.icon,
          size: 14,
          color: widget.isCompleted ? Colors.greenAccent : AppColors.accent,
        ),
        isDense: true,
        filled: true,
        fillColor: widget.isCompleted
        ? Colors.greenAccent.withOpacity(0.18)
        : Colors.white.withAlpha(20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: (text) {
        final normalizedText = text.replaceAll(',', '.');
        widget.onChanged(double.tryParse(normalizedText) ?? 0);
      },
    );
  }
}

class _CompletionToggle extends StatelessWidget {
  final bool isCompleted;
  final ValueChanged<bool> onChanged;

  const _CompletionToggle({required this.isCompleted, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: Material(
        color: isCompleted ? Colors.greenAccent : Colors.white.withAlpha(15),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onChanged(!isCompleted),
          child: Icon(
            isCompleted ? Icons.check_rounded : Icons.check_outlined,
            color: isCompleted ? Colors.black : Colors.grey,
            size: 20,
          ),
        ),
      ),
    );
  }
}
