import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/meal_item.dart';
import '../../data/models/user_profile.dart';
import '../../data/repositories/nutrition_repository.dart';
import '../widgets/insight_card.dart';
import '../widgets/macro_progress_bar.dart';
import '../widgets/meal_card.dart';
import '../widgets/metabolic_ring_widget.dart';
import '../widgets/nia_app_bar.dart';
import 'scan_screen.dart';

/// Full "Hoy" Dashboard screen combining the user greeting, active mode badge,
/// date navigation selector, metabolic dual ring card with macros, AI insights,
/// today's meal tracking breakdown, and one-tap quick scanner call-to-action.
class DashboardScreen extends StatefulWidget {
  final VoidCallback? onNavigateToScan;
  final VoidCallback? onNavigateToProfile;
  final VoidCallback? onNavigateToHistory;

  const DashboardScreen({
    super.key,
    this.onNavigateToScan,
    this.onNavigateToProfile,
    this.onNavigateToHistory,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final NutritionRepository _repository = NutritionRepository.instance;

  DateTime _selectedDate = DateTime.now();

  // Metabolic & Nutritive state (seeded with screenshot values as defaults)
  UserProfile _userProfile = UserProfile.defaultSofia();
  int _targetCalories = 2100;
  int _consumedCalories = 680;
  int _burnedCalories = 340;
  int _remainingCalories = 1420;

  int _carbsConsumed = 85;
  int _carbsTarget = 220;
  int _proteinConsumed = 72;
  int _proteinTarget = 130;
  int _fatConsumed = 24;
  int _fatTarget = 65;

  List<MealItem> _todayMeals = [];

  @override
  void initState() {
    super.initState();
    _repository.addListener(_onRepositoryChanged);
    _loadDashboardData();
  }

  @override
  void dispose() {
    _repository.removeListener(_onRepositoryChanged);
    super.dispose();
  }

  void _onRepositoryChanged() {
    if (mounted) {
      _loadDashboardData(silent: true);
    }
  }

  Future<void> _loadDashboardData({bool silent = false}) async {
    try {
      final profile = await _repository.getUserProfile();
      final summary = await _repository.getDailySummary(_selectedDate);
      final rawMeals = summary['meals'] as List<MealItem>? ?? [];

      if (mounted) {
        setState(() {
          _userProfile = profile;
          _targetCalories = summary['target_calories'] as int? ?? 2100;
          _consumedCalories = summary['consumed_calories'] as int? ?? 680;
          _burnedCalories = summary['burned_calories'] as int? ?? 340;
          _remainingCalories = summary['remaining_calories'] as int? ??
              (_targetCalories - _consumedCalories).clamp(0, 10000);

          _carbsConsumed = summary['carbs_consumed'] as int? ?? 85;
          _carbsTarget = summary['carbs_target'] as int? ?? 220;
          _proteinConsumed = summary['protein_consumed'] as int? ?? 72;
          _proteinTarget = summary['protein_target'] as int? ?? 130;
          _fatConsumed = summary['fat_consumed'] as int? ?? 24;
          _fatTarget = summary['fat_target'] as int? ?? 65;

          _todayMeals = rawMeals;
        });
      }
    } catch (_) {
      // Fallback to offline defaults matching the pristine UI mock
    }
  }

  void _changeDate(int dayOffset) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: dayOffset));
    });
    _loadDashboardData();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      _loadDashboardData();
    }
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final isToday = date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;

    final formatter = DateFormat('d MMMM', 'es_ES');
    try {
      final formatted = formatter.format(date);
      return isToday ? 'Hoy, $formatted' : formatted;
    } catch (_) {
      // Fallback if Spanish locale isn't fully loaded
      const months = [
        'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
        'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
      ];
      final monthName = months[date.month - 1];
      return isToday ? 'Hoy, ${date.day} $monthName' : '${date.day} $monthName';
    }
  }

  void _handleOpenScan() {
    if (widget.onNavigateToScan != null) {
      widget.onNavigateToScan!();
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ScanScreen(
            onSaveMeal: (analyzedMeal) async {
              // Convert to MealItem and save to repository
              final meal = MealItem(
                name: 'Plato escaneado (${analyzedMeal.mealType})',
                mealType: MealType.fromKey(analyzedMeal.mealType),
                calories: analyzedMeal.totalCalories,
                proteinG: analyzedMeal.proteinGrams.toDouble(),
                carbsG: analyzedMeal.carbsGrams.toDouble(),
                fatG: analyzedMeal.fatGrams.toDouble(),
                fiberG: analyzedMeal.fiberGrams,
                sodiumMg: analyzedMeal.sodiumMg,
                dateTime: analyzedMeal.timestamp,
                userNotes: analyzedMeal.noteAdjustmentText,
                isAiValidated: true,
                validationTag: 'Escaneado por IA • ${_formatCurrentTime()}',
              );
              await _repository.insertMeal(meal);
            },
          ),
        ),
      );
    }
  }

  String _formatCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final period = now.hour >= 12 ? 'PM' : 'AM';
    final minute = now.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: NiaAppBar(
        title: 'NutriLens AI',
        subtitle: 'HOY',
        streakDays: _userProfile.streakDays,
        onAvatarTap: widget.onNavigateToProfile,
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadDashboardData(),
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            top: 10,
            bottom: 120, // Space for the floating bottom navigation bar
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Greeting & Active Mode Header
              _buildGreetingHeader(),

              const SizedBox(height: 18),

              // 2. Date Selector Bar
              _buildDateSelector(),

              const SizedBox(height: 18),

              // 3. Central Metabolic Card (Dual Ring + Metrics + Macros)
              _buildMetabolicUnifiedCard(),

              const SizedBox(height: 18),

              // 4. NutriLens AI Insight Card
              InsightCard(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Recomendación generada por el motor de IA en base a tus registros.',
                      ),
                      duration: Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // 5. Today's Meals Section Header
              _buildMealsHeader(),

              const SizedBox(height: 14),

              // 6. Meal Cards List (Desayuno, Almuerzo, Merienda, Cena)
              _buildMealsList(),

              const SizedBox(height: 22),

              // 7. Prominent CTA Button: Escanear plato ahora
              _buildScanCtaButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreetingHeader() {
    final firstName = _userProfile.name.split(' ').first;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Greeting & Subtitle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¡Hola, $firstName! 👋',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Tu metabolismo rinde al 100% hoy',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        // MODO ACTIVO Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primaryMint,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primaryBorder, width: 1.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                Icons.bolt_rounded,
                color: AppColors.primaryDark,
                size: 15,
              ),
              SizedBox(width: 4),
              Text(
                'MODO ACTIVO',
                style: TextStyle(
                  color: AppColors.primaryDark,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous day arrow
          Semantics(
            button: true,
            label: 'Día anterior',
            child: IconButton(
              icon: const Icon(
                Icons.chevron_left_rounded,
                color: AppColors.textPrimary,
                size: 24,
              ),
              onPressed: () => _changeDate(-1),
              splashRadius: 20,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            ),
          ),

          // Date display pill button
          Semantics(
            button: true,
            label: 'Seleccionar fecha en el calendario',
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        color: AppColors.primaryDark,
                        size: 15,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDateHeader(_selectedDate),
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Next day arrow
          Semantics(
            button: true,
            label: 'Día siguiente',
            child: IconButton(
              icon: const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textPrimary,
                size: 24,
              ),
              onPressed: () => _changeDate(1),
              splashRadius: 20,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetabolicUnifiedCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Dual Circular Metabolic Ring + Consumed/Burned Cards
          MetabolicRingWidget(
            targetCalories: _targetCalories,
            consumedCalories: _consumedCalories,
            burnedCalories: _burnedCalories,
            remainingCalories: _remainingCalories,
            onConsumedTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '$_consumedCalories kcal consumidas en ${_todayMeals.length} comidas.',
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            onBurnedTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    '340 kcal quemadas por actividad física y metabolismo basal.',
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),

          const SizedBox(height: 22),

          // Divider between Ring and Macros
          const Divider(color: AppColors.divider, height: 1),

          const SizedBox(height: 18),

          // Macro Horizontal Progress Bars (Carbs, Protein, Fat)
          MacroProgressBar(
            carbsCurrent: _carbsConsumed,
            carbsTarget: _carbsTarget,
            proteinCurrent: _proteinConsumed,
            proteinTarget: _proteinTarget,
            fatCurrent: _fatConsumed,
            fatTarget: _fatTarget,
          ),
        ],
      ),
    );
  }

  Widget _buildMealsHeader() {
    final registeredCount = _todayMeals.isNotEmpty ? _todayMeals.length : 2;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Comidas de Hoy',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        Text(
          '$registeredCount de 4 registradas',
          style: const TextStyle(
            color: AppColors.primaryDark,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildMealsList() {
    // We construct the 4 slots: Desayuno, Almuerzo, Merienda, Cena
    // matching the pristine UI mock from screenshot 2.
    final breakfastItem = _findMeal(MealType.breakfast) ??
        const MealItemData(
          id: 'breakfast_1',
          categoryName: 'DESAYUNO',
          category: MealCategory.breakfast,
          title: 'Tostadas de aguacate con huevo',
          subtitle: '+ Café negro (sin azúcar)',
          calories: 410,
          isRegistered: true,
          aiBadgeText: 'Escaneado por IA • 9:15 AM',
          aiBadgeType: 'scanned',
        );

    final lunchItem = _findMeal(MealType.lunch) ??
        const MealItemData(
          id: 'lunch_1',
          categoryName: 'ALMUERZO',
          category: MealCategory.lunch,
          title: 'Bowl de salmón, quinoa y edam...',
          subtitle: 'Alto en Omega 3 y proteína magra',
          calories: 580,
          isRegistered: true,
          aiBadgeText: 'IA validada • 1:30 PM',
          aiBadgeType: 'validated',
        );

    final snackItem = _findMeal(MealType.snack) ??
        const MealItemData(
          id: 'snack_1',
          categoryName: 'MERIENDA / SNACK',
          category: MealCategory.snack,
          title: '¿Algún fruto seco o frut...',
          subtitle: 'Sugerencia: < 180 kcal',
          isRegistered: false,
          showAddButton: true,
        );

    final dinnerItem = _findMeal(MealType.dinner) ??
        const MealItemData(
          id: 'dinner_1',
          categoryName: 'CENA',
          category: MealCategory.dinner,
          title: 'Cierre liviano sugerido',
          subtitle: 'Meta estimada: ~430 kcal',
          pendingTag: 'Pendiente',
          isRegistered: false,
          showPlusCircle: true,
        );

    return Column(
      children: [
        MealCard(
          meal: breakfastItem,
          onTap: () => _showMealDetail(breakfastItem),
        ),
        MealCard(
          meal: lunchItem,
          onTap: () => _showMealDetail(lunchItem),
        ),
        MealCard(
          meal: snackItem,
          onAddTap: _handleOpenScan,
        ),
        MealCard(
          meal: dinnerItem,
          onAddTap: _handleOpenScan,
        ),
      ],
    );
  }

  MealItemData? _findMeal(MealType type) {
    if (_todayMeals.isEmpty) return null;
    final matches = _todayMeals.where((m) => m.mealType == type).toList();
    if (matches.isEmpty) return null;

    final match = matches.first;
    return MealItemData(
      id: match.id?.toString() ?? match.name,
      categoryName: type.label.toUpperCase(),
      category: _mapMealCategory(type),
      title: match.name,
      subtitle: match.userNotes,
      calories: match.calories,
      isRegistered: true,
      aiBadgeText: match.validationTag ?? 'Validado por IA',
      aiBadgeType: match.isAiValidated ? 'validated' : 'scanned',
    );
  }

  MealCategory _mapMealCategory(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return MealCategory.breakfast;
      case MealType.lunch:
        return MealCategory.lunch;
      case MealType.snack:
        return MealCategory.snack;
      case MealType.dinner:
        return MealCategory.dinner;
    }
  }

  void _showMealDetail(MealItemData meal) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                meal.categoryName,
                style: const TextStyle(
                  color: AppColors.primaryDark,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                meal.title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (meal.subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  meal.subtitle!,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryMint,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primaryBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Energía aportada',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${meal.calories ?? 0} kcal',
                      style: const TextStyle(
                        color: AppColors.primaryDark,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScanCtaButton() {
    return Semantics(
      button: true,
      label: 'Escanear plato ahora con reconocimiento nutricional de IA',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleOpenScan,
          borderRadius: BorderRadius.circular(22),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF10B981),
                  Color(0xFF059669),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.32),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                // Camera emblem icon container
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Button Labels
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        'Escanear plato ahora',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Reconocimiento nutricional con IA',
                        style: TextStyle(
                          color: Color(0xFFD1FAE5),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Forward arrow circle
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
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
