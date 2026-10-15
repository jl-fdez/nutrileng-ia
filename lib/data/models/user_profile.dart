/// Perfil de usuario y motor bioadaptativo basado en Mifflin-St Jeor.
class UserProfile {
  final int id;
  final String name;
  final bool isPro;
  final int age;
  final double weightKg;
  final double targetWeightKg;
  final double heightCm;
  final String gender; // 'female' o 'male'
  final double activityLevel; // 1.2 (Sedentario), 1.375 (Ligero), 1.55 (Moderado), 1.725 (Muy activo)
  final String activityLevelName;
  final double goalAdjustment; // -0.15 para -15%, -0.20 para -20%, 0.0 para mantención
  final String goalType;
  final int? customCalorieTarget; // Si el usuario define un target manual
  final double carbsRatio; // 0.40 = 40%
  final double proteinRatio; // 0.30 = 30%
  final double fatRatio; // 0.30 = 30%
  final int streakDays; // Días en racha (ej. 7d o 14d)
  final double weightProgressKg; // Progreso acumulado (ej. -3.2 kg)
  final int adherencePercent; // Porcentaje de adherencia (ej. 94%)
  final bool mealRemindersEnabled;
  final bool aiMetabolicCompensationEnabled;
  final DateTime updatedAt;

  const UserProfile({
    this.id = 1,
    required this.name,
    this.isPro = true,
    required this.age,
    required this.weightKg,
    required this.targetWeightKg,
    required this.heightCm,
    required this.gender,
    this.activityLevel = 1.55,
    this.activityLevelName = 'Moderadamente activo',
    this.goalAdjustment = -0.15,
    this.goalType = 'Déficit moderado óptimo (-15%)',
    this.customCalorieTarget = 1850,
    this.carbsRatio = 0.40,
    this.proteinRatio = 0.30,
    this.fatRatio = 0.30,
    this.streakDays = 7,
    this.weightProgressKg = -3.2,
    this.adherencePercent = 94,
    this.mealRemindersEnabled = true,
    this.aiMetabolicCompensationEnabled = true,
    required this.updatedAt,
  });

  /// Perfil por defecto de Sofía Martínez idéntico a las capturas oficiales
  factory UserProfile.defaultSofia() {
    return UserProfile(
      id: 1,
      name: 'Sofía Martínez',
      isPro: true,
      age: 29,
      weightKg: 68.5,
      targetWeightKg: 62.0,
      heightCm: 168.0,
      gender: 'female',
      activityLevel: 1.55,
      activityLevelName: 'Moderadamente activo',
      goalAdjustment: -0.15,
      goalType: 'Déficit moderado óptimo (-15%)',
      customCalorieTarget: 1850,
      carbsRatio: 0.40,
      proteinRatio: 0.30,
      fatRatio: 0.30,
      streakDays: 7,
      weightProgressKg: -3.2,
      adherencePercent: 94,
      mealRemindersEnabled: true,
      aiMetabolicCompensationEnabled: true,
      updatedAt: DateTime.now(),
    );
  }

  // ==========================================
  // CÁLCULOS METABÓLICOS BIOADAPTATIVOS
  // ==========================================

  /// Tasa Metabólica Basal (BMR) con fórmula Mifflin-St Jeor
  /// Mujer: 10 * peso(kg) + 6.25 * altura(cm) - 5 * edad(años) - 161
  /// Hombre: 10 * peso(kg) + 6.25 * altura(cm) - 5 * edad(años) + 5
  double calculateBmr() {
    final isFemale = gender.toLowerCase() == 'female' || gender.toLowerCase() == 'femenino';
    final base = (10 * weightKg) + (6.25 * heightCm) - (5 * age);
    return isFemale ? (base - 161) : (base + 5);
  }

  /// Gasto Energético Total Diario (TDEE) = BMR * factor de actividad
  double calculateTdee() {
    return calculateBmr() * activityLevel;
  }

  /// Meta Calórica diaria recomendada aplicando el ajuste por objetivo
  int calculateTargetCalories() {
    if (customCalorieTarget != null && customCalorieTarget! > 0) {
      return customCalorieTarget!;
    }
    final tdee = calculateTdee();
    final adjusted = tdee * (1.0 + goalAdjustment);
    return adjusted.round();
  }

  /// Déficit calórico diario en kcal (ej. -400 kcal)
  int calculateDeficitCalories() {
    final tdee = calculateTdee().round();
    final target = calculateTargetCalories();
    return target - tdee;
  }

  /// Gramos diarios de Carbohidratos (4 kcal/g)
  int calculateCarbsGrams() {
    final target = calculateTargetCalories();
    return ((target * carbsRatio) / 4.0).round();
  }

  /// Gramos diarios de Proteínas (4 kcal/g)
  int calculateProteinGrams() {
    final target = calculateTargetCalories();
    return ((target * proteinRatio) / 4.0).round();
  }

  /// Gramos diarios de Grasas (9 kcal/g)
  int calculateFatGrams() {
    final target = calculateTargetCalories();
    return ((target * fatRatio) / 9.0).round();
  }

  /// Peso faltante para la meta
  double get remainingWeightKg => (weightKg - targetWeightKg).clamp(0.0, 500.0);

  // ==========================================
  // SERIALIZACIÓN SQLITE
  // ==========================================

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'is_pro': isPro ? 1 : 0,
      'age': age,
      'weight_kg': weightKg,
      'target_weight_kg': targetWeightKg,
      'height_cm': heightCm,
      'gender': gender,
      'activity_level': activityLevel,
      'activity_level_name': activityLevelName,
      'goal_adjustment': goalAdjustment,
      'goal_type': goalType,
      'custom_calorie_target': customCalorieTarget,
      'carbs_ratio': carbsRatio,
      'protein_ratio': proteinRatio,
      'fat_ratio': fatRatio,
      'streak_days': streakDays,
      'weight_progress_kg': weightProgressKg,
      'adherence_percent': adherencePercent,
      'meal_reminders_enabled': mealRemindersEnabled ? 1 : 0,
      'ai_metabolic_compensation_enabled': aiMetabolicCompensationEnabled ? 1 : 0,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as int? ?? 1,
      name: map['name'] as String? ?? 'Usuario',
      isPro: (map['is_pro'] as int? ?? 1) == 1,
      age: map['age'] as int? ?? 29,
      weightKg: (map['weight_kg'] as num?)?.toDouble() ?? 68.5,
      targetWeightKg: (map['target_weight_kg'] as num?)?.toDouble() ?? 62.0,
      heightCm: (map['height_cm'] as num?)?.toDouble() ?? 168.0,
      gender: map['gender'] as String? ?? 'female',
      activityLevel: (map['activity_level'] as num?)?.toDouble() ?? 1.55,
      activityLevelName: map['activity_level_name'] as String? ?? 'Moderadamente activo',
      goalAdjustment: (map['goal_adjustment'] as num?)?.toDouble() ?? -0.15,
      goalType: map['goal_type'] as String? ?? 'Déficit moderado óptimo (-15%)',
      customCalorieTarget: map['custom_calorie_target'] as int? ?? 1850,
      carbsRatio: (map['carbs_ratio'] as num?)?.toDouble() ?? 0.40,
      proteinRatio: (map['protein_ratio'] as num?)?.toDouble() ?? 0.30,
      fatRatio: (map['fat_ratio'] as num?)?.toDouble() ?? 0.30,
      streakDays: map['streak_days'] as int? ?? 7,
      weightProgressKg: (map['weight_progress_kg'] as num?)?.toDouble() ?? -3.2,
      adherencePercent: map['adherence_percent'] as int? ?? 94,
      mealRemindersEnabled: (map['meal_reminders_enabled'] as int? ?? 1) == 1,
      aiMetabolicCompensationEnabled: (map['ai_metabolic_compensation_enabled'] as int? ?? 1) == 1,
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  UserProfile copyWith({
    int? id,
    String? name,
    bool? isPro,
    int? age,
    double? weightKg,
    double? targetWeightKg,
    double? heightCm,
    String? gender,
    double? activityLevel,
    String? activityLevelName,
    double? goalAdjustment,
    String? goalType,
    int? customCalorieTarget,
    double? carbsRatio,
    double? proteinRatio,
    double? fatRatio,
    int? streakDays,
    double? weightProgressKg,
    int? adherencePercent,
    bool? mealRemindersEnabled,
    bool? aiMetabolicCompensationEnabled,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      isPro: isPro ?? this.isPro,
      age: age ?? this.age,
      weightKg: weightKg ?? this.weightKg,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
      heightCm: heightCm ?? this.heightCm,
      gender: gender ?? this.gender,
      activityLevel: activityLevel ?? this.activityLevel,
      activityLevelName: activityLevelName ?? this.activityLevelName,
      goalAdjustment: goalAdjustment ?? this.goalAdjustment,
      goalType: goalType ?? this.goalType,
      customCalorieTarget: customCalorieTarget ?? this.customCalorieTarget,
      carbsRatio: carbsRatio ?? this.carbsRatio,
      proteinRatio: proteinRatio ?? this.proteinRatio,
      fatRatio: fatRatio ?? this.fatRatio,
      streakDays: streakDays ?? this.streakDays,
      weightProgressKg: weightProgressKg ?? this.weightProgressKg,
      adherencePercent: adherencePercent ?? this.adherencePercent,
      mealRemindersEnabled: mealRemindersEnabled ?? this.mealRemindersEnabled,
      aiMetabolicCompensationEnabled:
          aiMetabolicCompensationEnabled ?? this.aiMetabolicCompensationEnabled,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
