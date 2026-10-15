import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Activity level option for metabolic calculations.
class ActivityLevelOption {
  final String title;
  final String factorLabel;
  final double factor;
  final String description;

  const ActivityLevelOption({
    required this.title,
    required this.factorLabel,
    required this.factor,
    required this.description,
  });
}

/// Biometric data card with dynamic adjustment capabilities.
/// Displays current weight, target weight, age, height, biological sex selector,
/// and activity factor radio options.
class BiometricCard extends StatelessWidget {
  final double currentWeight;
  final double targetWeight;
  final int age;
  final double height;
  final String gender; // 'Femenino' or 'Masculino'
  final double activityFactor;

  final ValueChanged<double>? onCurrentWeightChanged;
  final ValueChanged<double>? onTargetWeightChanged;
  final ValueChanged<int>? onAgeChanged;
  final ValueChanged<double>? onHeightChanged;
  final ValueChanged<String>? onGenderChanged;
  final ValueChanged<double>? onActivityFactorChanged;

  const BiometricCard({
    super.key,
    this.currentWeight = 68.5,
    this.targetWeight = 62.0,
    this.age = 29,
    this.height = 168.0,
    this.gender = 'Femenino',
    this.activityFactor = 1.55,
    this.onCurrentWeightChanged,
    this.onTargetWeightChanged,
    this.onAgeChanged,
    this.onHeightChanged,
    this.onGenderChanged,
    this.onActivityFactorChanged,
  });

  static const List<ActivityLevelOption> activityOptions = [
    ActivityLevelOption(
      title: 'Moderadamente activo',
      factorLabel: 'x1.55',
      factor: 1.55,
      description: 'Entrenamiento moderado 3-5 días/sem',
    ),
    ActivityLevelOption(
      title: 'Muy activo / Atleta',
      factorLabel: 'x1.72',
      factor: 1.72,
      description: 'Entrenamiento intenso 6-7 días/sem',
    ),
    ActivityLevelOption(
      title: 'Ligeramente activo',
      factorLabel: 'x1.375',
      factor: 1.375,
      description: 'Ejercicio ligero o caminatas 1-3 días/sem',
    ),
    ActivityLevelOption(
      title: 'Sedentario',
      factorLabel: 'x1.20',
      factor: 1.20,
      description: 'Poco o ningún ejercicio, trabajo de oficina',
    ),
  ];

  void _showEditNumberDialog({
    required BuildContext context,
    required String title,
    required String suffix,
    required double initialValue,
    required ValueChanged<double> onSubmitted,
    double min = 10,
    double max = 300,
    bool isInteger = false,
  }) {
    final controller = TextEditingController(
      text: isInteger
          ? initialValue.toInt().toString()
          : initialValue.toStringAsFixed(1),
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Modificar $title',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
          ),
          content: Column(
            mainAxisSize: min == 0 ? MainAxisSize.max : MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                decoration: InputDecoration(
                  labelText: title,
                  suffixText: suffix,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                final value = double.tryParse(controller.text);
                if (value != null && value >= min && value <= max) {
                  onSubmitted(value);
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final weightDifference = (currentWeight - targetWeight).abs();

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
          // Header with dynamic adjustment badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.accessibility_new_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Datos Biométricos',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      fontSize: 17,
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
                  'Ajuste Dinámico',
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

          // 2x2 Grid of Metrics
          Row(
            children: [
              // Current Weight Card
              Expanded(
                child: _MetricTile(
                  label: 'Peso actual',
                  value: '${currentWeight.toStringAsFixed(1)} kg',
                  badgeText: '-1.8 kg Este mes',
                  badgeColor: AppColors.primaryMint,
                  badgeTextColor: AppColors.primaryDark,
                  onTap: () {
                    _showEditNumberDialog(
                      context: context,
                      title: 'Peso actual',
                      suffix: 'kg',
                      initialValue: currentWeight,
                      min: 30,
                      max: 250,
                      onSubmitted: (val) => onCurrentWeightChanged?.call(val),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),

              // Target Weight Card
              Expanded(
                child: _MetricTile(
                  label: 'Peso objetivo',
                  value: '${targetWeight.toStringAsFixed(1)} kg',
                  badgeText: 'META Resta: ${weightDifference.toStringAsFixed(1)} kg',
                  badgeColor: AppColors.purpleLight,
                  badgeTextColor: AppColors.purpleDark,
                  onTap: () {
                    _showEditNumberDialog(
                      context: context,
                      title: 'Peso objetivo',
                      suffix: 'kg',
                      initialValue: targetWeight,
                      min: 30,
                      max: 250,
                      onSubmitted: (val) => onTargetWeightChanged?.call(val),
                    );
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              // Age Card
              Expanded(
                child: _MetricTile(
                  label: 'Edad',
                  value: '$age años',
                  subtitle: 'Metabolismo basal',
                  onTap: () {
                    _showEditNumberDialog(
                      context: context,
                      title: 'Edad',
                      suffix: 'años',
                      initialValue: age.toDouble(),
                      isInteger: true,
                      min: 14,
                      max: 100,
                      onSubmitted: (val) => onAgeChanged?.call(val.toInt()),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),

              // Height Card
              Expanded(
                child: _MetricTile(
                  label: 'Altura',
                  value: '${height.toStringAsFixed(0)} cm',
                  subtitle: 'Estatura oficial',
                  onTap: () {
                    _showEditNumberDialog(
                      context: context,
                      title: 'Altura',
                      suffix: 'cm',
                      initialValue: height,
                      min: 100,
                      max: 230,
                      onSubmitted: (val) => onHeightChanged?.call(val),
                    );
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Biological Sex Selector
          Text(
            'Sexo Biológico (Fórmula Mifflin-St Jeor)',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _GenderButton(
                  label: '♀ Femenino',
                  isSelected: gender.toLowerCase() == 'femenino',
                  onTap: () => onGenderChanged?.call('Femenino'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _GenderButton(
                  label: '♂ Masculino',
                  isSelected: gender.toLowerCase() == 'masculino',
                  onTap: () => onGenderChanged?.call('Masculino'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Activity Level Selector
          Text(
            'Nivel de Actividad Física',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),

          Column(
            children: activityOptions.map((opt) {
              final isSelected = (activityFactor - opt.factor).abs() < 0.01;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Semantics(
                  button: true,
                  selected: isSelected,
                  label: '${opt.title}, factor ${opt.factorLabel}, ${opt.description}',
                  child: InkWell(
                    onTap: () => onActivityFactorChanged?.call(opt.factor),
                    borderRadius: BorderRadius.circular(14),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryMint.withValues(alpha: 0.5)
                            : AppColors.surfaceMuted.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected
                                ? Icons.radio_button_checked_rounded
                                : Icons.radio_button_off_rounded,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textMuted,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      opt.title,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 1.5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppColors.primary
                                            : AppColors.surface,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        opt.factorLabel,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: isSelected
                                              ? Colors.white
                                              : AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  opt.description,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// Helper tile for a single biometric metric.
class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final String? badgeText;
  final Color? badgeColor;
  final Color? badgeTextColor;
  final String? subtitle;
  final VoidCallback onTap;

  const _MetricTile({
    required this.label,
    required this.value,
    this.badgeText,
    this.badgeColor,
    this.badgeTextColor,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      button: true,
      label: '$label: $value. Toca para editar',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                  const Icon(
                    Icons.edit_outlined,
                    size: 14,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              if (badgeText != null) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeColor ?? AppColors.primaryMint,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badgeText!,
                    style: TextStyle(
                      color: badgeTextColor ?? AppColors.primaryDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                ),
              ] else if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Button for selecting biological sex.
class _GenderButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: 'Sexo: $label',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppColors.primaryDark : AppColors.border,
              width: 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
