import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrilengia/core/theme/app_theme.dart';
import 'package:nutrilengia/presentation/widgets/meal_card.dart';

void main() {
  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: Center(
          child: SizedBox(width: 420, child: child),
        ),
      ),
    );
  }

  testWidgets('MealCard renders registered meal title, calories, and badges',
      (WidgetTester tester) async {
    bool cardTapped = false;

    const mealData = MealItemData(
      id: 'meal_1',
      categoryName: 'Almuerzo',
      category: MealCategory.lunch,
      title: 'Bowl de Salmón y Quinoa',
      subtitle: '1:30 PM • 42g Prot • 48g Carbs',
      calories: 580,
      isRegistered: true,
      aiBadgeText: 'Validado',
      aiBadgeType: 'validated',
      fallbackIcon: Icons.lunch_dining_rounded,
    );

    await tester.pumpWidget(
      buildTestableWidget(
        MealCard(
          meal: mealData,
          onTap: () => cardTapped = true,
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify category label and title
    expect(find.text('ALMUERZO'), findsOneWidget);
    expect(find.text('Bowl de Salmón y Quinoa'), findsOneWidget);
    expect(find.text('1:30 PM • 42g Prot • 48g Carbs'), findsOneWidget);

    // Verify calories
    expect(find.text('580 kcal'), findsOneWidget);

    // Verify AI Badge text
    expect(find.text('Validado'), findsOneWidget);

    // Tap card and check callback
    await tester.tap(find.text('Bowl de Salmón y Quinoa'));
    await tester.pumpAndSettle();
    expect(cardTapped, isTrue);
  });

  testWidgets('MealCard renders pending meal state with add button',
      (WidgetTester tester) async {
    bool addTapped = false;

    const pendingMeal = MealItemData(
      id: 'meal_pending',
      categoryName: 'Cena',
      category: MealCategory.dinner,
      title: 'Registrar Cena',
      subtitle: 'Recomendado: 450 kcal',
      isRegistered: false,
      showAddButton: true,
      fallbackIcon: Icons.dinner_dining_rounded,
    );

    await tester.pumpWidget(
      buildTestableWidget(
        MealCard(
          meal: pendingMeal,
          onAddTap: () => addTapped = true,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('CENA'), findsOneWidget);
    expect(find.text('Registrar Cena'), findsOneWidget);
    expect(find.text('Recomendado: 450 kcal'), findsOneWidget);

    // Tap on pending card
    await tester.tap(find.text('Registrar Cena'));
    await tester.pumpAndSettle();
    expect(addTapped, isTrue);
  });
}
