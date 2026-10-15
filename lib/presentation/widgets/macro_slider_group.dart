import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Interactive macro distribution group with 3 auto-balancing sliders
/// and a segmented tri-color bar. Guarantees 100% total balance at all times.
class MacroSliderGroup extends StatefulWidget {
  final int totalCalories;
  final int initialCarbPercent;
  final int initialProteinPercent;
  final int initialFatPercent;
  final void Function(int carbs, int protein, int fat)? onMacrosChanged;

  const MacroSliderGroup({
    super.key,
    this.totalCalories = 1850,
    this.initialCarbPercent = 40,
    this.initialProteinPercent = 30,
    this.initialFatPercent = 30,
    this.onMacrosChanged,
  });

  @override
  State<MacroSliderGroup> createState() => _MacroSliderGroupState();
}

class _MacroSliderGroupState extends State<MacroSliderGroup> {
  late int _carbPercent;
  late int _proteinPercent;
  late int _fatPercent;

  @override
  void initState() {
    super.initState();
    _carbPercent = widget.initialCarbPercent;
    _proteinPercent = widget.initialProteinPercent;
    _fatPercent = widget.initialFatPercent;
    _ensureTotalIs100();
  }

  void _ensureTotalIs100() {
    final sum = _carbPercent + _proteinPercent + _fatPercent;
    if (sum != 100) {
      _fatPercent = 100 - _carbPercent - _proteinPercent;
      if (_fatPercent < 5) {
        _fatPercent = 5;
        _carbPercent = 95 - _proteinPercent;
      }
    }
  }

  // Grams formulas:
  // Carbs = 4 kcal/g
  // Protein = 4 kcal/g
  // Fat = 9 kcal/g
  int get carbGrams => ((widget.totalCalories * _carbPercent / 100) / 4).round();
  int get proteinGrams =>
      ((widget.totalCalories * _proteinPercent / 100) / 4).round();
  int get fatGrams => ((widget.totalCalories * _fatPercent / 100) / 9).round();

  // Smart redistribution logic that preserves 100% total
  void _updateCarbs(double value) {
    final newCarb = value.round().clamp(10, 80);
    final remaining = 100 - newCarb;
    final otherSum = _proteinPercent + _fatPercent;

    int newProtein;
    int newFat;

    if (otherSum > 0) {
      newProtein = ((_proteinPercent / otherSum) * remaining).round();
      newFat = remaining - newProtein;
    } else {
      newProtein = (remaining / 2).round();
      newFat = remaining - newProtein;
    }

    // Clamp minimums
    if (newProtein < 10) {
      newProtein = 10;
      newFat = remaining - 10;
    } else if (newFat < 10) {
      newFat = 10;
      newProtein = remaining - 10;
    }

    setState(() {
      _carbPercent = newCarb;
      _proteinPercent = newProtein;
      _fatPercent = newFat;
    });

    widget.onMacrosChanged?.call(_carbPercent, _proteinPercent, _fatPercent);
  }

  void _updateProtein(double value) {
    final newProtein = value.round().clamp(10, 80);
    final remaining = 100 - newProtein;
    final otherSum = _carbPercent + _fatPercent;

    int newCarb;
    int newFat;

    if (otherSum > 0) {
      newCarb = ((_carbPercent / otherSum) * remaining).round();
      newFat = remaining - newCarb;
    } else {
      newCarb = (remaining / 2).round();
      newFat = remaining - newCarb;
    }

    if (newCarb < 10) {
      newCarb = 10;
      newFat = remaining - 10;
    } else if (newFat < 10) {
      newFat = 10;
      newCarb = remaining - 10;
    }

    setState(() {
      _carbPercent = newCarb;
      _proteinPercent = newProtein;
      _fatPercent = newFat;
    });

    widget.onMacrosChanged?.call(_carbPercent, _proteinPercent, _fatPercent);
  }

  void _updateFat(double value) {
    final newFat = value.round().clamp(10, 80);
    final remaining = 100 - newFat;
    final otherSum = _carbPercent + _proteinPercent;

    int newCarb;
    int newProtein;

    if (otherSum > 0) {
      newCarb = ((_carbPercent / otherSum) * remaining).round();
      newProtein = remaining - newCarb;
    } else {
      newCarb = (remaining / 2).round();
      newProtein = remaining - newCarb;
    }

    if (newCarb < 10) {
      newCarb = 10;
      newProtein = remaining - 10;
    } else if (newProtein < 10) {
      newProtein = 10;
      newCarb = remaining - 10;
    }

    setState(() {
      _carbPercent = newCarb;
      _proteinPercent = newProtein;
      _fatPercent = newFat;
    });

    widget.onMacrosChanged?.call(_carbPercent, _proteinPercent, _fatPercent);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
          // Header: Title, subtitle and 100% total badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Distribución de Macronutrientes',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Balance Metabólico Diario',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryMint,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primaryBorder, width: 1),
                ),
                child: Text(
                  '100% Total',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Tri-color Segmented Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 14,
              child: Row(
                children: [
                  // Carbs Segment (Amber)
                  Expanded(
                    flex: _carbPercent,
                    child: Container(
                      color: AppColors.carbs,
                    ),
                  ),
                  const SizedBox(width: 2),
                  // Protein Segment (Emerald)
                  Expanded(
                    flex: _proteinPercent,
                    child: Container(
                      color: AppColors.protein,
                    ),
                  ),
                  const SizedBox(width: 2),
                  // Fat Segment (Indigo)
                  Expanded(
                    flex: _fatPercent,
                    child: Container(
                      color: AppColors.fat,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Slider 1: Carbohidratos (Amber)
          _MacroSliderRow(
            label: 'Carbohidratos',
            grams: '${carbGrams}g',
            percent: _carbPercent,
            color: AppColors.carbs,
            lightColor: AppColors.carbsLight,
            onChanged: _updateCarbs,
          ),

          const SizedBox(height: 16),

          // Slider 2: Proteínas (Emerald)
          _MacroSliderRow(
            label: 'Proteínas',
            grams: '${proteinGrams}g',
            percent: _proteinPercent,
            color: AppColors.protein,
            lightColor: AppColors.proteinLight,
            onChanged: _updateProtein,
          ),

          const SizedBox(height: 16),

          // Slider 3: Grasas Saludables (Indigo)
          _MacroSliderRow(
            label: 'Grasas Saludables',
            grams: '${fatGrams}g',
            percent: _fatPercent,
            color: AppColors.fat,
            lightColor: AppColors.fatLight,
            onChanged: _updateFat,
          ),
        ],
      ),
    );
  }
}

/// Helper row for an individual macro slider with color accent, grams and percentage.
class _MacroSliderRow extends StatelessWidget {
  final String label;
  final String grams;
  final int percent;
  final Color color;
  final Color lightColor;
  final ValueChanged<double> onChanged;

  const _MacroSliderRow({
    required this.label,
    required this.grams,
    required this.percent,
    required this.color,
    required this.lightColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  grams,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: lightColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$percent%',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 4),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            inactiveTrackColor: AppColors.surfaceMuted,
            thumbColor: color,
            overlayColor: color.withValues(alpha: 0.18),
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
          ),
          child: Semantics(
            slider: true,
            label: '$label: $grams, $percent por ciento',
            child: Slider(
              value: percent.toDouble(),
              min: 10,
              max: 80,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
