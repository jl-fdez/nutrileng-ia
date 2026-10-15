import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrilengia/core/theme/app_theme.dart';
import 'package:nutrilengia/presentation/widgets/macro_progress_bar.dart';

void main() {
  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: Center(
          child: SizedBox(width: 360, child: child),
        ),
      ),
    );
  }

  testWidgets('MacroProgressBar renders all three macro categories and progress bars',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      buildTestableWidget(
        const MacroProgressBar(
          carbsCurrent: 90,
          carbsTarget: 200,
          proteinCurrent: 80,
          proteinTarget: 140,
          fatCurrent: 30,
          fatTarget: 60,
          animate: false,
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify labels are displayed
    expect(find.text('Carbohidratos'), findsOneWidget);
    expect(find.text('Proteínas'), findsOneWidget);
    expect(find.text('Grasas'), findsOneWidget);

    final semantics = tester.ensureSemantics();
    expect(
      find.bySemanticsLabel(RegExp(r'Carbohidratos: 90 gramos de 200 gramos')),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(RegExp(r'Proteínas: 80 gramos de 140 gramos')),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(RegExp(r'Grasas: 30 gramos de 60 gramos')),
      findsOneWidget,
    );
    semantics.dispose();
  });

  test('MacroItemData calculates progress accurately with clamp at 1.0', () {
    const normal = MacroItemData(
      label: 'Proteínas',
      currentGrams: 50,
      targetGrams: 100,
      color: Colors.blue,
    );
    expect(normal.progress, equals(0.5));

    const exceeded = MacroItemData(
      label: 'Proteínas',
      currentGrams: 150,
      targetGrams: 100,
      color: Colors.blue,
    );
    expect(exceeded.progress, equals(1.0));

    const zeroTarget = MacroItemData(
      label: 'Proteínas',
      currentGrams: 20,
      targetGrams: 0,
      color: Colors.blue,
    );
    expect(zeroTarget.progress, equals(0.0));
  });
}
