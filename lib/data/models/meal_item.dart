import 'dart:convert';

/// Tipos de comida reconocidos en el sistema de nutrición
enum MealType {
  breakfast('Desayuno', 'breakfast'),
  lunch('Almuerzo', 'lunch'),
  snack('Merienda / Snack', 'snack'),
  dinner('Cena', 'dinner');

  final String label;
  final String key;
  const MealType(this.label, this.key);

  static MealType fromKey(String key) {
    return MealType.values.firstWhere(
      (e) => e.key.toLowerCase() == key.toLowerCase() || e.name.toLowerCase() == key.toLowerCase(),
      orElse: () => MealType.lunch,
    );
  }
}

/// Ingrediente individual detectado por visión computacional / IA
class DetectedIngredient {
  final String name;
  final String portion;
  final int calories;

  const DetectedIngredient({
    required this.name,
    required this.portion,
    required this.calories,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'portion': portion,
      'calories': calories,
    };
  }

  factory DetectedIngredient.fromMap(Map<String, dynamic> map) {
    return DetectedIngredient(
      name: map['name'] as String? ?? '',
      portion: map['portion'] as String? ?? '1 porción',
      calories: (map['calories'] as num?)?.toInt() ?? 0,
    );
  }

  DetectedIngredient copyWith({
    String? name,
    String? portion,
    int? calories,
  }) {
    return DetectedIngredient(
      name: name ?? this.name,
      portion: portion ?? this.portion,
      calories: calories ?? this.calories,
    );
  }
}

/// Registro completo de comida con desglose nutricional y trazabilidad IA
class MealItem {
  final int? id;
  final String name;
  final MealType mealType;
  final int calories;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final double fiberG;
  final int sodiumMg;
  final DateTime dateTime;
  final String? timeString;
  final String? imagePath;
  final List<DetectedIngredient> detectedIngredients;
  final String? userNotes;
  final bool appliedAdjustment;
  final int adjustmentCalories;
  final String? adjustmentReason;
  final String? aiCoachFeedback;
  final bool isAiValidated;
  final String? validationTag;

  const MealItem({
    this.id,
    required this.name,
    required this.mealType,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    this.fiberG = 0,
    this.sodiumMg = 0,
    required this.dateTime,
    this.timeString,
    this.imagePath,
    this.detectedIngredients = const [],
    this.userNotes,
    this.appliedAdjustment = false,
    this.adjustmentCalories = 0,
    this.adjustmentReason,
    this.aiCoachFeedback,
    this.isAiValidated = true,
    this.validationTag,
  });

  // ==========================================
  // SERIALIZACIÓN SQLITE
  // ==========================================

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'meal_type': mealType.key,
      'calories': calories,
      'protein_g': proteinG,
      'carbs_g': carbsG,
      'fat_g': fatG,
      'fiber_g': fiberG,
      'sodium_mg': sodiumMg,
      'date_time': dateTime.toIso8601String(),
      'time_string': timeString ?? formatTime(dateTime),
      'image_path': imagePath,
      'detected_ingredients_json': jsonEncode(
        detectedIngredients.map((i) => i.toMap()).toList(),
      ),
      'user_notes': userNotes,
      'applied_adjustment': appliedAdjustment ? 1 : 0,
      'adjustment_calories': adjustmentCalories,
      'adjustment_reason': adjustmentReason,
      'ai_coach_feedback': aiCoachFeedback,
      'is_ai_validated': isAiValidated ? 1 : 0,
      'validation_tag': validationTag,
    };
  }

  factory MealItem.fromMap(Map<String, dynamic> map) {
    List<DetectedIngredient> ingredients = [];
    if (map['detected_ingredients_json'] != null) {
      try {
        final decoded = jsonDecode(map['detected_ingredients_json'] as String);
        if (decoded is List) {
          ingredients = decoded
              .map((item) => DetectedIngredient.fromMap(item as Map<String, dynamic>))
              .toList();
        }
      } catch (_) {}
    }

    final dt = map['date_time'] != null
        ? DateTime.tryParse(map['date_time'] as String) ?? DateTime.now()
        : DateTime.now();

    return MealItem(
      id: map['id'] as int?,
      name: map['name'] as String? ?? 'Comida',
      mealType: MealType.fromKey(map['meal_type'] as String? ?? 'lunch'),
      calories: (map['calories'] as num?)?.toInt() ?? 0,
      proteinG: (map['protein_g'] as num?)?.toDouble() ?? 0.0,
      carbsG: (map['carbs_g'] as num?)?.toDouble() ?? 0.0,
      fatG: (map['fat_g'] as num?)?.toDouble() ?? 0.0,
      fiberG: (map['fiber_g'] as num?)?.toDouble() ?? 0.0,
      sodiumMg: (map['sodium_mg'] as num?)?.toInt() ?? 0,
      dateTime: dt,
      timeString: map['time_string'] as String? ?? formatTime(dt),
      imagePath: map['image_path'] as String?,
      detectedIngredients: ingredients,
      userNotes: map['user_notes'] as String?,
      appliedAdjustment: (map['applied_adjustment'] as int? ?? 0) == 1,
      adjustmentCalories: (map['adjustment_calories'] as num?)?.toInt() ?? 0,
      adjustmentReason: map['adjustment_reason'] as String?,
      aiCoachFeedback: map['ai_coach_feedback'] as String?,
      isAiValidated: (map['is_ai_validated'] as int? ?? 1) == 1,
      validationTag: map['validation_tag'] as String?,
    );
  }

  MealItem copyWith({
    int? id,
    String? name,
    MealType? mealType,
    int? calories,
    double? proteinG,
    double? carbsG,
    double? fatG,
    double? fiberG,
    int? sodiumMg,
    DateTime? dateTime,
    String? timeString,
    String? imagePath,
    List<DetectedIngredient>? detectedIngredients,
    String? userNotes,
    bool? appliedAdjustment,
    int? adjustmentCalories,
    String? adjustmentReason,
    String? aiCoachFeedback,
    bool? isAiValidated,
    String? validationTag,
  }) {
    return MealItem(
      id: id ?? this.id,
      name: name ?? this.name,
      mealType: mealType ?? this.mealType,
      calories: calories ?? this.calories,
      proteinG: proteinG ?? this.proteinG,
      carbsG: carbsG ?? this.carbsG,
      fatG: fatG ?? this.fatG,
      fiberG: fiberG ?? this.fiberG,
      sodiumMg: sodiumMg ?? this.sodiumMg,
      dateTime: dateTime ?? this.dateTime,
      timeString: timeString ?? this.timeString,
      imagePath: imagePath ?? this.imagePath,
      detectedIngredients: detectedIngredients ?? this.detectedIngredients,
      userNotes: userNotes ?? this.userNotes,
      appliedAdjustment: appliedAdjustment ?? this.appliedAdjustment,
      adjustmentCalories: adjustmentCalories ?? this.adjustmentCalories,
      adjustmentReason: adjustmentReason ?? this.adjustmentReason,
      aiCoachFeedback: aiCoachFeedback ?? this.aiCoachFeedback,
      isAiValidated: isAiValidated ?? this.isAiValidated,
      validationTag: validationTag ?? this.validationTag,
    );
  }

  static String formatTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }
}
