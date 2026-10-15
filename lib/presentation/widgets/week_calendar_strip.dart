import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Interactive week calendar strip widget.
/// Displays a week selector with navigation controls, date range badge,
/// and a 7-day row with completion checks and emerald active day highlight.
class WeekCalendarStrip extends StatefulWidget {
  final DateTime? initialDate;
  final ValueChanged<DateTime>? onDaySelected;
  final String weekLabel;
  final String dateRangeBadge;
  final Set<int>? completedDayIndices; // 0-indexed (0 = Monday, ..., 6 = Sunday)

  const WeekCalendarStrip({
    super.key,
    this.initialDate,
    this.onDaySelected,
    this.weekLabel = 'Semana Actual',
    this.dateRangeBadge = '12 - 18 MAY',
    this.completedDayIndices,
  });

  @override
  State<WeekCalendarStrip> createState() => _WeekCalendarStripState();
}

class _WeekCalendarStripState extends State<WeekCalendarStrip> {
  late int _selectedDayIndex; // 0 = Lunes, 4 = Viernes (default highlighted)
  late DateTime _currentWeekStart;

  // Days configuration for the week
  final List<String> _dayNames = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
  final List<String> _fullDayNames = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo'
  ];
  final List<int> _dayNumbers = [12, 13, 14, 15, 16, 17, 18];

  late Set<int> _completedDays;

  @override
  void initState() {
    super.initState();
    // Default to Friday 16 (index 4) as shown in reference designs
    _selectedDayIndex = 4;
    _currentWeekStart = widget.initialDate ?? DateTime(2026, 5, 12);
    _completedDays = widget.completedDayIndices ?? {0, 1, 2, 3, 4, 5, 6};
  }

  void _selectDay(int index) {
    setState(() {
      _selectedDayIndex = index;
    });
    final selectedDate = _currentWeekStart.add(Duration(days: index));
    widget.onDaySelected?.call(selectedDate);
  }

  void _previousWeek() {
    setState(() {
      _currentWeekStart = _currentWeekStart.subtract(const Duration(days: 7));
    });
  }

  void _nextWeek() {
    setState(() {
      _currentWeekStart = _currentWeekStart.add(const Duration(days: 7));
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Navigation and week badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Previous week button
              Semantics(
                button: true,
                label: 'Semana anterior',
                child: IconButton(
                  icon: const Icon(Icons.chevron_left_rounded, size: 24),
                  color: AppColors.textSecondary,
                  constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                  splashRadius: 22,
                  onPressed: _previousWeek,
                ),
              ),

              // Title and date badge
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('📅 ', style: TextStyle(fontSize: 16)),
                  Text(
                    widget.weekLabel,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryMint,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primaryBorder,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      widget.dateRangeBadge,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),

              // Next week button
              Semantics(
                button: true,
                label: 'Semana siguiente',
                child: IconButton(
                  icon: const Icon(Icons.chevron_right_rounded, size: 24),
                  color: AppColors.textSecondary,
                  constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                  splashRadius: 22,
                  onPressed: _nextWeek,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 7-day strip row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final isSelected = _selectedDayIndex == index;
              final isCompleted = _completedDays.contains(index);
              final dayLetter = _dayNames[index];
              final dayNumber = _dayNumbers[index];
              final fullDayName = _fullDayNames[index];

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.5),
                  child: Semantics(
                    button: true,
                    selected: isSelected,
                    label:
                        '$fullDayName $dayNumber de Mayo, '
                        '${isCompleted ? 'completado' : 'sin completar'}, '
                        '${isSelected ? 'seleccionado' : 'toca para seleccionar'}',
                    child: InkWell(
                      onTap: () => _selectDay(index),
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.surfaceMuted.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryDark
                                : AppColors.border.withValues(alpha: 0.6),
                            width: 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.35),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Day letter (L, M, X, J, V, S, D)
                            Text(
                              dayLetter,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isSelected
                                    ? Colors.white.withValues(alpha: 0.9)
                                    : AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),

                            // Day number (12..18)
                            Text(
                              dayNumber.toString(),
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textPrimary,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 6),

                            // Completion check badge
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? Colors.white
                                    : (isCompleted
                                        ? AppColors.primary
                                        : AppColors.border),
                              ),
                              child: Icon(
                                Icons.check_rounded,
                                size: 11,
                                color: isSelected
                                    ? AppColors.primary
                                    : (isCompleted
                                        ? Colors.white
                                        : AppColors.textMuted),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
