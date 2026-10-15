import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../data/models/meal_item.dart';
import '../data/models/user_profile.dart';

/// Servicio de exportación e impresión de reportes nutricionales en PDF.
class PdfExportService {
  PdfExportService._();
  static final PdfExportService instance = PdfExportService._();

  /// Genera los bytes del documento PDF con diseño clínico y visual bio-tech
  Future<Uint8List> generateWeeklyReportPdf({
    required UserProfile profile,
    required List<MealItem> weeklyMeals,
    required Map<String, dynamic> metrics,
  }) async {
    final pdf = pw.Document();

    final primaryColor = PdfColor.fromHex('#10B981');
    final darkColor = PdfColor.fromHex('#059669');
    final textDark = PdfColor.fromHex('#0F172A');
    final textSecondary = PdfColor.fromHex('#64748B');
    final bgLight = PdfColor.fromHex('#F7F9FB');
    final borderColor = PdfColor.fromHex('#E2E8F0');

    final avgCalories = metrics['average_calories'] ?? 1840;
    final totalDeficit = metrics['total_deficit'] ?? -2450;
    final kgBurned = metrics['kg_burned'] ?? 0.32;
    final daysData = metrics['days_data'] as List<dynamic>? ?? [];

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) => [
          // 1. Header con marca NIA y título
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: pw.BoxDecoration(
                          color: primaryColor,
                          borderRadius: pw.BorderRadius.circular(6),
                        ),
                        child: pw.Text(
                          'NIA',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      pw.SizedBox(width: 8),
                      pw.Text(
                        'NutriLens AI',
                        style: pw.TextStyle(
                          color: textDark,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Reporte Clínico y Balance Metabólico Semanal',
                    style: pw.TextStyle(color: textSecondary, fontSize: 11),
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'Semana: 12 - 18 Mayo',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      color: textDark,
                      fontSize: 12,
                    ),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    'Emitido: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
                    style: pw.TextStyle(color: textSecondary, fontSize: 10),
                  ),
                ],
              ),
            ],
          ),

          pw.Divider(color: borderColor, thickness: 1, height: 24),

          // 2. Ficha de Usuario y Motor Metabólico (Mifflin-St Jeor)
          pw.Container(
            padding: const pw.EdgeInsets.all(14),
            decoration: pw.BoxDecoration(
              color: bgLight,
              borderRadius: pw.BorderRadius.circular(8),
              border: pw.Border.all(color: borderColor),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      profile.name,
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: textDark,
                      ),
                    ),
                    pw.SizedBox(height: 3),
                    pw.Text(
                      '${profile.age} años • ${profile.gender == 'female' ? 'Femenino' : 'Masculino'} • ${profile.heightCm.toStringAsFixed(0)} cm • ${profile.weightKg} kg',
                      style: pw.TextStyle(color: textSecondary, fontSize: 10),
                    ),
                    pw.Text(
                      'Actividad: ${profile.activityLevelName} (x${profile.activityLevel})',
                      style: pw.TextStyle(color: textSecondary, fontSize: 10),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Plan: ${profile.goalType}',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        color: darkColor,
                        fontSize: 11,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      'TDEE: ${profile.calculateTdee().round()} kcal | Meta: ${profile.calculateTargetCalories()} kcal/día',
                      style: pw.TextStyle(color: textDark, fontSize: 10),
                    ),
                    pw.Text(
                      'Racha: ${profile.streakDays} días | Adherencia: ${profile.adherencePercent}%',
                      style: pw.TextStyle(color: textSecondary, fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 18),

          // 3. Tarjetas de Resumen de Rendimiento
          pw.Text(
            'Rendimiento y Balance Semanal',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: textDark),
          ),
          pw.SizedBox(height: 8),

          pw.Row(
            children: [
              pw.Expanded(
                child: _buildMetricCard(
                  title: 'Promedio Diario',
                  value: '$avgCalories kcal',
                  subtitle: 'Óptimo para tu meta de déficit',
                  borderColor: borderColor,
                  valueColor: primaryColor,
                ),
              ),
              pw.SizedBox(width: 12),
              pw.Expanded(
                child: _buildMetricCard(
                  title: 'Déficit Logrado',
                  value: '$totalDeficit kcal',
                  subtitle: '~${kgBurned.toStringAsFixed(2)} kg de tejido graso quemado',
                  borderColor: borderColor,
                  valueColor: darkColor,
                ),
              ),
              pw.SizedBox(width: 12),
              pw.Expanded(
                child: _buildMetricCard(
                  title: 'Distribución de Macros',
                  value: '${(profile.carbsRatio * 100).toInt()}C / ${(profile.proteinRatio * 100).toInt()}P / ${(profile.fatRatio * 100).toInt()}G',
                  subtitle: '${profile.calculateCarbsGrams()}g C • ${profile.calculateProteinGrams()}g P • ${profile.calculateFatGrams()}g G',
                  borderColor: borderColor,
                  valueColor: textDark,
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 20),

          // 4. Tabla de Consumo Diario de la Semana
          if (daysData.isNotEmpty) ...[
            pw.Text(
              'Consumo Diario vs. Límite Objetivo (2,000 kcal)',
              style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: textDark),
            ),
            pw.SizedBox(height: 8),
            pw.Table(
              border: pw.TableBorder.all(color: borderColor, width: 0.5),
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: bgLight),
                  children: [
                    _tableHeader('Día'),
                    _tableHeader('Fecha'),
                    _tableHeader('Calorías'),
                    _tableHeader('Meta Ref.'),
                    _tableHeader('Estado'),
                  ],
                ),
                ...daysData.map((d) {
                  final cals = d['calories'] as int? ?? 1840;
                  final dayLabel = d['day_label'] as String? ?? 'D';
                  final dayNum = d['day_number'] ?? 0;
                  final isOptimal = cals <= 2000;
                  return pw.TableRow(
                    children: [
                      _tableCell('$dayLabel ($dayNum)'),
                      _tableCell(DateFormat('dd/MM').format(d['date'] as DateTime? ?? DateTime.now())),
                      _tableCell('$cals kcal', isBold: true),
                      _tableCell('2,000 kcal'),
                      _tableCell(
                        isOptimal ? 'Déficit OK' : 'Superávit',
                        color: isOptimal ? primaryColor : PdfColors.orange,
                        isBold: true,
                      ),
                    ],
                  );
                }),
              ],
            ),
            pw.SizedBox(height: 20),
          ],

          // 5. Desglose de Comidas Registradas
          pw.Text(
            'Registro Detallado de Comidas de la Semana',
            style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: textDark),
          ),
          pw.SizedBox(height: 8),

          pw.Table(
            border: pw.TableBorder.all(color: borderColor, width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(2.5),
              1: const pw.FlexColumnWidth(1.5),
              2: const pw.FlexColumnWidth(1.2),
              3: const pw.FlexColumnWidth(1.0),
              4: const pw.FlexColumnWidth(1.0),
              5: const pw.FlexColumnWidth(1.0),
              6: const pw.FlexColumnWidth(3.0),
            },
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(color: bgLight),
                children: [
                  _tableHeader('Plato'),
                  _tableHeader('Tipo / Hora'),
                  _tableHeader('Kcal'),
                  _tableHeader('Prot.'),
                  _tableHeader('Carb.'),
                  _tableHeader('Grasa'),
                  _tableHeader('Notas y Ajustes IA'),
                ],
              ),
              ...weeklyMeals.take(12).map((meal) {
                return pw.TableRow(
                  children: [
                    _tableCell(meal.name, isBold: true),
                    _tableCell('${meal.mealType.label}\n${meal.timeString ?? ''}'),
                    _tableCell('${meal.calories}', isBold: true, color: primaryColor),
                    _tableCell('${meal.proteinG.round()}g'),
                    _tableCell('${meal.carbsG.round()}g'),
                    _tableCell('${meal.fatG.round()}g'),
                    _tableCell(
                      meal.appliedAdjustment
                          ? '${meal.userNotes ?? ''}\n(Ajuste: ${meal.adjustmentCalories} kcal)'
                          : (meal.userNotes ?? '-'),
                    ),
                  ],
                );
              }),
            ],
          ),

          pw.SizedBox(height: 24),

          // 6. Pie de Página y Firma Digital NutriLens AI
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'NutriLens AI (NIA) • Sistema de Nutrición Inteligente y Bioadaptativo',
                style: pw.TextStyle(color: textSecondary, fontSize: 8),
              ),
              pw.Text(
                'Página 1 de 1 • Reporte Oficial Exportado',
                style: pw.TextStyle(color: textSecondary, fontSize: 8),
              ),
            ],
          ),
        ],
      ),
    );

    return await pdf.save();
  }

  /// Despliega el diálogo de impresión / compartir nativo de Flutter
  Future<void> exportAndPrintWeeklyReport({
    required UserProfile profile,
    required List<MealItem> weeklyMeals,
    required Map<String, dynamic> metrics,
  }) async {
    final pdfBytes = await generateWeeklyReportPdf(
      profile: profile,
      weeklyMeals: weeklyMeals,
      metrics: metrics,
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: 'Reporte_NutriLens_Semanal_${profile.name.replaceAll(' ', '_')}.pdf',
    );
  }

  // ==========================================
  // HELPERS DE RENDERIZADO PDF
  // ==========================================

  static pw.Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required PdfColor borderColor,
    required PdfColor valueColor,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: borderColor),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: pw.TextStyle(color: PdfColor.fromHex('#64748B'), fontSize: 9)),
          pw.SizedBox(height: 4),
          pw.Text(
            value,
            style: pw.TextStyle(color: valueColor, fontWeight: pw.FontWeight.bold, fontSize: 14),
          ),
          pw.SizedBox(height: 2),
          pw.Text(subtitle, style: pw.TextStyle(color: PdfColor.fromHex('#94A3B8'), fontSize: 8)),
        ],
      ),
    );
  }

  static pw.Widget _tableHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8.5, color: PdfColor.fromHex('#0F172A')),
      ),
    );
  }

  static pw.Widget _tableCell(
    String text, {
    bool isBold = false,
    PdfColor? color,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          fontSize: 8,
          color: color ?? PdfColor.fromHex('#0F172A'),
        ),
      ),
    );
  }
}
