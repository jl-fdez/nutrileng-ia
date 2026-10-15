import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/biometric_card.dart';
import '../widgets/macro_slider_group.dart';

/// Deficit plan definition for metabolic calculations.
class DeficitPlan {
  final String label;
  final double deficitPercentage; // e.g. 0.15 for 15%
  final String description;

  const DeficitPlan({
    required this.label,
    required this.deficitPercentage,
    required this.description,
  });
}

/// Profile screen displaying user stats, dynamic biometric adjustments,
/// bioadaptive metabolic calculations with Mifflin-St Jeor formulas,
/// interactive macronutrient redistribution sliders, and AI automation switches.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Biometric state
  double _currentWeight = 68.5;
  double _targetWeight = 62.0;
  int _age = 29;
  double _height = 168.0;
  String _gender = 'Femenino';
  double _activityFactor = 1.55;

  // Metabolic plan options
  final List<DeficitPlan> _deficitPlans = const [
    DeficitPlan(
      label: 'Déficit moderado óptimo (-15%)',
      deficitPercentage: 0.15,
      description: 'Pérdida sostenible ~0.45 kg/sem sin pérdida muscular',
    ),
    DeficitPlan(
      label: 'Déficit ligero (-10%)',
      deficitPercentage: 0.10,
      description: 'Pérdida gradual ~0.30 kg/sem, máxima energía',
    ),
    DeficitPlan(
      label: 'Déficit agresivo (-20%)',
      deficitPercentage: 0.20,
      description: 'Pérdida rápida ~0.60 kg/sem, monitoreo estricto',
    ),
    DeficitPlan(
      label: 'Mantenimiento (0%)',
      deficitPercentage: 0.0,
      description: 'Recomposición corporal y mantenimiento de peso',
    ),
    DeficitPlan(
      label: 'Superávit limpio (+10%)',
      deficitPercentage: -0.10,
      description: 'Ganancia de masa muscular magra controlada',
    ),
  ];

  late int _selectedPlanIndex;

  // Macros state
  int _carbPercent = 40;
  int _proteinPercent = 30;
  int _fatPercent = 30;

  // Automation & AI Toggles
  bool _mealReminders = true;
  bool _aiMetabolicCompensation = true;

  @override
  void initState() {
    super.initState();
    _selectedPlanIndex = 0; // Déficit moderado óptimo (-15%)
  }

  // Mifflin-St Jeor BMR & TDEE Calculations:
  // Women: BMR = (10 * kg) + (6.25 * cm) - (5 * age) - 161
  // Men: BMR = (10 * kg) + (6.25 * cm) - (5 * age) + 5
  int get _bmr {
    final base = (10 * _currentWeight) + (6.25 * _height) - (5 * _age);
    if (_gender.toLowerCase() == 'femenino') {
      return (base - 161).round();
    } else {
      return (base + 5).round();
    }
  }

  int get _tdee => (_bmr * _activityFactor).round();

  DeficitPlan get _currentPlan => _deficitPlans[_selectedPlanIndex];

  int get _deficitAdjustmentCalories =>
      (_tdee * _currentPlan.deficitPercentage).round();

  int get _targetDailyCalories => (_tdee - _deficitAdjustmentCalories).round();

  void _nextPlan() {
    setState(() {
      _selectedPlanIndex = (_selectedPlanIndex + 1) % _deficitPlans.length;
    });
  }

  void _previousPlan() {
    setState(() {
      _selectedPlanIndex =
          (_selectedPlanIndex - 1 + _deficitPlans.length) % _deficitPlans.length;
    });
  }

  void _saveAndRecalculate() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.primaryDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '¡Metas sincronizadas con éxito! Meta: $_targetDailyCalories kcal/día '
                '(TDEE: $_tdee kcal). Sincronizado con el lente.',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Top App Bar Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Brand Logo NIA & Title
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'NIA',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'PERFIL',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                            color: AppColors.textPrimary,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),

                    // Quick Settings Icon
                    IconButton(
                      icon: const Icon(
                        Icons.settings_outlined,
                        color: AppColors.textPrimary,
                        size: 24,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 44,
                        minHeight: 44,
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Configuración avanzada del sistema'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Profile Main Body
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 6),

                  // Profile Header Card (Avatar, Name, PRO, Stats)
                  _buildProfileHeaderCard(theme),

                  const SizedBox(height: 18),

                  // Intelligent Metabolic Calculation Card
                  _buildMetabolicEngineCard(theme),

                  const SizedBox(height: 18),

                  // Biometric Data Card with dynamic adjustments
                  BiometricCard(
                    currentWeight: _currentWeight,
                    targetWeight: _targetWeight,
                    age: _age,
                    height: _height,
                    gender: _gender,
                    activityFactor: _activityFactor,
                    onCurrentWeightChanged: (val) =>
                        setState(() => _currentWeight = val),
                    onTargetWeightChanged: (val) =>
                        setState(() => _targetWeight = val),
                    onAgeChanged: (val) => setState(() => _age = val),
                    onHeightChanged: (val) => setState(() => _height = val),
                    onGenderChanged: (val) => setState(() => _gender = val),
                    onActivityFactorChanged: (val) =>
                        setState(() => _activityFactor = val),
                  ),

                  const SizedBox(height: 18),

                  // Macro Distribution Group with 100% preservation
                  MacroSliderGroup(
                    totalCalories: _targetDailyCalories,
                    initialCarbPercent: _carbPercent,
                    initialProteinPercent: _proteinPercent,
                    initialFatPercent: _fatPercent,
                    onMacrosChanged: (c, p, f) {
                      _carbPercent = c;
                      _proteinPercent = p;
                      _fatPercent = f;
                    },
                  ),

                  const SizedBox(height: 18),

                  // Automation & AI Toggles Card
                  _buildAutomationAndAICard(theme),

                  const SizedBox(height: 22),

                  // Primary CTA Button: Save & Recalculate
                  _buildSaveAndRecalculateButton(theme),

                  const SizedBox(height: 36),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Header profile card with user avatar, name, PRO badge and streak/progress stats.
  Widget _buildProfileHeaderCard(ThemeData theme) {
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
        children: [
          // User Details Row
          Row(
            children: [
              // Avatar with online status
              Stack(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary,
                        width: 2.5,
                      ),
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=200&q=80',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),

              // Name, PRO Badge and Subtitles
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'Sofía Martínez',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              fontSize: 18,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'PRO',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 10,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '• Nivel Activo • Plan Déficit Saludable',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 14),

          // Stats Row: Racha, Progreso, Adherencia
          Row(
            mainAxisAlignment: spaceAround(),
            children: [
              _buildStatColumn('Racha', '14d', '🔥 Constancia'),
              _buildStatDivider(),
              _buildStatColumn('Progreso', '-3.2 kg', '📉 Grasa'),
              _buildStatDivider(),
              _buildStatColumn('Adherencia', '94%', '🎯 Precisión'),
            ],
          ),
        ],
      ),
    );
  }

  static MainAxisAlignment spaceAround() => MainAxisAlignment.spaceAround;

  Widget _buildStatColumn(String label, String value, String sub) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          sub,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 34,
      color: AppColors.divider,
    );
  }

  /// Intelligent Metabolic Calculation Card (NutriLens Bioadaptive Engine).
  Widget _buildMetabolicEngineCard(ThemeData theme) {
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
          // Header: Engine title & LIVE badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.bolt_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Cálculo Metabólico Inteligente',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryMint,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryBorder, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'VIVO',
                      style: TextStyle(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),
          Text(
            'Motor Bioadaptativo NutriLens',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 16),

          // Calorie Target Box with interactive plan selector
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryMint.withValues(alpha: 0.6),
                  AppColors.surfaceMuted,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primaryBorder, width: 1),
            ),
            child: Column(
              children: [
                Text(
                  'Meta calórica diaria recomendada',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$_targetDailyCalories',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w900,
                        fontSize: 34,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'kcal / día',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Interactive Plan Selector: < Déficit moderado óptimo (-15%) >
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border, width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Semantics(
                        button: true,
                        label: 'Plan anterior',
                        child: IconButton(
                          icon: const Icon(Icons.chevron_left_rounded, size: 20),
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                          onPressed: _previousPlan,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          _currentPlan.label,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Semantics(
                        button: true,
                        label: 'Plan siguiente',
                        child: IconButton(
                          icon: const Icon(Icons.chevron_right_rounded, size: 20),
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                          onPressed: _nextPlan,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Two Metrics: TDEE Estimado & Ajuste de Déficit
          Row(
            children: [
              // TDEE Estimado
              Expanded(
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
                      Text(
                        'TDEE Estimado',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$_tdee kcal',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Gasto Total Diario',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Ajuste de Déficit
              Expanded(
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
                      Text(
                        'Ajuste de Déficit',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '-$_deficitAdjustmentCalories kcal',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Pérdida ~0.45 kg/sem',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Real-time synchronization text
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.sync_rounded,
                size: 15,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'El motor bioadaptativo recalculó tu BMR en $_bmr kcal usando '
                  'la fórmula clínica Mifflin-St Jeor y lo sincroniza en tiempo real.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Automation & AI Settings card with switches.
  Widget _buildAutomationAndAICard(ThemeData theme) {
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
          Row(
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Automatización & IA',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Switch 1: Recordatorios de comida
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recordatorios de comida',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Alertas inteligentes para mantener el ritmo metabólico',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: _mealReminders,
                activeTrackColor: AppColors.primary,
                onChanged: (val) => setState(() => _mealReminders = val),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 12),

          // Switch 2: Compensación metabólica IA
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Compensación metabólica IA',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Ajusta calorías del día según el gasto de actividad física real',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: _aiMetabolicCompensation,
                activeTrackColor: AppColors.primary,
                onChanged: (val) =>
                    setState(() => _aiMetabolicCompensation = val),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Primary action button: Save & Recalculate Goals.
  Widget _buildSaveAndRecalculateButton(ThemeData theme) {
    return Semantics(
      button: true,
      label: 'Guardar y Recalcular Metas',
      hint: 'Tus objetivos se sincronizan al instante con el lente fotográfico',
      child: InkWell(
        onTap: _saveAndRecalculate,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Guardar y Recalcular Metas',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Tus objetivos se sincronizan al instante con el lente fotográfico.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
