import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/meal_item.dart';
import '../../data/repositories/nutrition_repository.dart';
import '../widgets/custom_bottom_nav.dart';
import 'dashboard_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import 'scan_screen.dart';

/// Main Shell Scaffold maintaining persistent state across the 4 primary app tabs:
/// - Tab 0: Hoy (DashboardScreen)
/// - Tab 1: Escanear (ScanScreen)
/// - Tab 2: Historial (HistoryScreen)
/// - Tab 3: Perfil (ProfileScreen)
class MainShellScreen extends StatefulWidget {
  final int initialIndex;

  const MainShellScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  late int _currentIndex;
  final NutritionRepository _repository = NutritionRepository.instance;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabSelected(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
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
    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _currentIndex != 0) {
          setState(() {
            _currentIndex = 0;
          });
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        extendBody: true,
        body: IndexedStack(
          index: _currentIndex,
          children: [
            // 0: Hoy (Dashboard)
            DashboardScreen(
              onNavigateToScan: () => _onTabSelected(1),
              onNavigateToHistory: () => _onTabSelected(2),
              onNavigateToProfile: () => _onTabSelected(3),
            ),

            // 1: Escanear (AI Food Scanner)
            ScanScreen(
              onSaveMeal: (analyzedMeal) async {
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

                if (!mounted || !context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${meal.name} registrada exitosamente.',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: AppColors.primaryDark,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );

                // Switch back to Hoy to observe updated metabolic ring
                _onTabSelected(0);
              },
            ),

            // 2: Historial (History & Reports)
            const HistoryScreen(),

            // 3: Perfil (Biometrics & Settings)
            const ProfileScreen(),
          ],
        ),
        bottomNavigationBar: CustomBottomNav(
          currentIndex: _currentIndex,
          onTap: _onTabSelected,
          onScanTap: () => _onTabSelected(1),
        ),
      ),
    );
  }
}
