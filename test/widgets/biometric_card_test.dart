import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrilengia/core/theme/app_theme.dart';
import 'package:nutrilengia/presentation/widgets/biometric_card.dart';

void main() {
  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }

  testWidgets('BiometricCard renders biometric data header, tiles and values',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      buildTestableWidget(
        const BiometricCard(
          currentWeight: 68.5,
          targetWeight: 62.0,
          age: 29,
          height: 168.0,
          gender: 'Femenino',
          activityFactor: 1.55,
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Header
    expect(find.text('Datos Biométricos'), findsOneWidget);
    expect(find.text('Ajuste Dinámico'), findsOneWidget);

    // Verify Metric Tiles
    expect(find.text('Peso actual'), findsOneWidget);
    expect(find.text('68.5 kg'), findsOneWidget);

    expect(find.text('Peso objetivo'), findsOneWidget);
    expect(find.text('62.0 kg'), findsOneWidget);

    expect(find.text('Edad'), findsOneWidget);
    expect(find.text('29 años'), findsOneWidget);

    expect(find.text('Altura'), findsOneWidget);
    expect(find.text('168 cm'), findsOneWidget);
  });

  testWidgets('BiometricCard opens editing dialog on tile tap',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      buildTestableWidget(
        const BiometricCard(
          currentWeight: 68.5,
          targetWeight: 62.0,
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Tap on Current Weight tile to open dialog
    await tester.tap(find.text('68.5 kg'));
    await tester.pumpAndSettle();

    // Verify dialog appears
    expect(find.text('Modificar Peso actual'), findsOneWidget);
    expect(find.text('Cancelar'), findsOneWidget);
    expect(find.text('Guardar'), findsOneWidget);

    // Close dialog
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    expect(find.text('Modificar Peso actual'), findsNothing);
  });
}
