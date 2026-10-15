import 'package:flutter_test/flutter_test.dart';
import 'package:nutrilengia/data/models/meal_item.dart';

void main() {
  group('MealType Enum parsing', () {
    test('fromKey parses known meal keys correctly', () {
      expect(MealType.fromKey('breakfast'), equals(MealType.breakfast));
      expect(MealType.fromKey('lunch'), equals(MealType.lunch));
      expect(MealType.fromKey('snack'), equals(MealType.snack));
      expect(MealType.fromKey('dinner'), equals(MealType.dinner));
    });

    test('fromKey is case-insensitive', () {
      expect(MealType.fromKey('BREAKFAST'), equals(MealType.breakfast));
      expect(MealType.fromKey('LUNCH'), equals(MealType.lunch));
      expect(MealType.fromKey('Snack'), equals(MealType.snack));
    });

    test('fromKey falls back to lunch on invalid key', () {
      expect(MealType.fromKey('unknown_meal'), equals(MealType.lunch));
      expect(MealType.fromKey(''), equals(MealType.lunch));
    });
  });

  group('DetectedIngredient Model', () {
    test('toMap and fromMap bidirectional serialization', () {
      const ingredient = DetectedIngredient(
        name: 'Aguacate Hass',
        portion: '50g',
        calories: 80,
      );

      final map = ingredient.toMap();
      expect(map['name'], equals('Aguacate Hass'));
      expect(map['portion'], equals('50g'));
      expect(map['calories'], equals(80));

      final restored = DetectedIngredient.fromMap(map);
      expect(restored.name, equals(ingredient.name));
      expect(restored.portion, equals(ingredient.portion));
      expect(restored.calories, equals(ingredient.calories));
    });

    test('copyWith modifies individual fields', () {
      const ingredient = DetectedIngredient(
        name: 'Huevo duro',
        portion: '1 unidad',
        calories: 78,
      );

      final updated = ingredient.copyWith(portion: '2 unidades', calories: 156);
      expect(updated.name, equals('Huevo duro'));
      expect(updated.portion, equals('2 unidades'));
      expect(updated.calories, equals(156));
    });
  });

  group('MealItem Model', () {
    test('toMap and fromMap preserves all fields and JSON ingredient list', () {
      final now = DateTime(2026, 10, 15, 13, 30);
      final meal = MealItem(
        id: 42,
        name: 'Bowl de Salmón y Quinoa',
        mealType: MealType.lunch,
        calories: 580,
        proteinG: 42.0,
        carbsG: 48.0,
        fatG: 22.0,
        fiberG: 7.0,
        sodiumMg: 390,
        dateTime: now,
        timeString: '1:30 PM',
        imagePath: '/photos/salmon.jpg',
        userNotes: 'Sin sal añadida',
        appliedAdjustment: true,
        adjustmentCalories: -50,
        adjustmentReason: 'Reducción de aceite',
        aiCoachFeedback: 'Excelente perfil de grasas monoinsaturadas',
        isAiValidated: true,
        validationTag: 'IA validada • 1:30 PM',
        detectedIngredients: const [
          DetectedIngredient(name: 'Salmón fresco', portion: '140g', calories: 260),
          DetectedIngredient(name: 'Quinoa', portion: '100g', calories: 120),
        ],
      );

      final map = meal.toMap();
      expect(map['id'], equals(42));
      expect(map['name'], equals('Bowl de Salmón y Quinoa'));
      expect(map['meal_type'], equals('lunch'));
      expect(map['calories'], equals(580));
      expect(map['applied_adjustment'], equals(1));
      expect(map['adjustment_calories'], equals(-50));
      expect(map['detected_ingredients_json'], contains('Salmón fresco'));

      final restored = MealItem.fromMap(map);
      expect(restored.id, equals(42));
      expect(restored.name, equals('Bowl de Salmón y Quinoa'));
      expect(restored.mealType, equals(MealType.lunch));
      expect(restored.calories, equals(580));
      expect(restored.proteinG, equals(42.0));
      expect(restored.carbsG, equals(48.0));
      expect(restored.fatG, equals(22.0));
      expect(restored.appliedAdjustment, isTrue);
      expect(restored.adjustmentCalories, equals(-50));
      expect(restored.detectedIngredients.length, equals(2));
      expect(restored.detectedIngredients.first.name, equals('Salmón fresco'));
    });

    test('formatTime generates standard 12-hour AM/PM string', () {
      final morning = DateTime(2026, 10, 15, 8, 5);
      expect(MealItem.formatTime(morning), equals('8:05 AM'));

      final noon = DateTime(2026, 10, 15, 12, 0);
      expect(MealItem.formatTime(noon), equals('12:00 PM'));

      final night = DateTime(2026, 10, 15, 20, 45);
      expect(MealItem.formatTime(night), equals('8:45 PM'));
    });

    test('copyWith creates a new instance with altered properties', () {
      final now = DateTime(2026, 10, 15, 8, 0);
      final meal = MealItem(
        name: 'Avena con Frutas',
        mealType: MealType.breakfast,
        calories: 320,
        proteinG: 12.0,
        carbsG: 55.0,
        fatG: 6.0,
        dateTime: now,
      );

      final modified = meal.copyWith(calories: 350, proteinG: 16.0);
      expect(modified.name, equals('Avena con Frutas'));
      expect(modified.calories, equals(350));
      expect(modified.proteinG, equals(16.0));
      expect(meal.calories, equals(320));
    });
  });
}
