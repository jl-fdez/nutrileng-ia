import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/week_calendar_strip.dart';
import '../widgets/weekly_calorie_chart.dart';

/// Meal item model for the history feed.
class HistoryMealItem {
  final String id;
  final String title;
  final String category; // 'Desayuno', 'Almuerzo', 'Cena', 'Snack'
  final String time;
  final int calories;
  final int proteinGrams;
  final int carbGrams;
  final int fatGrams;
  final String? userNote;
  final IconData icon;

  const HistoryMealItem({
    required this.id,
    required this.title,
    required this.category,
    required this.time,
    required this.calories,
    required this.proteinGrams,
    required this.carbGrams,
    required this.fatGrams,
    this.userNote,
    this.icon = Icons.restaurant_rounded,
  });
}

/// Service class handling PDF generation and export for nutritional reports.
class PdfExportService {
  static Future<void> exportNutritionalReport({
    required BuildContext context,
    required String userName,
    required String dateRange,
    required int dailyAverageCalories,
    required int totalDeficit,
    required List<HistoryMealItem> meals,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context pdfContext) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'NutriLens AI',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromInt(0xFF10B981),
                        ),
                      ),
                      pw.Text(
                        'Reporte Nutricional Clínico y Metabólico',
                        style: const pw.TextStyle(
                          fontSize: 12,
                          color: PdfColor.fromInt(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromInt(0xFFE8FDF5),
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Text(
                      dateRange,
                      style: pw.TextStyle(
                        color: PdfColor.fromInt(0xFF059669),
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 18),
              pw.Divider(color: PdfColor.fromInt(0xFFE2E8F0)),
              pw.SizedBox(height: 14),

              // Patient / User Bio
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Usuario: $userName',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  pw.Text(
                    'Plan: Déficit Saludable (-15%)',
                    style: const pw.TextStyle(
                      fontSize: 12,
                      color: PdfColor.fromInt(0xFF64748B),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 16),

              // KPI Cards
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromInt(0xFFF8FAFC),
                        borderRadius: pw.BorderRadius.circular(8),
                        border: pw.Border.all(
                          color: PdfColor.fromInt(0xFFE2E8F0),
                        ),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'PROMEDIO DIARIO',
                            style: const pw.TextStyle(
                              fontSize: 9,
                              color: PdfColor.fromInt(0xFF64748B),
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            '$dailyAverageCalories kcal/día',
                            style: pw.TextStyle(
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColor.fromInt(0xFF0F172A),
                            ),
                          ),
                          pw.Text(
                            'Óptimo para tu meta',
                            style: const pw.TextStyle(
                              fontSize: 9,
                              color: PdfColor.fromInt(0xFF059669),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 12),
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromInt(0xFFF8FAFC),
                        borderRadius: pw.BorderRadius.circular(8),
                        border: pw.Border.all(
                          color: PdfColor.fromInt(0xFFE2E8F0),
                        ),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'DÉFICIT LOGRADO',
                            style: const pw.TextStyle(
                              fontSize: 9,
                              color: PdfColor.fromInt(0xFF64748B),
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            '-$totalDeficit kcal',
                            style: pw.TextStyle(
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColor.fromInt(0xFF059669),
                            ),
                          ),
                          pw.Text(
                            '~0.32 kg tejido graso quemado',
                            style: const pw.TextStyle(
                              fontSize: 9,
                              color: PdfColor.fromInt(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 20),
              pw.Text(
                'Registro Detallado de Comidas',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromInt(0xFF0F172A),
                ),
              ),
              pw.SizedBox(height: 10),

              // Table of meals
              pw.TableHelper.fromTextArray(
                headers: [
                  'Comida',
                  'Momento',
                  'Calorías',
                  'Proteínas',
                  'Carbos',
                  'Grasas',
                  'Notas de Usuario'
                ],
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 9,
                  color: PdfColor.fromInt(0xFF0F172A),
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFFF1F5F9),
                ),
                cellStyle: const pw.TextStyle(fontSize: 8),
                cellPadding: const pw.EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 6,
                ),
                data: meals.map((m) {
                  return [
                    m.title,
                    '${m.category} (${m.time})',
                    '${m.calories} kcal',
                    '${m.proteinGrams}g',
                    '${m.carbGrams}g',
                    '${m.fatGrams}g',
                    m.userNote ?? '-',
                  ];
                }).toList(),
              ),

              pw.Spacer(),
              pw.Divider(color: PdfColor.fromInt(0xFFE2E8F0)),
              pw.SizedBox(height: 6),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Generado automáticamente por NutriLens AI Bioadaptive Engine',
                    style: const pw.TextStyle(
                      fontSize: 8,
                      color: PdfColor.fromInt(0xFF94A3B8),
                    ),
                  ),
                  pw.Text(
                    'Página 1 de 1',
                    style: const pw.TextStyle(
                      fontSize: 8,
                      color: PdfColor.fromInt(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'NutriLens_Reporte_Nutricional.pdf',
    );
  }
}

/// History screen displaying the weekly calendar strip, weekly balance stats,
/// calorie comparison bar chart, filterable meal feed, and PDF export.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedCategory = 'Todos';

  final List<String> _categories = [
    'Todos (18)',
    'Desayuno',
    'Almuerzo',
    'Cena',
  ];

  final List<HistoryMealItem> _allMeals = const [
    HistoryMealItem(
      id: '1',
      title: 'Bowl de Salmón & Quinoa',
      category: 'Almuerzo',
      time: '1:30 PM',
      calories: 540,
      proteinGrams: 38,
      carbGrams: 45,
      fatGrams: 18,
      userNote: 'Sin aderezos pesados, vinagreta ligera.',
      icon: Icons.set_meal_rounded,
    ),
    HistoryMealItem(
      id: '2',
      title: 'Avena con Frutos Rojos y Chía',
      category: 'Desayuno',
      time: '8:15 AM',
      calories: 320,
      proteinGrams: 14,
      carbGrams: 52,
      fatGrams: 8,
      userNote: 'Café negro sin azúcar.',
      icon: Icons.breakfast_dining_rounded,
    ),
    HistoryMealItem(
      id: '3',
      title: 'Pechuga Grillé con Vegetales al Vapor',
      category: 'Cena',
      time: '8:45 PM',
      calories: 420,
      proteinGrams: 46,
      carbGrams: 18,
      fatGrams: 12,
      userNote: 'Cocinada con aceite en spray y sal marina.',
      icon: Icons.dinner_dining_rounded,
    ),
    HistoryMealItem(
      id: '4',
      title: 'Yogurt Griego con Almendras y Canela',
      category: 'Desayuno',
      time: '11:00 AM',
      calories: 210,
      proteinGrams: 20,
      carbGrams: 12,
      fatGrams: 9,
      userNote: 'Sin miel extra, canela ceilán pura.',
      icon: Icons.bakery_dining_rounded,
    ),
    HistoryMealItem(
      id: '5',
      title: 'Tarta de Espinacas y Queso Ricotta',
      category: 'Almuerzo',
      time: '2:15 PM',
      calories: 350,
      proteinGrams: 18,
      carbGrams: 30,
      fatGrams: 14,
      userNote: 'Masa integral fina horneada.',
      icon: Icons.lunch_dining_rounded,
    ),
  ];

  List<HistoryMealItem> get _filteredMeals {
    if (_selectedCategory.startsWith('Todos')) {
      return _allMeals;
    }
    return _allMeals
        .where((m) => m.category.toLowerCase() == _selectedCategory.toLowerCase())
        .toList();
  }

  void _exportReport() {
    PdfExportService.exportNutritionalReport(
      context: context,
      userName: 'Sofía Martínez',
      dateRange: '12 - 18 MAY 2026',
      dailyAverageCalories: 1840,
      totalDeficit: 2450,
      meals: _allMeals,
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
            // Top App Bar / Header
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
                          'HISTORIAL',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                            color: AppColors.textPrimary,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),

                    // Streak, Notification Bell, User Avatar
                    Row(
                      children: [
                        // Streak Badge 🔥 7d
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.burnOrangeLight,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.burnOrange.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: const [
                              Text('🔥', style: TextStyle(fontSize: 13)),
                              SizedBox(width: 4),
                              Text(
                                '7d',
                                style: TextStyle(
                                  color: AppColors.burnOrange,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Notification Bell
                        Stack(
                          children: [
                            Semantics(
                              button: true,
                              label: 'Notificaciones',
                              child: IconButton(
                                icon: const Icon(
                                  Icons.notifications_none_rounded,
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
                                      content: Text('No hay nuevas alertas'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Positioned(
                              right: 10,
                              top: 10,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Avatar
                        const SizedBox(width: 4),
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary,
                              width: 2,
                            ),
                            image: const DecorationImage(
                              image: NetworkImage(
                                'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=120&q=80',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Content Sections
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 6),

                  // Week Calendar Strip
                  const WeekCalendarStrip(
                    weekLabel: 'Semana Actual',
                    dateRangeBadge: '12 - 18 MAY',
                  ),

                  const SizedBox(height: 16),

                  // Weekly Balance Cards & 7-day streak
                  _buildWeeklyBalanceSection(theme),

                  const SizedBox(height: 16),

                  // Weekly Calorie Bar Chart
                  const WeeklyCalorieChart(
                    calorieTarget: 2000,
                  ),

                  const SizedBox(height: 24),

                  // Meal Feed Header & Filter Chips
                  _buildFeedHeaderAndChips(theme),

                  const SizedBox(height: 14),

                  // Meal Feed Cards
                  ..._filteredMeals.map((meal) => _buildMealCard(theme, meal)),

                  const SizedBox(height: 20),

                  // PDF Export Button
                  _buildExportPdfButton(theme),

                  const SizedBox(height: 32),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Weekly Balance summary cards and streak badge.
  Widget _buildWeeklyBalanceSection(ThemeData theme) {
    return Column(
      children: [
        // 7-day streak announcement badge
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                AppColors.primaryMint,
                AppColors.surface,
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primaryBorder, width: 1),
          ),
          child: Row(
            children: [
              const Text('🎉', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '¡7 días en racha completados! Mantén el ritmo.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  '7 / 7',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Balance 2-column cards
        Row(
          children: [
            // Daily Average
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Promedio diario',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '1,840',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                      ),
                    ),
                    Text(
                      'kcal / día',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 13,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Óptimo para tu meta',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Deficit Achieved
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Déficit logrado',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '-2,450',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                      ),
                    ),
                    Text(
                      'kcal acumuladas',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.local_fire_department_rounded,
                          size: 13,
                          color: AppColors.burnOrange,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '~0.32 kg quemados',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.burnOrange,
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Meal feed header with title and category chips.
  Widget _buildFeedHeaderAndChips(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Comidas Registradas',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                fontSize: 17,
              ),
            ),
            Text(
              '${_filteredMeals.length} registros',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: _categories.map((category) {
              final isSelected = _selectedCategory == category ||
                  (_selectedCategory.startsWith('Todos') &&
                      category.startsWith('Todos'));

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Semantics(
                  button: true,
                  selected: isSelected,
                  label: 'Filtrar por $category',
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    backgroundColor: AppColors.surface,
                    selectedColor: AppColors.primary,
                    checkmarkColor: Colors.white,
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primaryDark
                          : AppColors.border,
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w600,
                      fontSize: 12,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  /// Meal item card with macro badges and clarifying user notes bubble.
  Widget _buildMealCard(ThemeData theme, HistoryMealItem meal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Icon / photo placeholder, Title, Calories and Time
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryMint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  meal.icon,
                  color: AppColors.primaryDark,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          meal.category,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '•  ${meal.time}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${meal.calories} kcal',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Macro badges row
          Row(
            children: [
              _buildMacroBadge(
                'Proteínas',
                '${meal.proteinGrams}g',
                AppColors.protein,
                AppColors.proteinLight,
              ),
              const SizedBox(width: 8),
              _buildMacroBadge(
                'Carbos',
                '${meal.carbGrams}g',
                AppColors.carbs,
                AppColors.carbsLight,
              ),
              const SizedBox(width: 8),
              _buildMacroBadge(
                'Grasas',
                '${meal.fatGrams}g',
                AppColors.fat,
                AppColors.fatLight,
              ),
            ],
          ),

          // Clarifying note bubble
          if (meal.userNote != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.8),
                  width: 0.8,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('💬 ', style: TextStyle(fontSize: 12)),
                  Expanded(
                    child: Text(
                      meal.userNote!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMacroBadge(
    String label,
    String amount,
    Color color,
    Color bgColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            '$label $amount',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// PDF Export Call-to-Action button with micronutrient subtext.
  Widget _buildExportPdfButton(ThemeData theme) {
    return Semantics(
      button: true,
      label: 'Exportar reporte nutricional en PDF',
      hint: 'Incluye desglose de micronutrientes y gráficos exportables',
      child: InkWell(
        onTap: _exportReport,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0F172A),
                Color(0xFF1E293B),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.picture_as_pdf_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📄 Exportar reporte nutricional en PDF',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Incluye desglose de micronutrientes y gráficos exportables',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
