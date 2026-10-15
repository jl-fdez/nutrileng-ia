import 'package:flutter_test/flutter_test.dart';
import 'package:nutrilengia/data/datasources/app_database.dart';
import 'package:nutrilengia/data/models/meal_item.dart';
import 'package:nutrilengia/data/models/user_profile.dart';
import 'package:nutrilengia/data/repositories/nutrition_repository.dart';
import 'test_helpers.dart';

void main() {
  setUpAll(() async {
    await setupTestDatabaseFactory();
  });

  group('Database & NutritionRepository Integration Tests', () {
    late NutritionRepository repository;

    setUp(() async {
      // Ensure the database is initialized
      await AppDatabase.instance.database;
      repository = NutritionRepository();
    });

    test('getUserProfile returns seeded profile on startup', () async {
      final profile = await repository.getUserProfile();
      expect(profile.id, equals(1));
      expect(profile.name, equals('Sofía Martínez'));
      expect(profile.isPro, isTrue);
      expect(profile.weightKg, equals(68.5));
      expect(profile.targetWeightKg, equals(62.0));
    });

    test('updateUserProfile persists changes and notifies reactive listeners', () async {
      final currentProfile = await repository.getUserProfile();
      final updatedProfile = currentProfile.copyWith(
        weightKg: 67.8,
        streakDays: 8,
      );

      bool listenerNotified = false;
      void listener() {
        listenerNotified = true;
      }

      repository.addListener(listener);

      await repository.updateUserProfile(updatedProfile);

      expect(listenerNotified, isTrue);

      final fetched = await repository.getUserProfile();
      expect(fetched.weightKg, equals(67.8));
      expect(fetched.streakDays, equals(8));

      repository.removeListener(listener);

      // Restore original profile for subsequent tests
      await repository.updateUserProfile(currentProfile);
    });

    test('Meal CRUD lifecycle (insert, retrieve, delete) with reactive notification', () async {
      final testDate = DateTime(2026, 10, 15, 14, 0);
      final newMeal = MealItem(
        name: 'Snack Proteico de Almendras',
        mealType: MealType.snack,
        calories: 190,
        proteinG: 7.0,
        carbsG: 6.0,
        fatG: 15.0,
        fiberG: 3.0,
        sodiumMg: 10,
        dateTime: testDate,
        timeString: '2:00 PM',
        userNotes: 'Prueba de integración',
        isAiValidated: true,
        validationTag: 'IA validada • 2:00 PM',
      );

      bool listenerNotifiedOnInsert = false;
      void onInsertListener() {
        listenerNotifiedOnInsert = true;
      }

      repository.addListener(onInsertListener);

      // 1. Insert meal
      final insertedId = await repository.insertMeal(newMeal);
      expect(insertedId, isPositive);
      expect(listenerNotifiedOnInsert, isTrue);
      repository.removeListener(onInsertListener);

      // 2. Retrieve meal by date
      final mealsOnDate = await repository.getMealsForDate(testDate);
      expect(mealsOnDate.any((m) => m.id == insertedId), isTrue);

      final retrieved = mealsOnDate.firstWhere((m) => m.id == insertedId);
      expect(retrieved.name, equals('Snack Proteico de Almendras'));
      expect(retrieved.calories, equals(190));
      expect(retrieved.mealType, equals(MealType.snack));

      // 3. Delete meal
      bool listenerNotifiedOnDelete = false;
      void onDeleteListener() {
        listenerNotifiedOnDelete = true;
      }

      repository.addListener(onDeleteListener);
      await repository.deleteMeal(insertedId);
      expect(listenerNotifiedOnDelete, isTrue);
      repository.removeListener(onDeleteListener);

      // 4. Verify absence
      final afterDeleteMeals = await repository.getMealsForDate(testDate);
      expect(afterDeleteMeals.any((m) => m.id == insertedId), isFalse);
    });

    test('getDailySummary aggregates total calories and macronutrients correctly', () async {
      final now = DateTime.now();
      final summary = await repository.getDailySummary(now);

      expect(summary.containsKey('consumed_calories'), isTrue);
      expect(summary.containsKey('target_calories'), isTrue);
      expect(summary.containsKey('remaining_calories'), isTrue);
      expect(summary.containsKey('carbs_consumed'), isTrue);
      expect(summary.containsKey('protein_consumed'), isTrue);
      expect(summary.containsKey('fat_consumed'), isTrue);
      expect(summary.containsKey('meals'), isTrue);

      final consumed = summary['consumed_calories'] as int;
      final target = summary['target_calories'] as int;
      final remaining = summary['remaining_calories'] as int;

      expect(consumed, isNonNegative);
      expect(target, isPositive);
      expect(remaining, isNonNegative);
    });

    test('getWeeklyMetrics computes 7-day strip and metabolic weekly metrics', () async {
      final referenceDate = DateTime.now();
      final weeklyMetrics = await repository.getWeeklyMetrics(referenceDate);

      expect(weeklyMetrics.containsKey('average_calories'), isTrue);
      expect(weeklyMetrics.containsKey('total_deficit'), isTrue);
      expect(weeklyMetrics.containsKey('days_data'), isTrue);

      final daysData = weeklyMetrics['days_data'] as List<Map<String, dynamic>>;
      expect(daysData.length, equals(7));

      // Days of week labels: L, M, X, J, V, S, D
      final expectedLabels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
      for (int i = 0; i < 7; i++) {
        expect(daysData[i]['day_label'], equals(expectedLabels[i]));
      }
    });
  });
}
