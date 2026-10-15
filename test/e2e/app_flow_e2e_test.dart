import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrilengia/data/datasources/app_database.dart';
import 'package:nutrilengia/data/repositories/nutrition_repository.dart';
import 'package:nutrilengia/presentation/screens/main_shell_screen.dart';
import '../integration/test_helpers.dart';

void main() {
  setUpAll(() async {
    await setupTestDatabaseFactory();
    await AppDatabase.instance.database;
    await NutritionRepository.instance.getUserProfile();
  });

  testWidgets('NutriLens AI complete user flow E2E across all 4 primary tabs',
      (WidgetTester tester) async {
    // Suppress visual render overflow warnings during end-to-end integration flow
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      final isOverflow = details.exceptionAsString().contains('A RenderFlex overflowed') ||
          details.exceptionAsString().contains('RenderFlex overflowed');
      if (!isOverflow) {
        originalOnError?.call(details);
      }
    };
    addTearDown(() => FlutterError.onError = originalOnError);

    // Set standard mobile device view
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Render the complete app shell with standard test MaterialApp
    await tester.pumpWidget(
      const MaterialApp(
        home: MainShellScreen(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    // -------------------------------------------------------------
    // Paso 1: Dashboard Flow (Pestaña "Hoy")
    // -------------------------------------------------------------
    expect(find.text('NIA'), findsWidgets);
    expect(find.text('RESTANTES'), findsOneWidget);
    expect(find.text('kcal'), findsWidgets);

    // -------------------------------------------------------------
    // Paso 2: Historial Flow (Pestaña "Historial")
    // -------------------------------------------------------------
    final historyNav = find.text('Historial');
    expect(historyNav, findsOneWidget);
    await tester.tap(historyNav);
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('HISTORIAL'), findsOneWidget);

    // -------------------------------------------------------------
    // Paso 3: Escáner Flow (Pestaña "ESCANEAR")
    // -------------------------------------------------------------
    final scanNav = find.text('ESCANEAR');
    expect(scanNav, findsOneWidget);
    await tester.tap(scanNav);
    await tester.pump(const Duration(milliseconds: 300));

    // Verify scanner screen icon is rendered
    expect(find.byIcon(Icons.filter_center_focus_rounded), findsWidgets);

    // -------------------------------------------------------------
    // Paso 4: Perfil Flow (Pestaña "Perfil")
    // -------------------------------------------------------------
    final profileNav = find.text('Perfil');
    expect(profileNav, findsOneWidget);
    await tester.tap(profileNav);
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('PERFIL'), findsOneWidget);
    expect(find.text('Sofía Martínez'), findsOneWidget);

    // -------------------------------------------------------------
    // Paso 5: Regreso a Dashboard
    // -------------------------------------------------------------
    final hoyNav = find.text('Hoy');
    expect(hoyNav, findsOneWidget);
    await tester.tap(hoyNav);
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('RESTANTES'), findsOneWidget);
  });
}
