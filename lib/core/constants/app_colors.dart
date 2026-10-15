import 'package:flutter/material.dart';

/// Paleta de colores central de NutriLens AI.
/// Estilo visual: Vitality Glassmorphism / Clean Bio-Tech Saludable.
class AppColors {
  AppColors._();

  // Marca y Acentos Principales
  static const Color primary = Color(0xFF10B981); // Verde Esmeralda
  static const Color primaryDark = Color(0xFF059669);
  static const Color primaryLight = Color(0xFFD1FAE5);
  static const Color primaryMint = Color(0xFFE8FDF5);
  static const Color primaryBorder = Color(0xFFA7F3D0);

  // Fondos y Superficies
  static const Color background = Color(0xFFF7F9FB); // Base limpia
  static const Color surface = Color(0xFFFFFFFF); // Blanco puro
  static const Color surfaceMuted = Color(0xFFF1F5F9);
  static const Color surfaceGlass = Color(0xEBFFFFFF); // Glassmorphism translúcido
  static const Color border = Color(0xFFE2E8F0); // Borde sutil
  static const Color borderSubtle = Color(0xFFF1F5F9);
  static const Color divider = Color(0xFFEEF2F6);

  // Textos y Contraste (WCAG compliant)
  static const Color textPrimary = Color(0xFF0F172A); // Carbón oscuro
  static const Color textSecondary = Color(0xFF64748B); // Slate medio
  static const Color textMuted = Color(0xFF94A3B8); // Slate claro

  // Macronutrientes Semánticos
  static const Color carbs = Color(0xFFF59E0B); // Ámbar / Naranja
  static const Color carbsLight = Color(0xFFFEF3C7);
  static const Color protein = Color(0xFF10B981); // Esmeralda
  static const Color proteinLight = Color(0xFFD1FAE5);
  static const Color fat = Color(0xFF6366F1); // Índigo / Pizarra
  static const Color fatLight = Color(0xFFEDE9FE);

  // Estados, Métricas y Badges
  static const Color burnOrange = Color(0xFFF97316); // Racha / Calorías quemadas
  static const Color burnOrangeLight = Color(0xFFFFEDD5);
  static const Color purpleLight = Color(0xFFF3E8FF);
  static const Color purpleDark = Color(0xFF7E22CE);
  static const Color blueLight = Color(0xFFE0F2FE);
  static const Color blueDark = Color(0xFF0284C7);

  // Estados del Sistema
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);

  // Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient scannerOverlayGradient = LinearGradient(
    colors: [Color(0x80000000), Color(0x20000000), Color(0x90000000)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient ringTrackGradient = LinearGradient(
    colors: [Color(0xFFE2E8F0), Color(0xFFF1F5F9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Sombras Soft Glassmorphism
  static List<BoxShadow> get cardShadow => [
        const BoxShadow(
          color: Color(0x0A0F172A), // 4% de opacidad
          blurRadius: 30,
          offset: Offset(0, 8),
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get floatingShadow => [
        const BoxShadow(
          color: Color(0x14059669), // 8% de esmeralda
          blurRadius: 24,
          offset: Offset(0, 10),
          spreadRadius: -2,
        ),
      ];
}
