import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';

/// Model representing the AI nutritional analysis breakdown.
class NutritionAnalysisData {
  final int totalCalories;
  final int baseCalories;
  final int proteinGrams;
  final int carbsGrams;
  final int fatGrams;
  final double fiberGrams;
  final int sodiumMg;
  final String? noteAdjustmentText;
  final int? caloriesAdjustedByNote;
  final String mealType; // e.g. "Almuerzo"
  final DateTime timestamp;
  final String coachInsight;

  const NutritionAnalysisData({
    required this.totalCalories,
    required this.baseCalories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
    this.fiberGrams = 6.0,
    this.sodiumMg = 340,
    this.noteAdjustmentText,
    this.caloriesAdjustedByNote,
    this.mealType = 'Almuerzo',
    required this.timestamp,
    this.coachInsight =
        'Excelente elección rica en proteína magra. Te deja un margen ideal de 900 kcal para la cena dentro de tu meta de déficit.',
  });

  factory NutritionAnalysisData.sample({
    bool withNoteAdjustment = true,
    int adjustedCaloriesDiff = -65,
  }) {
    const base = 585;
    final total = withNoteAdjustment ? (base + adjustedCaloriesDiff) : base;

    return NutritionAnalysisData(
      totalCalories: total,
      baseCalories: base,
      proteinGrams: 42,
      carbsGrams: 28,
      fatGrams: 16,
      fiberGrams: 6.0,
      sodiumMg: 340,
      noteAdjustmentText: withNoteAdjustment
          ? '✓ Ajustado por tu nota: -65 kcal por café sin endulzante ni cremas.'
          : null,
      caloriesAdjustedByNote: withNoteAdjustment ? adjustedCaloriesDiff : null,
      mealType: 'Almuerzo',
      timestamp: DateTime.now(),
      coachInsight:
          'Excelente elección rica en proteína magra. Te deja un margen ideal de 900 kcal para la cena dentro de tu meta de déficit.',
    );
  }
}

/// The complete Nutrition Analysis Panel / Bottom Sheet
class NutritionBottomSheet extends StatefulWidget {
  final NutritionAnalysisData data;
  final VoidCallback? onConfirm;
  final bool isModal;

  const NutritionBottomSheet({
    super.key,
    required this.data,
    this.onConfirm,
    this.isModal = false,
  });

  /// Convenient helper to display as modal bottom sheet
  static Future<bool?> showModal(
    BuildContext context, {
    required NutritionAnalysisData data,
    VoidCallback? onConfirm,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (ctx) {
        return NutritionBottomSheet(
          data: data,
          isModal: true,
          onConfirm: onConfirm,
        );
      },
    );
  }

  @override
  State<NutritionBottomSheet> createState() => _NutritionBottomSheetState();
}

class _NutritionBottomSheetState extends State<NutritionBottomSheet>
    with SingleTickerProviderStateMixin {
  bool _isSaving = false;
  bool _isSaved = false;

  late final AnimationController _progressController;
  late final Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _progressAnimation = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    );
    _progressController.forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  Future<void> _handleConfirm() async {
    if (_isSaving || _isSaved) return;

    setState(() {
      _isSaving = true;
    });

    // Simulate database write / verification delay
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    setState(() {
      _isSaving = false;
      _isSaved = true;
    });

    // Call onConfirm callback
    widget.onConfirm?.call();

    // Small delay to let user appreciate the success checkmark
    await Future.delayed(const Duration(milliseconds: 700));

    if (mounted) {
      if (widget.isModal) {
        Navigator.of(context).pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedTime = DateFormat('HH:mm').format(widget.data.timestamp);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: widget.isModal
            ? const BorderRadius.vertical(top: Radius.circular(32))
            : BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 28,
            offset: const Offset(0, -6),
          ),
        ],
        border: widget.isModal
            ? Border.all(color: AppColors.border, width: 1)
            : Border.all(color: AppColors.primaryBorder.withValues(alpha: 0.6), width: 1.2),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: widget.isModal
              ? const BouncingScrollPhysics()
              : const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Bottom sheet drag handle (if modal)
              if (widget.isModal)
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),

              // Header: ANÁLISIS NUTRICIONAL TOTAL
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryMint,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.analytics_outlined,
                          size: 18,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'ANÁLISIS NUTRICIONAL TOTAL',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryMint,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primaryBorder, width: 1),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bolt, size: 14, color: AppColors.primary),
                        SizedBox(width: 2),
                        Text(
                          'IA 98%',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Total Calories Highlight with circular indicator
              _buildCaloriesRow(),

              // Note Adjustment Alert Banner (Mint Green)
              if (widget.data.noteAdjustmentText != null &&
                  widget.data.noteAdjustmentText!.isNotEmpty) ...[
                const SizedBox(height: 14),
                _buildNoteAdjustmentBanner(widget.data.noteAdjustmentText!),
              ],

              const SizedBox(height: 18),

              // 3 Macronutrient Columns (Proteínas, Carbos, Grasas)
              _buildMacronutrientsRow(),

              const SizedBox(height: 14),

              // Micronutrients: Fibra & Sodio with "ÓPTIMO" Badge
              _buildMicronutrientsRow(),

              const SizedBox(height: 16),

              // Nutri-Coach IA Card (Soft lilac #F3E8FF)
              _buildNutriCoachCard(),

              const SizedBox(height: 20),

              // Main Confirmation Button: "✓ Confirmar y registrar comida"
              _buildConfirmButton(formattedTime),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCaloriesRow() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${widget.data.totalCalories}',
                    style: const TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.0,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'kcal estimadas',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 15,
                    color: AppColors.primaryDark,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Meta diaria: 2,100 kcal • Restan 1,580 kcal',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Circular Calorie Progress Gauge
          SizedBox(
            width: 54,
            height: 54,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: (widget.data.totalCalories / 2100.0).clamp(0.0, 1.0),
                  backgroundColor: AppColors.border,
                  color: AppColors.primary,
                  strokeWidth: 5,
                  strokeCap: StrokeCap.round,
                ),
                Text(
                  '${((widget.data.totalCalories / 2100.0) * 100).round()}%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteAdjustmentBanner(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primaryMint,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryBorder,
          width: 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
            ),
            child: const Icon(
              Icons.check,
              size: 13,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF065F46), // Deep rich green
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacronutrientsRow() {
    final totalGrams = (widget.data.proteinGrams +
            widget.data.carbsGrams +
            widget.data.fatGrams)
        .toDouble();

    final pRatio = totalGrams > 0 ? widget.data.proteinGrams / totalGrams : 0.33;
    final cRatio = totalGrams > 0 ? widget.data.carbsGrams / totalGrams : 0.33;
    final fRatio = totalGrams > 0 ? widget.data.fatGrams / totalGrams : 0.33;

    return Row(
      children: [
        // Proteínas
        Expanded(
          child: _buildMacroCard(
            title: 'Proteínas',
            grams: '${widget.data.proteinGrams}g',
            ratio: pRatio,
            color: AppColors.protein,
            lightBg: AppColors.proteinLight,
          ),
        ),
        const SizedBox(width: 8),

        // Carbos
        Expanded(
          child: _buildMacroCard(
            title: 'Carbos',
            grams: '${widget.data.carbsGrams}g',
            ratio: cRatio,
            color: AppColors.carbs,
            lightBg: AppColors.carbsLight,
          ),
        ),
        const SizedBox(width: 8),

        // Grasas
        Expanded(
          child: _buildMacroCard(
            title: 'Grasas',
            grams: '${widget.data.fatGrams}g',
            ratio: fRatio,
            color: AppColors.fat,
            lightBg: AppColors.fatLight,
          ),
        ),
      ],
    );
  }

  Widget _buildMacroCard({
    required String title,
    required String grams,
    required double ratio,
    required Color color,
    required Color lightBg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            grams,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return LinearProgressIndicator(
                  value: ratio * _progressAnimation.value,
                  backgroundColor: lightBg,
                  color: color,
                  minHeight: 6,
                );
              },
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${(ratio * 100).round()}% total',
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMicronutrientsRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(
                Icons.trending_up,
                size: 18,
                color: AppColors.primaryDark,
              ),
              const SizedBox(width: 8),
              Text(
                'Fibra ${widget.data.fiberGrams.toStringAsFixed(0)}g  •  Sodio ${widget.data.sodiumMg}mg',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'ÓPTIMO',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                color: AppColors.primaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutriCoachCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.purpleLight, // Soft lilac #F3E8FF
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.purpleDark.withValues(alpha: 0.18),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.purpleDark.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.psychology_outlined,
              size: 22,
              color: AppColors.purpleDark,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text(
                      'NUTRI-COACH IA',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: AppColors.purpleDark,
                      ),
                    ),
                    SizedBox(width: 5),
                    Icon(
                      Icons.auto_awesome,
                      size: 13,
                      color: AppColors.purpleDark,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  widget.data.coachInsight,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                    color: Color(0xFF4A148C), // Rich deep purple for high contrast
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton(String formattedTime) {
    if (_isSaved) {
      return Container(
        height: 60,
        decoration: BoxDecoration(
          color: AppColors.primaryDark,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 24),
            SizedBox(width: 10),
            Text(
              '¡Comida registrada exitosamente!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }

    return Semantics(
      button: true,
      label: 'Confirmar y registrar comida',
      hint: 'Guarda esta comida como Almuerzo en el historial diario',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isSaving ? null : _handleConfirm,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isSaving) ...[
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Guardando en tu historial...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ] else ...[
                      const Icon(Icons.check, color: Colors.white, size: 21),
                      const SizedBox(width: 8),
                      const Text(
                        'Confirmar y registrar comida',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  'Se guardará como "${widget.data.mealType}" a las $formattedTime hrs',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.88),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
