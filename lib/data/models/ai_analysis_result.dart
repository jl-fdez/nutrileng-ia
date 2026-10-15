import 'meal_item.dart';

/// Desglose de macronutrientes y micronutrientes principales del análisis IA
class MacroBreakdown {
  final double proteinG;
  final double carbsG;
  final double fatG;
  final double fiberG;
  final int sodiumMg;

  const MacroBreakdown({
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    this.fiberG = 0,
    this.sodiumMg = 0,
  });

  factory MacroBreakdown.fromJson(Map<String, dynamic> json) {
    return MacroBreakdown(
      proteinG: (json['protein_g'] as num?)?.toDouble() ?? 0.0,
      carbsG: (json['carbs_g'] as num?)?.toDouble() ?? 0.0,
      fatG: (json['fat_g'] as num?)?.toDouble() ?? 0.0,
      fiberG: (json['fiber_g'] as num?)?.toDouble() ?? 0.0,
      sodiumMg: (json['sodium_mg'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'protein_g': proteinG,
      'carbs_g': carbsG,
      'fat_g': fatG,
      'fiber_g': fiberG,
      'sodium_mg': sodiumMg,
    };
  }
}

/// Detalle del ajuste calórico aplicado a partir de notas del usuario
/// (ej. ingredientes invisibles, preparación sin azúcar, sin aceite)
class NotesAdjustment {
  final bool applied;
  final int calorieDiff; // Negativo para reducción (ej. -65), positivo para adición
  final String explanation;

  const NotesAdjustment({
    required this.applied,
    required this.calorieDiff,
    required this.explanation,
  });

  factory NotesAdjustment.none() {
    return const NotesAdjustment(
      applied: false,
      calorieDiff: 0,
      explanation: 'Sin ajustes manuales requeridos.',
    );
  }

  factory NotesAdjustment.fromJson(Map<String, dynamic> json) {
    return NotesAdjustment(
      applied: json['applied'] as bool? ?? false,
      calorieDiff: (json['calorie_diff'] as num?)?.toInt() ?? 0,
      explanation: json['explanation'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'applied': applied,
      'calorie_diff': calorieDiff,
      'explanation': explanation,
    };
  }
}

/// Resultado estructurado entregado por Gemini Multimodal API o motor mock inteligente
class AiAnalysisResult {
  final String dishName;
  final List<DetectedIngredient> detectedIngredients;
  final int totalCalories;
  final MacroBreakdown macros;
  final NotesAdjustment notesAdjustment;
  final String coachFeedback;

  const AiAnalysisResult({
    required this.dishName,
    required this.detectedIngredients,
    required this.totalCalories,
    required this.macros,
    required this.notesAdjustment,
    required this.coachFeedback,
  });

  factory AiAnalysisResult.fromJson(Map<String, dynamic> json) {
    List<DetectedIngredient> ingredients = [];
    if (json['detected_ingredients'] != null && json['detected_ingredients'] is List) {
      ingredients = (json['detected_ingredients'] as List)
          .map((item) => DetectedIngredient.fromMap(item as Map<String, dynamic>))
          .toList();
    }

    final macrosJson = json['macros'] as Map<String, dynamic>? ?? {};
    final notesJson = json['notes_adjustment'] as Map<String, dynamic>? ?? {};

    return AiAnalysisResult(
      dishName: json['dish_name'] as String? ?? 'Plato Reconocido',
      detectedIngredients: ingredients,
      totalCalories: (json['total_calories'] as num?)?.toInt() ?? 0,
      macros: MacroBreakdown.fromJson(macrosJson),
      notesAdjustment: NotesAdjustment.fromJson(notesJson),
      coachFeedback: json['coach_feedback'] as String? ??
          'Excelente balance nutricional para tus metas metabólicas.',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dish_name': dishName,
      'detected_ingredients': detectedIngredients.map((e) => e.toMap()).toList(),
      'total_calories': totalCalories,
      'macros': macros.toJson(),
      'notes_adjustment': notesAdjustment.toJson(),
      'coach_feedback': coachFeedback,
    };
  }

  /// Convierte el análisis a una entidad [MealItem] persistible en base de datos
  MealItem toMealItem({
    required MealType mealType,
    String? imagePath,
    String? userNotes,
    DateTime? timestamp,
  }) {
    final now = timestamp ?? DateTime.now();
    return MealItem(
      name: dishName,
      mealType: mealType,
      calories: totalCalories,
      proteinG: macros.proteinG,
      carbsG: macros.carbsG,
      fatG: macros.fatG,
      fiberG: macros.fiberG,
      sodiumMg: macros.sodiumMg,
      dateTime: now,
      imagePath: imagePath,
      detectedIngredients: detectedIngredients,
      userNotes: userNotes,
      appliedAdjustment: notesAdjustment.applied,
      adjustmentCalories: notesAdjustment.calorieDiff,
      adjustmentReason: notesAdjustment.explanation,
      aiCoachFeedback: coachFeedback,
      isAiValidated: true,
      validationTag: 'IA validada • ${MealItem.formatTime(now)}',
    );
  }
}
