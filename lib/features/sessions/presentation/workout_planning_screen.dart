import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronger/core/models/enums.dart';
import 'package:stronger/core/models/recurring_schedule.dart';
import 'package:stronger/core/models/routine.dart';
import 'package:stronger/core/models/workout_session.dart';
import 'package:stronger/core/theme/app_colors.dart';
import 'package:stronger/core/theme/enum_theme_extensions.dart';
import 'package:stronger/features/routines/data/routine_repository.dart';
import 'package:stronger/features/sessions/data/session_repository.dart';
import 'package:stronger/features/sessions/presentation/sessions_controller.dart';

class WorkoutPlanningScreen extends ConsumerStatefulWidget {
  const WorkoutPlanningScreen({super.key});

  @override
  ConsumerState<WorkoutPlanningScreen> createState() => _WorkoutPlanningScreenState();
}

class _WorkoutPlanningScreenState extends ConsumerState<WorkoutPlanningScreen> {
  late DateTime _weekStart;
  List<Routine> _routines = [];
  List<WorkoutSession> _scheduledSessions = [];
  List<RecurringSchedule> _recurringSchedules = [];
  bool _loading = true;

  static const _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    _weekStart = _startOfWeek(DateTime.now());
    _loadData();
  }

  DateTime _startOfWeek(DateTime date) {
    return DateTime(date.year, date.month, date.day - (date.weekday - 1));
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final sessionRepo = ref.read(sessionRepositoryProvider);
    final routineRepo = ref.read(routineRepositoryProvider);

    await sessionRepo.ensureRecurringSessionsForWeek(_weekStart);
    final routines = await routineRepo.getRoutines();
    final scheduled = await sessionRepo.getScheduledSessionsForWeek(_weekStart);
    final recurring = await sessionRepo.getRecurringSchedules();

    if (!mounted) return;
    setState(() {
      _routines = routines;
      _scheduledSessions = scheduled;
      _recurringSchedules = recurring;
      _loading = false;
    });
  }

  void _changeWeek(int delta) {
    setState(() {
      _weekStart = _weekStart.add(Duration(days: 7 * delta));
    });
    _loadData();
  }

  WorkoutSession? _sessionForDay(DateTime day) {
    for (var session in _scheduledSessions) {
      if (_isSameDay(session.date, day)) return session;
    }
    return null;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _weekRangeLabel() {
    final weekEnd = _weekStart.add(const Duration(days: 6));
    return '${_weekStart.day}/${_weekStart.month} – ${weekEnd.day}/${weekEnd.month}';
  }

  RecurringSchedule? _recurringForDay(DateTime day) {
    for (var schedule in _recurringSchedules) {
      if (schedule.weekday == day.weekday) return schedule;
    }
    return null;
  }

  Future<void> _planDay(DateTime day) async {
    final existing = _sessionForDay(day);
    final recurring = _recurringForDay(day);

    final result = await showModalBottomSheet<_PlanPickerResult>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _RoutinePickerSheet(
        routines: _routines,
        selectedRoutineId: existing?.routineId ?? recurring?.routineId,
        repeatWeekly: recurring != null,
        dayLabel: _dayLabels[day.weekday - 1],
      ),
    );

    if (!mounted || result == null) return;

    final sessionRepo = ref.read(sessionRepositoryProvider);

    if (result.clearExisting) {
      if (existing != null) {
        await sessionRepo.deleteWorkoutSession(existing.id);
      }
      await sessionRepo.deleteRecurringScheduleForWeekday(day.weekday);

      ref.invalidate(scheduledSessionsProvider);
      ref.invalidate(historySessionsProvider);

      _loadData();
      return;
    }

    final selectedRoutine = result.routine;
    if (selectedRoutine == null) return;

    final duration = int.tryParse(
      selectedRoutine.estimatedDurationMinutes.replaceAll(RegExp(r'[^0-9]'), ''),
    ) ?? 45;

    if (result.repeatWeekly) {
      await sessionRepo.upsertRecurringSchedule(
        RecurringSchedule(
          id: 'recur_${day.weekday}',
          routineId: selectedRoutine.id,
          weekday: day.weekday,
          title: selectedRoutine.name,
          durationMinutes: duration,
          notes: selectedRoutine.description,
        ),
      );
    } else {
      await sessionRepo.deleteRecurringScheduleForWeekday(day.weekday);
    }

    final session = WorkoutSession(
      id: existing?.id ?? 'sched_${DateTime.now().millisecondsSinceEpoch}',
      title: selectedRoutine.name,
      date: DateTime(day.year, day.month, day.day, 8),
      routineId: selectedRoutine.id,
      performedExercises: const [],
      durationMinutes: duration,
      status: WorkoutStatus.scheduled,
      notes: selectedRoutine.description,
    );

    await sessionRepo.insertWorkoutSession(session);

    ref.invalidate(scheduledSessionsProvider);
    ref.invalidate(historySessionsProvider);

    _loadData();
  }

  Future<void> _removeSession(WorkoutSession session) async {
    final recurring = _recurringForDay(session.date);
    final isRecurring = recurring != null;

    if (isRecurring) {
      HapticFeedback.heavyImpact();
      final result = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          title: const Text('Remove repeating workout?', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text('"${session.title}" repeats every week. How would you like to remove it?'),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () => Navigator.pop(context, 'cancel'),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),

                TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    Navigator.pop(context, 'stop_repeat');
                  },
                  child: const Text(
                    'Stop All',
                    style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                  ),
                ),

                TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context, 'only_this');
                  },
                  child: const Text(
                    'Only This',
                    style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      );

      if (result == null || result == 'cancel') return;

      final sessionRepo = ref.read(sessionRepositoryProvider);

      if (result == 'only_this') {
        await sessionRepo.deleteWorkoutSession(session.id);
      } else if (result == 'stop_repeat') {
        await sessionRepo.deleteWorkoutSession(session.id);
        await sessionRepo.deleteRecurringScheduleForWeekday(session.date.weekday);
      }

    } else {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          title: const Text('Remove planned session?'),
          content: Text('Remove "${session.title}" from your plan?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Remove', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        ),
      );

      if (confirmed != true) return;
      await ref.read(sessionRepositoryProvider).deleteWorkoutSession(session.id);
    }

    ref.invalidate(scheduledSessionsProvider);
    ref.invalidate(historySessionsProvider);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan Your Week', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      ),
      body: _loading
      ? const Center(child: CircularProgressIndicator())
      : Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => _changeWeek(-1)),
                Column(
                  children: [
                    Text(_weekRangeLabel(), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 16)),
                    const Text('Tap a day to assign a routine', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
                IconButton(icon: const Icon(Icons.chevron_right), onPressed: () => _changeWeek(1)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 7,
              itemBuilder: (context, index) {
                final day = _weekStart.add(Duration(days: index));
                final session = _sessionForDay(day);
                final isToday = _isSameDay(day, DateTime.now());
                Routine? matchedRoutine;
                for (var r in _routines) {
                  if (r.id == session?.routineId) {
                    matchedRoutine = r;
                    break;
                  }
                }
                final goalColor = matchedRoutine != null ? matchedRoutine.goal.color : null;
                final recurring = _recurringForDay(day);

                return _DayPlanCard(
                  dayLabel: _dayLabels[index],
                  dayNumber: day.day,
                  monthLabel: _monthShort(day.month),
                  isToday: isToday,
                  session: session,
                  isRecurring: recurring != null,
                  goalColor: session != null && session.status != WorkoutStatus.skipped ? goalColor : null,
                  onTap: () => _planDay(day),
                  onRemove: session != null ? () => _removeSession(session) : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _monthShort(int month) {
    const names = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return names[month - 1];
  }
}

class _DayPlanCard extends StatelessWidget {
  final String dayLabel;
  final int dayNumber;
  final String monthLabel;
  final bool isToday;
  final WorkoutSession? session;
  final bool isRecurring;
  final Color? goalColor;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  const _DayPlanCard({
    required this.dayLabel,
    required this.dayNumber,
    required this.monthLabel,
    required this.isToday,
    required this.session,
    required this.isRecurring,
    required this.goalColor,
    required this.onTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final hasPlan = session != null;
    final isSkipped = session?.status == WorkoutStatus.skipped;

    return Card(
      color: Theme.of(context).colorScheme.surfaceContainer,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isToday ? const BorderSide(color: AppColors.accent, width: 1.5) : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  color: isToday ? AppColors.accent.withAlpha(40) : Colors.white.withAlpha(15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      dayLabel.toUpperCase(),
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isToday ? AppColors.accent : AppColors.textSecondary),
                    ),
                    Text(
                      '$dayNumber',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isToday ? AppColors.accent : AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasPlan && !isSkipped) ...[
                      Text(session!.title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      const SizedBox(height: 4),
                      Text(
                        '${session!.durationMinutes} min · ${session!.status.name}${isRecurring ? ' · weekly' : ''}',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ] else if (isSkipped) ...[
                      Text(
                        session!.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary, decoration: TextDecoration.lineThrough),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'SKIPPED',
                        style: TextStyle(color: AppColors.advanced, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ] else
                    const Text('Rest day — tap to plan', style: TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              ),
              if (hasPlan && goalColor != null && !isSkipped)
                Container(
                  width: 8, height: 40,
                  decoration: BoxDecoration(color: goalColor, borderRadius: BorderRadius.circular(4)),
                ),
                if (onRemove != null) ...[
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                    onPressed: onRemove,
                  ),
                ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanPickerResult {
  final Routine? routine;
  final bool clearExisting;
  final bool repeatWeekly;

  const _PlanPickerResult({this.routine, this.clearExisting = false, this.repeatWeekly = false});
}

class _RoutinePickerSheet extends StatefulWidget {
  final List<Routine> routines;
  final String? selectedRoutineId;
  final bool repeatWeekly;
  final String dayLabel;

  const _RoutinePickerSheet({
    required this.routines,
    required this.selectedRoutineId,
    required this.repeatWeekly,
    required this.dayLabel,
  });

  @override
  State<_RoutinePickerSheet> createState() => _RoutinePickerSheetState();
}

class _RoutinePickerSheetState extends State<_RoutinePickerSheet> {
  late bool _repeatWeekly;

  @override
  void initState() {
    super.initState();
    _repeatWeekly = widget.repeatWeekly;
  }

  void _selectRoutine(Routine routine) {
    Navigator.pop(context, _PlanPickerResult(routine: routine, repeatWeekly: _repeatWeekly));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.72,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 12, 8),
            child: Row(
              children: [
                Expanded(child: Text('Plan ${widget.dayLabel}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
                if (widget.selectedRoutineId != null &&
                  widget.selectedRoutineId!.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    tooltip: 'Remove planned routine',
                    onPressed: () => Navigator.pop(
                      context,
                      const _PlanPickerResult(clearExisting: true),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Material(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
              child: SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                title: const Text('Repeat every week', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: const Text('Automatically schedule this routine on the same weekday', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                value: _repeatWeekly,
                activeThumbColor: AppColors.accent,
                onChanged: (value) => setState(() => _repeatWeekly = value),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: Colors.white10),
          Expanded(
            child: widget.routines.isEmpty
            ? const Center(
              child: Text(
                'No routines yet.\nCreate one in the Routines tab first.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
            : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.routines.length,
              itemBuilder: (context, index) {
                final routine = widget.routines[index];
                final isSelected = routine.id == widget.selectedRoutineId;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    color: isSelected ? AppColors.accent.withAlpha(30) : Theme.of(context).colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: isSelected ? const BorderSide(color: AppColors.accent) : BorderSide.none,
                      ),
                      title: Text(routine.name, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      subtitle: Text(
                        '${routine.goal.name} · ${routine.estimatedDurationMinutes} · ${routine.exercises.length} exercises',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                      trailing: isSelected
                      ? const Icon(Icons.check_circle, color: AppColors.accent)
                      : const Icon(Icons.add_circle_outline, color: AppColors.accent),
                      onTap: () => _selectRoutine(routine),
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
