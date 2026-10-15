import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Data representation for a single macronutrient target and current consumption.
class MacroItemData {
  final String label;
  final int currentGrams;
  final int targetGrams;
  final Color color;
  final Color? trackColor;

  const MacroItemData({
    required this.label,
    required this.currentGrams,
    required this.targetGrams,
    required this.color,
    this.trackColor,
  });

  double get progress {
    if (targetGrams <= 0) return 0.0;
    return (currentGrams / targetGrams).clamp(0.0, 1.0);
  }
}

/// Horizontal progress bars for daily macronutrients (Carbs, Protein, Fat),
/// featuring color accents, rounded tracks, animated progress, and accessible labels.
class MacroProgressBar extends StatelessWidget {
  final int carbsCurrent;
  final int carbsTarget;
  final int proteinCurrent;
  final int proteinTarget;
  final int fatCurrent;
  final int fatTarget;
  final bool animate;

  const MacroProgressBar({
    super.key,
    this.carbsCurrent = 85,
    this.carbsTarget = 220,
    this.proteinCurrent = 72,
    this.proteinTarget = 130,
    this.fatCurrent = 24,
    this.fatTarget = 65,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      MacroItemData(
        label: 'Carbohidratos',
        currentGrams: carbsCurrent,
        targetGrams: carbsTarget,
        color: AppColors.carbs,
        trackColor: AppColors.carbsLight,
      ),
      MacroItemData(
        label: 'Proteínas',
        currentGrams: proteinCurrent,
        targetGrams: proteinTarget,
        color: AppColors.protein,
        trackColor: AppColors.proteinLight,
      ),
      MacroItemData(
        label: 'Grasas',
        currentGrams: fatCurrent,
        targetGrams: fatTarget,
        color: AppColors.fat,
        trackColor: AppColors.fatLight,
      ),
    ];

    return Semantics(
      container: true,
      label: 'Resumen de macronutrientes del día',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: items.map((item) {
          final isLast = item == items.last;
          return Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
            child: _MacroProgressRow(item: item, animate: animate),
          );
        }).toList(),
      ),
    );
  }
}

class _MacroProgressRow extends StatelessWidget {
  final MacroItemData item;
  final bool animate;

  const _MacroProgressRow({
    required this.item,
    required this.animate,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          '${item.label}: ${item.currentGrams} gramos de ${item.targetGrams} gramos alcanzados.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header: Dot + Label + Values
          Row(
            children: [
              // Dot indicator
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: item.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),

              // Macro name
              Text(
                item.label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const Spacer(),

              // Progress numbers: "85g / 220g"
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${item.currentGrams}g',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    TextSpan(
                      text: ' / ${item.targetGrams}g',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Horizontal progress track
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Container(
              height: 7,
              width: double.infinity,
              color: item.trackColor ?? const Color(0xFFF1F5F9),
              child: Stack(
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final targetWidth = constraints.maxWidth * item.progress;

                      if (!animate) {
                        return Container(
                          width: targetWidth,
                          height: 7,
                          decoration: BoxDecoration(
                            color: item.color,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        );
                      }

                      return TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0.0, end: item.progress),
                        duration: const Duration(milliseconds: 900),
                        curve: Curves.easeOutCubic,
                        builder: (context, val, child) {
                          return Container(
                            width: constraints.maxWidth * val,
                            height: 7,
                            decoration: BoxDecoration(
                              color: item.color,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
