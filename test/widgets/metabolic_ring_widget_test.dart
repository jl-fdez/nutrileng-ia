import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrilengia/core/theme/app_theme.dart';
import 'package:nutrilengia/presentation/widgets/metabolic_ring_widget.dart';

void main() {
  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: Center(
          child: SingleChildScrollView(child: child),
        ),
      ),
    );
  }

  testWidgets('MetabolicRingWidget renders calories remaining, target and labels',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      buildTestableWidget(
        const MetabolicRingWidget(
          targetCalories: 2100,
          consumedCalories: 680,
          burnedCalories: 340,
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Remaining calories calculation: 2100 - 680 = 1420
    expect(find.text('RESTANTES'), findsOneWidget);
    expect(find.text('1,420'), findsOneWidget);
    expect(find.text('kcal'), findsOneWidget);
    expect(find.text('Meta: 2,100'), findsOneWidget);

    // Verify Semantics container is created
    expect(
      find.bySemanticsLabel(RegExp(r'Anillo metabólico: 1,420 kilocalorías restantes')),
      findsOneWidget,
    );
  });

  testWidgets('MetabolicRingWidget fires tap callbacks when consumed/burned cards are tapped',
      (WidgetTester tester) async {
    bool consumedTapped = false;
    bool burnedTapped = false;

    await tester.pumpWidget(
      buildTestableWidget(
        MetabolicRingWidget(
          targetCalories: 2000,
          consumedCalories: 500,
          burnedCalories: 200,
          onConsumedTap: () => consumedTapped = true,
          onBurnedTap: () => burnedTapped = true,
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Find consumed and burned cards
    final consumedFinder = find.text('CONSUMIDAS');
    expect(consumedFinder, findsOneWidget);
    await tester.tap(consumedFinder);
    await tester.pumpAndSettle();
    expect(consumedTapped, isTrue);

    final burnedFinder = find.text('QUEMADAS');
    expect(burnedFinder, findsOneWidget);
    await tester.tap(burnedFinder);
    await tester.pumpAndSettle();
    expect(burnedTapped, isTrue);
  });

  testWidgets('MetabolicRingWidget clamps remaining calories to zero when consumed exceeds target',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      buildTestableWidget(
        const MetabolicRingWidget(
          targetCalories: 1800,
          consumedCalories: 2200,
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Remaining should be clamped to 0
    expect(find.text('0'), findsOneWidget);
    expect(find.text('Meta: 1,800'), findsOneWidget);
  });
}
