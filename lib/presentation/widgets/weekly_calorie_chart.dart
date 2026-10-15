import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Data model representing a day's calorie consumption in the weekly chart.
class DayCalorieData {
  final String dayLabel;
  final String fullDayName;
  final int calories;
  final bool isHighlighted;

  const DayCalorieData({
    required this.dayLabel,
    required this.fullDayName,
    required this.calories,
    this.isHighlighted = false,
  });
}

/// Interactive weekly calorie consumption vs target bar chart.
/// Shows daily bars (L, M, X, J, V, S, D), a dashed 2,000 kcal target line,
/// deficit legend badge, and highlights the active Friday at 1,840 kcal.
class WeeklyCalorieChart extends StatefulWidget {
  final int calorieTarget;
  final List<DayCalorieData>? customData;
  final ValueChanged<int>? onDaySelected;

  const WeeklyCalorieChart({
    super.key,
    this.calorieTarget = 2000,
    this.customData,
    this.onDaySelected,
  });

  @override
  State<WeeklyCalorieChart> createState() => _WeeklyCalorieChartState();
}

class _WeeklyCalorieChartState extends State<WeeklyCalorieChart> {
  late int _selectedDayIndex;

  late final List<DayCalorieData> _data = widget.customData ??
      const [
        DayCalorieData(
          dayLabel: 'L',
          fullDayName: 'Lunes',
          calories: 1920,
        ),
        DayCalorieData(
          dayLabel: 'M',
          fullDayName: 'Martes',
          calories: 1780,
        ),
        DayCalorieData(
          dayLabel: 'X',
          fullDayName: 'Miércoles',
          calories: 1950,
        ),
        DayCalorieData(
          dayLabel: 'J',
          fullDayName: 'Jueves',
          calories: 1810,
        ),
        DayCalorieData(
          dayLabel: 'V',
          fullDayName: 'Viernes',
          calories: 1840,
          isHighlighted: true,
        ),
        DayCalorieData(
          dayLabel: 'S',
          fullDayName: 'Sábado',
          calories: 1980,
        ),
        DayCalorieData(
          dayLabel: 'D',
          fullDayName: 'Domingo',
          calories: 1860,
        ),
      ];

  @override
  void initState() {
    super.initState();
    _selectedDayIndex = 4; // Friday highlighted by default
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const maxScaleCalories = 2500.0;
    final selectedDay = _data[_selectedDayIndex];

    return Container(
      padding: const EdgeInsets.all(20),
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
          // Header: Title and Legend Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Consumo vs. Meta',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  fontSize: 16,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryMint,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primaryBorder, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Déficit ok',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Chart Display Area
          SizedBox(
            height: 190,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final chartHeight = constraints.maxHeight - 35; // Reserve for labels
                final targetLineFraction = widget.calorieTarget / maxScaleCalories;
                final targetYFromBottom = chartHeight * targetLineFraction;

                return Stack(
                  children: [
                    // Dashed Target Line at 2,000 kcal
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 35 + targetYFromBottom,
                      child: Row(
                        children: [
                          Expanded(
                            child: CustomPaint(
                              painter: _DashedLinePainter(
                                color: AppColors.textMuted.withValues(alpha: 0.5),
                                strokeWidth: 1.2,
                                dashWidth: 5,
                                dashSpace: 3,
                              ),
                              size: const Size(double.infinity, 1),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceMuted,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: AppColors.border,
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              'Meta: ${widget.calorieTarget}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Daily Bars Row
                    Positioned.fill(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(_data.length, (index) {
                          final item = _data[index];
                          final isSelected = index == _selectedDayIndex;
                          final barHeight =
                              (item.calories / maxScaleCalories) * chartHeight;
                          final isUnderTarget = item.calories <= widget.calorieTarget;

                          return Expanded(
                            child: Semantics(
                              button: true,
                              label:
                                  '${item.fullDayName}: ${item.calories} kilocalorías, '
                                  '${isUnderTarget ? "dentro de la meta" : "sobre la meta"}, '
                                  '${isSelected ? "seleccionado" : "toca para ver"}',
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedDayIndex = index;
                                  });
                                  widget.onDaySelected?.call(index);
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    // Highlight badge for Friday or selected day
                                    if (isSelected)
                                      Container(
                                        margin: const EdgeInsets.only(bottom: 6),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.textPrimary,
                                          borderRadius: BorderRadius.circular(8),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.12),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          '${item.calories}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 10,
                                          ),
                                        ),
                                      )
                                    else
                                      const SizedBox(height: 23),

                                    // Bar container
                                    Container(
                                      width: 26,
                                      height: chartHeight,
                                      alignment: Alignment.bottomCenter,
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceMuted.withValues(alpha: 0.5),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 300),
                                        curve: Curves.easeOutCubic,
                                        width: 26,
                                        height: barHeight,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: isSelected
                                                ? [
                                                    AppColors.primary,
                                                    AppColors.primaryDark,
                                                  ]
                                                : [
                                                    AppColors.primaryLight,
                                                    AppColors.primary.withValues(alpha: 0.7),
                                                  ],
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                          boxShadow: isSelected
                                              ? [
                                                  BoxShadow(
                                                    color: AppColors.primary
                                                        .withValues(alpha: 0.4),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 3),
                                                  ),
                                                ]
                                              : null,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 8),

                                    // Day Letter Label
                                    Text(
                                      item.dayLabel,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: isSelected
                                            ? AppColors.primaryDark
                                            : AppColors.textSecondary,
                                        fontWeight: isSelected
                                            ? FontWeight.w800
                                            : FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // Sub-footer info for selected day
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${selectedDay.fullDayName}: ${selectedDay.calories} kcal',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  selectedDay.calories <= widget.calorieTarget
                      ? 'Déficit de ${widget.calorieTarget - selectedDay.calories} kcal'
                      : 'Exceso de ${selectedDay.calories - widget.calorieTarget} kcal',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: selectedDay.calories <= widget.calorieTarget
                        ? AppColors.primaryDark
                        : AppColors.burnOrange,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for horizontal dashed reference line.
class _DashedLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  _DashedLinePainter({
    required this.color,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashSpace,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.dashSpace != dashSpace;
  }
}
