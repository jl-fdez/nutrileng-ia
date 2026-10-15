import 'package:flutter/widgets.dart';
import '../../data/datasources/app_database.dart';
import '../../data/repositories/nutrition_repository.dart';

/// Central dependency initialization and service locator provider
class Injection {
  Injection._();

  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize local SQLite database and pre-seed initial data
    await AppDatabase.instance.database;

    // Pre-cache user profile in memory repository
    await NutritionRepository.instance.getUserProfile();
  }
}
