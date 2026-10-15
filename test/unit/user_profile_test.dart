import 'package:flutter_test/flutter_test.dart';
import 'package:nutrilengia/data/models/user_profile.dart';

void main() {
  group('UserProfile - Mifflin-St Jeor Metabolic Formulas', () {
    test('calculateBmr for female Sofia Martinez (68.5kg, 168cm, 29yo)', () {
      final profile = UserProfile.defaultSofia();
      // BMR = (10 * 68.5) + (6.25 * 168) - (5 * 29) - 161
      // BMR = 685 + 1050 - 145 - 161 = 1429.0
      expect(profile.calculateBmr(), closeTo(1429.0, 0.01));
    });

    test('calculateBmr for male (75.0kg, 178cm, 30yo)', () {
      final maleProfile = UserProfile(
        name: 'Carlos Mendoza',
        age: 30,
        weightKg: 75.0,
        targetWeightKg: 70.0,
        heightCm: 178.0,
        gender: 'male',
        updatedAt: DateTime.now(),
      );
      // BMR = (10 * 75.0) + (6.25 * 178) - (5 * 30) + 5
      // BMR = 750 + 1112.5 - 150 + 5 = 1717.5
      expect(maleProfile.calculateBmr(), closeTo(1717.5, 0.01));
    });

    test('calculateTdee with activityLevel 1.55', () {
      final profile = UserProfile.defaultSofia();
      // TDEE = 1429.0 * 1.55 = 2214.95
      expect(profile.calculateTdee(), closeTo(2214.95, 0.05));
    });

    test('calculateTargetCalories respects customCalorieTarget when defined', () {
      final profile = UserProfile.defaultSofia().copyWith(customCalorieTarget: 1850);
      expect(profile.calculateTargetCalories(), equals(1850));
    });

    test('calculateTargetCalories computes dynamic deficit when customCalorieTarget is null', () {
      final profile = UserProfile(
        name: 'Test Dynamic',
        age: 29,
        weightKg: 68.5,
        targetWeightKg: 62.0,
        heightCm: 168.0,
        gender: 'female',
        activityLevel: 1.55,
        goalAdjustment: -0.15,
        customCalorieTarget: null,
        updatedAt: DateTime.now(),
      );
      // TDEE = 2214.95. Target = 2214.95 * (1 - 0.15) = 1882.7075 -> round() = 1883
      expect(profile.calculateTargetCalories(), equals(1883));
    });

    test('calculateDeficitCalories reflects difference between target and TDEE', () {
      final profile = UserProfile.defaultSofia().copyWith(customCalorieTarget: 1850);
      // target = 1850, tdee.round() = 2215 -> deficit = 1850 - 2215 = -365
      expect(profile.calculateDeficitCalories(), equals(-365));
    });

    test('calculateCarbsGrams, calculateProteinGrams, calculateFatGrams distribute 40/30/30', () {
      final profile = UserProfile.defaultSofia().copyWith(
        customCalorieTarget: 1850,
        carbsRatio: 0.40,
        proteinRatio: 0.30,
        fatRatio: 0.30,
      );
      // Carbs: (1850 * 0.40) / 4 = 185g
      expect(profile.calculateCarbsGrams(), equals(185));

      // Protein: (1850 * 0.30) / 4 = 138.75 -> 139g
      expect(profile.calculateProteinGrams(), equals(139));

      // Fat: (1850 * 0.30) / 9 = 61.666 -> 62g
      expect(profile.calculateFatGrams(), equals(62));
    });

    test('remainingWeightKg clamps negative delta to zero', () {
      final inProgress = UserProfile.defaultSofia().copyWith(weightKg: 68.5, targetWeightKg: 62.0);
      expect(inProgress.remainingWeightKg, closeTo(6.5, 0.001));

      final achieved = UserProfile.defaultSofia().copyWith(weightKg: 60.0, targetWeightKg: 62.0);
      expect(achieved.remainingWeightKg, equals(0.0));
    });
  });

  group('UserProfile - SQLite Serialization & Deserialization', () {
    test('toMap and fromMap bidirectional consistency', () {
      final original = UserProfile.defaultSofia();
      final map = original.toMap();

      expect(map['name'], equals('Sofía Martínez'));
      expect(map['is_pro'], equals(1));
      expect(map['weight_kg'], equals(68.5));
      expect(map['target_weight_kg'], equals(62.0));
      expect(map['custom_calorie_target'], equals(1850));

      final restored = UserProfile.fromMap(map);
      expect(restored.name, equals(original.name));
      expect(restored.isPro, isTrue);
      expect(restored.weightKg, equals(original.weightKg));
      expect(restored.targetWeightKg, equals(original.targetWeightKg));
      expect(restored.streakDays, equals(original.streakDays));
      expect(restored.adherencePercent, equals(original.adherencePercent));
    });

    test('copyWith updates individual fields immutably', () {
      final original = UserProfile.defaultSofia();
      final modified = original.copyWith(
        weightKg: 67.0,
        streakDays: 8,
        adherencePercent: 96,
      );

      expect(modified.weightKg, equals(67.0));
      expect(modified.streakDays, equals(8));
      expect(modified.adherencePercent, equals(96));
      expect(modified.name, equals(original.name));
      expect(original.weightKg, equals(68.5));
    });
  });
}
