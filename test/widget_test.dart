import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:nutrilengia/core/theme/app_theme.dart';
import 'package:nutrilengia/presentation/widgets/nia_app_bar.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('NutriLens AI NiaAppBar smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          appBar: NiaAppBar(
            title: 'HOY',
            streakDays: 7,
          ),
          body: Center(
            child: Text('NutriLens AI'),
          ),
        ),
      ),
    );

    // Verify logo and title
    expect(find.text('NIA'), findsOneWidget);
    expect(find.text('HOY'), findsWidgets);
    expect(find.text('7d'), findsOneWidget);
  });
}
