import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrilengia/data/models/ai_analysis_result.dart';
import 'package:nutrilengia/data/models/meal_item.dart';

void main() {
  group('MacroBreakdown Model', () {
    test('fromJson and toJson conversion', () {
      final json = {
        'protein_g': 35.5,
        'carbs_g': 40.0,
        'fat_g': 15.2,
        'fiber_g': 6.0,
        'sodium_mg': 450,
      };

      final breakdown = MacroBreakdown.fromJson(json);
      expect(breakdown.proteinG, equals(35.5));
      expect(breakdown.carbsG, equals(40.0));
      expect(breakdown.fatG, equals(15.2));
      expect(breakdown.fiberG, equals(6.0));
      expect(breakdown.sodiumMg, equals(450));

      final serialized = breakdown.toJson();
      expect(serialized['protein_g'], equals(35.5));
      expect(serialized['carbs_g'], equals(40.0));
      expect(serialized['fat_g'], equals(15.2));
      expect(serialized['fiber_g'], equals(6.0));
      expect(serialized['sodium_mg'], equals(450));
    });
  });

  group('NotesAdjustment Model', () {
    test('none factory creates default zero adjustment', () {
      final adjustment = NotesAdjustment.none();
      expect(adjustment.applied, isFalse);
      expect(adjustment.calorieDiff, equals(0));
      expect(adjustment.explanation, isNotEmpty);
    });

    test('fromJson with negative calorie adjustment', () {
      final json = {
        'applied': true,
        'calorie_diff': -75,
        'explanation': 'Preparado sin mantequilla',
      };

      final adjustment = NotesAdjustment.fromJson(json);
      expect(adjustment.applied, isTrue);
      expect(adjustment.calorieDiff, equals(-75));
      expect(adjustment.explanation, equals('Preparado sin mantequilla'));
    });
  });

  group('AiAnalysisResult Model', () {
    test('fromJson deserializes complete AI response', () {
      final json = {
        'dish_name': 'Pechuga de Pollo con Brócoli',
        'total_calories': 420,
        'macros': {
          'protein_g': 45.0,
          'carbs_g': 12.0,
          'fat_g': 10.0,
          'fiber_g': 5.0,
          'sodium_mg': 320,
        },
        'notes_adjustment': {
          'applied': true,
          'calorie_diff': -30,
          'explanation': 'Cocido al vapor sin aceite',
        },
        'coach_feedback': 'Plato óptimo para recuperación muscular.',
        'detected_ingredients': [
          {'name': 'Pechuga de pollo', 'portion': '180g', 'calories': 280},
          {'name': 'Brócoli al vapor', 'portion': '150g', 'calories': 50},
        ],
      };

      final result = AiAnalysisResult.fromJson(json);
      expect(result.dishName, equals('Pechuga de Pollo con Brócoli'));
      expect(result.totalCalories, equals(420));
      expect(result.macros.proteinG, equals(45.0));
      expect(result.notesAdjustment.applied, isTrue);
      expect(result.notesAdjustment.calorieDiff, equals(-30));
      expect(result.detectedIngredients.length, equals(2));
      expect(result.coachFeedback, contains('recuperación muscular'));
    });

    test('toMealItem converts analysis result into persistent MealItem', () {
      final result = AiAnalysisResult(
        dishName: 'Tortilla de Espinaca',
        detectedIngredients: const [
          DetectedIngredient(name: 'Huevos', portion: '2 piezas', calories: 140),
          DetectedIngredient(name: 'Espinacas', portion: '100g', calories: 25),
        ],
        totalCalories: 260,
        macros: const MacroBreakdown(proteinG: 18, carbsG: 6, fatG: 16),
        notesAdjustment: NotesAdjustment.none(),
        coachFeedback: 'Rica en hierro y vitaminas esenciales.',
      );

      final fixedDate = DateTime(2026, 10, 15, 9, 0);
      final mealItem = result.toMealItem(
        mealType: MealType.breakfast,
        userNotes: 'Desayuno pre-entreno',
        timestamp: fixedDate,
      );

      expect(mealItem.name, equals('Tortilla de Espinaca'));
      expect(mealItem.mealType, equals(MealType.breakfast));
      expect(mealItem.calories, equals(260));
      expect(mealItem.proteinG, equals(18.0));
      expect(mealItem.isAiValidated, isTrue);
      expect(mealItem.userNotes, equals('Desayuno pre-entreno'));
      expect(mealItem.validationTag, contains('IA validada'));
    });

    test('parses simulated raw string response wrapped in markdown code blocks', () {
      const rawMarkdown = '''
      ```json
      {
        "dish_name": "Tazón de Yogur Griego y Arándanos",
        "total_calories": 210,
        "macros": {
          "protein_g": 18.0,
          "carbs_g": 24.0,
          "fat_g": 4.0
        },
        "notes_adjustment": {
          "applied": false,
          "calorie_diff": 0,
          "explanation": "Sin ajustes"
        },
        "coach_feedback": "Excelente snack proteico.",
        "detected_ingredients": []
      }
      ```
      ''';

      // Clean markdown fences as GeminiAiService does
      final cleaned = rawMarkdown
          .replaceAll(RegExp(r'```json\s*'), '')
          .replaceAll(RegExp(r'```\s*'), '')
          .trim();

      final parsed = jsonDecode(cleaned) as Map<String, dynamic>;
      final result = AiAnalysisResult.fromJson(parsed);

      expect(result.dishName, equals('Tazón de Yogur Griego y Arándanos'));
      expect(result.totalCalories, equals(210));
      expect(result.macros.proteinG, equals(18.0));
    });
  });
}
