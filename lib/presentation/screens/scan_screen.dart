import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/camera_scanner_view.dart';
import '../widgets/food_tag_pin.dart';
import '../widgets/nutrition_bottom_sheet.dart';
import '../widgets/quick_chip_group.dart';

/// Screen representing the AI Food Scanner & Plate Analysis ("Escanear")
class ScanScreen extends StatefulWidget {
  final Future<void> Function(NutritionAnalysisData meal)? onSaveMeal;

  const ScanScreen({
    super.key,
    this.onSaveMeal,
  });

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  // Tab index: 0 = "📷 Con Foto", 1 = "✍️ Escribir Plato"
  int _selectedTab = 0;

  // Controllers for text fields
  late final TextEditingController _foodDescriptionController;
  late final TextEditingController _notesController;

  final ScrollController _scrollController = ScrollController();

  // Voice dictation state
  bool _isDictating = false;
  Timer? _dictationTimer;

  // Active pins for the scanner
  late List<FoodTagPinData> _pins;
  String? _selectedPinId;

  // Quick chips selections
  final Set<String> _selectedPortionChips = {};
  final Set<String> _selectedNoteChips = {'+ Sin azúcar'};

  // Dynamic nutrition values
  int _baseCalories = 585;
  int _noteAdjustmentDiff = -65;
  bool _hasNoteAdjustment = true;

  @override
  void initState() {
    super.initState();

    _foodDescriptionController = TextEditingController(
      text:
          'Pechuga de pollo a la plancha 180g, ensalada fresca de lechuga, tomate y pepino, café tostado',
    );

    _notesController = TextEditingController(
      text:
          'El café es completamente sin azúcar. El aderezo de la ensalada es solo vinagre',
    );

    _pins = const [
      FoodTagPinData(
        id: 'pin_coffee',
        name: 'Café tostado',
        portion: 'Taza 200ml',
        calories: 15,
        relativeX: 0.16,
        relativeY: 0.18,
        accentColor: Color(0xFFF59E0B),
      ),
      FoodTagPinData(
        id: 'pin_chicken',
        name: 'Pechuga plancha ~180g',
        portion: '180g',
        calories: 297,
        relativeX: 0.40,
        relativeY: 0.45,
        accentColor: AppColors.primary,
      ),
      FoodTagPinData(
        id: 'pin_salad',
        name: 'Ensalada fresca',
        portion: 'Plato mediano',
        calories: 208,
        relativeX: 0.64,
        relativeY: 0.60,
        accentColor: Color(0xFF10B981),
      ),
    ];
  }

  @override
  void dispose() {
    _dictationTimer?.cancel();
    _foodDescriptionController.dispose();
    _notesController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _recalculateCalories() {
    int adjustment = 0;
    bool hasActiveAdjustment = false;

    final notesLower = _notesController.text.toLowerCase();
    if (_selectedNoteChips.contains('+ Sin azúcar') ||
        notesLower.contains('sin azúcar') ||
        notesLower.contains('sin endulzante')) {
      adjustment -= 65;
      hasActiveAdjustment = true;
    }

    if (_selectedNoteChips.contains('+ Sin aceite') ||
        notesLower.contains('sin aceite') ||
        notesLower.contains('solo vinagre')) {
      adjustment -= 45;
      hasActiveAdjustment = true;
    }

    if (_selectedNoteChips.contains('+ Leche descremada') ||
        notesLower.contains('descremada')) {
      adjustment -= 30;
      hasActiveAdjustment = true;
    }

    int extraPortions = 0;
    if (_selectedPortionChips.contains('+ 1 Porción (150g)')) {
      extraPortions += 150;
    }
    if (_selectedPortionChips.contains('+ 1 Taza')) {
      extraPortions += 80;
    }
    if (_selectedPortionChips.contains('+ Sin aderezo')) {
      extraPortions -= 50;
    }

    setState(() {
      _hasNoteAdjustment = hasActiveAdjustment;
      _noteAdjustmentDiff = adjustment;
      _baseCalories = 585 + extraPortions;
    });
  }

  void _toggleDictation() {
    if (_isDictating) {
      _dictationTimer?.cancel();
      setState(() {
        _isDictating = false;
      });
      return;
    }

    setState(() {
      _isDictating = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.mic, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('NutriVoice IA escuchando... "Pechuga plancha con ensalada"'),
          ],
        ),
        backgroundColor: AppColors.primaryDark,
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );

    _dictationTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isDictating = false;
        });
      }
    });
  }

  void _handlePortionChipTapped(QuickChipItem item) {
    setState(() {
      if (_selectedPortionChips.contains(item.label)) {
        _selectedPortionChips.remove(item.label);
      } else {
        _selectedPortionChips.add(item.label);
      }
    });
    _recalculateCalories();
  }

  void _handleNoteChipTapped(QuickChipItem item) {
    setState(() {
      if (_selectedNoteChips.contains(item.label)) {
        _selectedNoteChips.remove(item.label);
      } else {
        _selectedNoteChips.add(item.label);
        // Append note if not present
        final textToAdd = item.label.replaceAll('+ ', '');
        if (!_notesController.text.contains(textToAdd)) {
          if (_notesController.text.isNotEmpty &&
              !_notesController.text.endsWith('. ') &&
              !_notesController.text.endsWith('.')) {
            _notesController.text += '. ';
          }
          _notesController.text += '$textToAdd.';
        }
      }
    });
    _recalculateCalories();
  }

  void _handlePinTapped(FoodTagPinData pin) {
    setState(() {
      _selectedPinId = pin.id;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Alimento seleccionado: ${pin.name} (~${pin.calories} kcal)'),
        backgroundColor: AppColors.textPrimary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleConfirmMeal() async {
    final currentMeal = _buildCurrentNutritionData();

    if (widget.onSaveMeal != null) {
      await widget.onSaveMeal!(currentMeal);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 22),
              const SizedBox(width: 10),
              Text(
                '¡${currentMeal.mealType} (${currentMeal.totalCalories} kcal) guardado con éxito!',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          backgroundColor: AppColors.primaryDark,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );

      // Return to previous screen with recorded meal
      Navigator.of(context).maybePop(currentMeal);
    }
  }

  NutritionAnalysisData _buildCurrentNutritionData() {
    final total = (_baseCalories + (_hasNoteAdjustment ? _noteAdjustmentDiff : 0))
        .clamp(50, 3000);

    return NutritionAnalysisData(
      totalCalories: total,
      baseCalories: _baseCalories,
      proteinGrams: 42,
      carbsGrams: 28,
      fatGrams: 16,
      fiberGrams: 6.0,
      sodiumMg: 340,
      noteAdjustmentText: _hasNoteAdjustment
          ? '✓ Ajustado por tu nota: $_noteAdjustmentDiff kcal por café sin endulzante ni cremas.'
          : null,
      caloriesAdjustedByNote: _hasNoteAdjustment ? _noteAdjustmentDiff : null,
      mealType: 'Almuerzo',
      timestamp: DateTime.now(),
      coachInsight:
          'Excelente elección rica en proteína magra. Te deja un margen ideal de 900 kcal para la cena dentro de tu meta de déficit.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header Bar with Back Button, "Escanear" & NIA Badge
            _buildHeader(context),

            // Top Segmented Mode Selector: [📷 Con Foto] vs [✍️ Escribir Plato]
            _buildSegmentedTabSelector(),

            const SizedBox(height: 12),

            // Main Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Mode 0: Photo & Viewfinder Mode
                    if (_selectedTab == 0) ...[
                      CameraScannerView(
                        pins: _pins,
                        activePinId: _selectedPinId,
                        onPinTapped: _handlePinTapped,
                      ),
                      const SizedBox(height: 14),

                      // Alternative Text Banner
                      _buildAlternativeTextBanner(),
                      const SizedBox(height: 16),
                    ],

                    // Section: Descripción de tu comida & Dictar
                    _buildFoodDescriptionSection(),

                    const SizedBox(height: 16),

                    // Section: Notas y aclaraciones (Ajuste fino IA)
                    _buildNotesSection(),

                    const SizedBox(height: 20),

                    // Nutrition Analysis Panel
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: NutritionBottomSheet(
                        data: _buildCurrentNutritionData(),
                        onConfirm: _handleConfirmMeal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 16, 6),
      child: Row(
        children: [
          // Back Button
          Semantics(
            button: true,
            label: 'Volver atrás',
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Navigator.of(context).maybePop(),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border, width: 1),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Title: "Escanear"
          const Text(
            'Escanear',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(width: 8),

          // NIA Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE8FDF5), Color(0xFFD1FAE5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primaryBorder, width: 1),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  blurRadius: 6,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 13,
                  color: AppColors.primaryDark,
                ),
                SizedBox(width: 3),
                Text(
                  'NIA',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Help / Info icon
          Semantics(
            button: true,
            label: 'Ayuda y guía de escaneo',
            child: IconButton(
              icon: const Icon(
                Icons.help_outline_rounded,
                color: AppColors.textSecondary,
                size: 22,
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'NutriVision reconoce platos, porciones y calcula macros en tiempo real.',
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedTabSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          // Tab 0: 📷 Con Foto
          Expanded(
            child: _buildSegmentButton(
              title: '📷 Con Foto',
              isSelected: _selectedTab == 0,
              showGreenDot: true,
              onTap: () {
                setState(() {
                  _selectedTab = 0;
                });
              },
            ),
          ),

          const SizedBox(width: 4),

          // Tab 1: ✍️ Escribir Plato (con badge IA)
          Expanded(
            child: _buildSegmentButton(
              title: '✍️ Escribir Plato',
              isSelected: _selectedTab == 1,
              showIaBadge: true,
              onTap: () {
                setState(() {
                  _selectedTab = 1;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentButton({
    required String title,
    required bool isSelected,
    bool showGreenDot = false,
    bool showIaBadge = false,
    required VoidCallback onTap,
  }) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: title,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.surface : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (showGreenDot && isSelected) ...[
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary,
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
                if (showIaBadge) ...[
                  const SizedBox(width: 5),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.purpleLight
                          : const Color(0xFFEDE9FE),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'IA',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.purpleDark,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAlternativeTextBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: AppColors.primaryDark,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              '¿Prefieres no tomar foto? Describe tu plato con texto o voz',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _selectedTab = 1;
              });
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              backgroundColor: AppColors.primaryMint,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              '✍️ Escribir',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodDescriptionSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title & "🎙️ Dictar" button
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
                      Icons.restaurant_menu_rounded,
                      size: 18,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Descripción de tu comida',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),

              // Dictation Button
              Semantics(
                button: true,
                label: _isDictating ? 'Detener dictado' : 'Dictar por voz',
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _toggleDictation,
                    borderRadius: BorderRadius.circular(14),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _isDictating
                            ? Colors.red.shade50
                            : AppColors.primaryMint,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _isDictating
                              ? Colors.red.shade200
                              : AppColors.primaryBorder,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isDictating ? Icons.graphic_eq : Icons.mic_rounded,
                            size: 15,
                            color: _isDictating
                                ? Colors.red.shade700
                                : AppColors.primaryDark,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _isDictating ? 'Grabando...' : '🎙️ Dictar',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _isDictating
                                  ? Colors.red.shade700
                                  : AppColors.primaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Editable Text Field
          TextField(
            controller: _foodDescriptionController,
            maxLines: 3,
            onChanged: (val) => _recalculateCalories(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.4,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.surfaceMuted,
              hintText: 'Ej. Pechuga de pollo 180g, ensalada mixta y café...',
              hintStyle: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
              ),
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.border, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.border, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Tag: ⚡ Estimación instantánea IA activa • 3 alimentos reconocidos
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryMint,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryBorder, width: 1),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bolt, size: 15, color: AppColors.primaryDark),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Estimación instantánea IA activa • 3 alimentos reconocidos',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Quick portion chips: "+ 1 Porción (150g)", "+ 1 Taza", "+ Sin aderezo"
          const Text(
            'Porciones rápidas:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          QuickChipGroup(
            scrollable: true,
            padding: EdgeInsets.zero,
            selectedLabels: _selectedPortionChips,
            onChipTapped: _handlePortionChipTapped,
            items: const [
              QuickChipItem(label: '+ 1 Porción (150g)', icon: Icons.add),
              QuickChipItem(label: '+ 1 Taza', icon: Icons.local_cafe_outlined),
              QuickChipItem(label: '+ Sin aderezo', icon: Icons.remove_circle_outline),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Badge: "✨ Considerado en el cálculo"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.purpleLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      size: 18,
                      color: AppColors.purpleDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Notas y aclaraciones',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: AppColors.primaryMint,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.primaryBorder, width: 0.8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, size: 12, color: AppColors.primaryDark),
                    SizedBox(width: 3),
                    Text(
                      'Considerado en el cálculo',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Subtitle
          const Text(
            'Dile a NutriLens los ingredientes invisibles para afinar el cálculo exacto.',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
              height: 1.35,
            ),
          ),

          const SizedBox(height: 12),

          // Notes Field
          TextField(
            controller: _notesController,
            maxLines: 2,
            onChanged: (val) => _recalculateCalories(),
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              height: 1.35,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.surfaceMuted,
              hintText: 'Ej. Café sin azúcar, vinagreta sin aceite...',
              hintStyle: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 12.5,
              ),
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.border, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.border, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Quick notes chips: "+ Sin azúcar", "+ Sin aceite", "+ Leche descremada"
          QuickChipGroup(
            scrollable: true,
            padding: EdgeInsets.zero,
            selectedLabels: _selectedNoteChips,
            onChipTapped: _handleNoteChipTapped,
            activeColor: AppColors.purpleDark,
            activeBackgroundColor: AppColors.purpleLight,
            items: const [
              QuickChipItem(label: '+ Sin azúcar', iconText: '🍃'),
              QuickChipItem(label: '+ Sin aceite', iconText: '💧'),
              QuickChipItem(label: '+ Leche descremada', iconText: '🥛'),
            ],
          ),
        ],
      ),
    );
  }
}
