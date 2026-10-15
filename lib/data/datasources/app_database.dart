import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/meal_item.dart';
import '../models/user_profile.dart';

/// Fuente de datos local SQLite con soporte multiplataforma (Móvil, Windows, macOS, Linux).
class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Configuración FFI en plataformas de escritorio
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    String dbPath;
    if (kIsWeb) {
      dbPath = 'nutrilens_ai.db';
    } else {
      final documentsDirectory = await getApplicationDocumentsDirectory();
      dbPath = join(documentsDirectory.path, 'nutrilens_ai.db');
    }

    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // 1. Tabla de Perfil de Usuario
    await db.execute('''
      CREATE TABLE user_profile (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        is_pro INTEGER NOT NULL DEFAULT 1,
        age INTEGER NOT NULL,
        weight_kg REAL NOT NULL,
        target_weight_kg REAL NOT NULL,
        height_cm REAL NOT NULL,
        gender TEXT NOT NULL,
        activity_level REAL NOT NULL,
        activity_level_name TEXT NOT NULL,
        goal_adjustment REAL NOT NULL,
        goal_type TEXT NOT NULL,
        custom_calorie_target INTEGER,
        carbs_ratio REAL NOT NULL,
        protein_ratio REAL NOT NULL,
        fat_ratio REAL NOT NULL,
        streak_days INTEGER NOT NULL,
        weight_progress_kg REAL NOT NULL,
        adherence_percent INTEGER NOT NULL,
        meal_reminders_enabled INTEGER NOT NULL DEFAULT 1,
        ai_metabolic_compensation_enabled INTEGER NOT NULL DEFAULT 1,
        updated_at TEXT NOT NULL
      )
    ''');

    // 2. Tabla de Comidas y Registros IA
    await db.execute('''
      CREATE TABLE meals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        meal_type TEXT NOT NULL,
        calories INTEGER NOT NULL,
        protein_g REAL NOT NULL,
        carbs_g REAL NOT NULL,
        fat_g REAL NOT NULL,
        fiber_g REAL DEFAULT 0,
        sodium_mg INTEGER DEFAULT 0,
        date_time TEXT NOT NULL,
        time_string TEXT,
        image_path TEXT,
        detected_ingredients_json TEXT,
        user_notes TEXT,
        applied_adjustment INTEGER DEFAULT 0,
        adjustment_calories INTEGER DEFAULT 0,
        adjustment_reason TEXT,
        ai_coach_feedback TEXT,
        is_ai_validated INTEGER DEFAULT 1,
        validation_tag TEXT
      )
    ''');

    // Pre-sembrar datos de demostración idénticos a los mocks oficiales
    await _seedInitialData(db);
  }

  Future<void> _seedInitialData(Database db) async {
    final sofia = UserProfile.defaultSofia();
    await db.insert(
      'user_profile',
      sofia.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    final now = DateTime.now();

    // Helper para generar fechas de la semana actual
    DateTime dayAt(int daysAgo, int hour, int minute) {
      return DateTime(now.year, now.month, now.day, hour, minute)
          .subtract(Duration(days: daysAgo));
    }

    final initialMeals = <MealItem>[
      // --- HOY ---
      MealItem(
        name: 'Tostadas de aguacate con huevo',
        mealType: MealType.breakfast,
        calories: 410,
        proteinG: 18,
        carbsG: 35,
        fatG: 16,
        fiberG: 5,
        sodiumMg: 310,
        dateTime: dayAt(0, 9, 15),
        timeString: '9:15 AM',
        userNotes: '+ Café negro (sin azúcar)',
        isAiValidated: true,
        validationTag: 'Escaneado por IA • 9:15 AM',
        detectedIngredients: const [
          DetectedIngredient(name: 'Pan tostado integral', portion: '2 rebanadas', calories: 150),
          DetectedIngredient(name: 'Aguacate hass', portion: '60g', calories: 95),
          DetectedIngredient(name: 'Huevo pochado', portion: '1 unidad', calories: 75),
          DetectedIngredient(name: 'Semillas de sésamo', portion: '5g', calories: 25),
          DetectedIngredient(name: 'Café negro sin azúcar', portion: '200ml', calories: 5),
        ],
      ),
      MealItem(
        name: 'Bowl de salmón, quinoa y edamame',
        mealType: MealType.lunch,
        calories: 580,
        proteinG: 42,
        carbsG: 48,
        fatG: 22,
        fiberG: 7,
        sodiumMg: 390,
        dateTime: dayAt(0, 13, 30),
        timeString: '1:30 PM',
        userNotes: 'Alto en Omega 3 y proteína magra',
        isAiValidated: true,
        validationTag: 'IA validada • 1:30 PM',
        detectedIngredients: const [
          DetectedIngredient(name: 'Salmón fresco a la plancha', portion: '140g', calories: 260),
          DetectedIngredient(name: 'Quinoa real cocida', portion: '110g', calories: 135),
          DetectedIngredient(name: 'Edamame japonés', portion: '50g', calories: 60),
          DetectedIngredient(name: 'Palta en cubos', portion: '40g', calories: 65),
          DetectedIngredient(name: 'Pepino y vinagre de arroz', portion: '60g', calories: 30),
        ],
      ),

      // --- AYER (Día -1) ---
      MealItem(
        name: 'Café & Tostada con ricotta',
        mealType: MealType.breakfast,
        calories: 290,
        proteinG: 14,
        carbsG: 28,
        fatG: 7,
        fiberG: 3,
        sodiumMg: 210,
        dateTime: dayAt(1, 8, 30),
        timeString: '8:30 AM',
        userNotes: 'Café negro sin azúcar.',
        isAiValidated: true,
        validationTag: 'IA validada • 8:30 AM',
        detectedIngredients: const [
          DetectedIngredient(name: 'Tostada masa madre', portion: '1 rebanada', calories: 120),
          DetectedIngredient(name: 'Queso ricotta magro', portion: '50g', calories: 80),
          DetectedIngredient(name: 'Miel orgánica', portion: '1 cdta', calories: 25),
          DetectedIngredient(name: 'Café tostado', portion: '1 taza', calories: 2),
        ],
      ),
      MealItem(
        name: 'Bowl de Quinoa & Salmón',
        mealType: MealType.lunch,
        calories: 580,
        proteinG: 38,
        carbsG: 45,
        fatG: 18,
        fiberG: 6,
        sodiumMg: 340,
        dateTime: dayAt(1, 13, 45),
        timeString: '1:45 PM',
        userNotes: 'Sin aderezos pesados, vinagreta ligera.',
        isAiValidated: true,
        validationTag: 'IA validada • 1:45 PM',
        detectedIngredients: const [
          DetectedIngredient(name: 'Salmón noruego', portion: '130g', calories: 250),
          DetectedIngredient(name: 'Quinoa tricolor', portion: '120g', calories: 150),
          DetectedIngredient(name: 'Mix de hojas verdes', portion: '1 bowl', calories: 25),
          DetectedIngredient(name: 'Vinagreta de limón y oliva', portion: '10g', calories: 45),
        ],
      ),
      MealItem(
        name: 'Wrap de pavo y vegetales crujientes',
        mealType: MealType.dinner,
        calories: 490,
        proteinG: 35,
        carbsG: 38,
        fatG: 14,
        fiberG: 5,
        sodiumMg: 420,
        dateTime: dayAt(1, 20, 15),
        timeString: '8:15 PM',
        userNotes: 'Tortilla integral sin salsas artificiales.',
        isAiValidated: true,
        validationTag: 'IA validada • 8:15 PM',
      ),

      // --- HACE 2 DÍAS (Día -2) ---
      MealItem(
        name: 'Yogur griego con frutos rojos y nueces',
        mealType: MealType.breakfast,
        calories: 340,
        proteinG: 22,
        carbsG: 30,
        fatG: 10,
        fiberG: 4,
        sodiumMg: 90,
        dateTime: dayAt(2, 8, 45),
        timeString: '8:45 AM',
      ),
      MealItem(
        name: 'Bowl de pollo teriyaki y arroz integral',
        mealType: MealType.lunch,
        calories: 620,
        proteinG: 46,
        carbsG: 58,
        fatG: 16,
        fiberG: 5,
        sodiumMg: 480,
        dateTime: dayAt(2, 14, 0),
        timeString: '2:00 PM',
      ),
      MealItem(
        name: 'Pechuga con verduras',
        mealType: MealType.dinner,
        calories: 460,
        proteinG: 48,
        carbsG: 16,
        fatG: 12,
        fiberG: 5,
        sodiumMg: 280,
        dateTime: dayAt(2, 20, 15),
        timeString: '8:15 PM',
        userNotes: 'Hecho en airfryer con spray de oliva.',
        isAiValidated: true,
        validationTag: 'IA validada • 8:15 PM',
        detectedIngredients: const [
          DetectedIngredient(name: 'Pechuga de pollo a la plancha', portion: '180g', calories: 240),
          DetectedIngredient(name: 'Mix de verduras asadas', portion: '150g', calories: 85),
          DetectedIngredient(name: 'Aceite de oliva spray', portion: '3g', calories: 30),
        ],
      ),

      // --- DÍAS RESTANTES DE LA SEMANA (Promedio diario objetivo: ~1840 kcal) ---
      MealItem(
        name: 'Omelette de espinacas y queso feta',
        mealType: MealType.breakfast,
        calories: 380,
        proteinG: 26,
        carbsG: 8,
        fatG: 20,
        dateTime: dayAt(3, 9, 0),
      ),
      MealItem(
        name: 'Pescado blanco con puré de coliflor',
        mealType: MealType.lunch,
        calories: 590,
        proteinG: 44,
        carbsG: 32,
        fatG: 18,
        dateTime: dayAt(3, 14, 0),
      ),
      MealItem(
        name: 'Ensalada tibia de lentejas y queso de cabra',
        mealType: MealType.dinner,
        calories: 480,
        proteinG: 28,
        carbsG: 46,
        fatG: 14,
        dateTime: dayAt(3, 20, 30),
      ),
      MealItem(
        name: 'Smoothie bowl de proteína y chía',
        mealType: MealType.breakfast,
        calories: 390,
        proteinG: 28,
        carbsG: 42,
        fatG: 9,
        dateTime: dayAt(4, 8, 30),
      ),
      MealItem(
        name: 'Atún sellado con espárragos y arroz basmati',
        mealType: MealType.lunch,
        calories: 610,
        proteinG: 48,
        carbsG: 46,
        fatG: 17,
        dateTime: dayAt(4, 13, 30),
      ),
      MealItem(
        name: 'Sopa detox de calabaza y semillas',
        mealType: MealType.dinner,
        calories: 440,
        proteinG: 18,
        carbsG: 35,
        fatG: 12,
        dateTime: dayAt(4, 20, 0),
      ),
      MealItem(
        name: 'Pancakes de avena y plátano con canela',
        mealType: MealType.breakfast,
        calories: 420,
        proteinG: 18,
        carbsG: 62,
        fatG: 8,
        dateTime: dayAt(5, 9, 30),
      ),
      MealItem(
        name: 'Carne magra a la parrilla con boniato',
        mealType: MealType.lunch,
        calories: 650,
        proteinG: 50,
        carbsG: 50,
        fatG: 19,
        dateTime: dayAt(5, 14, 15),
      ),
      MealItem(
        name: 'Tartar de atún con aguacate',
        mealType: MealType.dinner,
        calories: 460,
        proteinG: 36,
        carbsG: 12,
        fatG: 22,
        dateTime: dayAt(5, 20, 45),
      ),
      MealItem(
        name: 'Revuelto de claras con champiñones',
        mealType: MealType.breakfast,
        calories: 350,
        proteinG: 30,
        carbsG: 14,
        fatG: 11,
        dateTime: dayAt(6, 9, 0),
      ),
      MealItem(
        name: 'Poke bowl mixto con edamame y algas wakame',
        mealType: MealType.lunch,
        calories: 630,
        proteinG: 44,
        carbsG: 55,
        fatG: 18,
        dateTime: dayAt(6, 14, 0),
      ),
      MealItem(
        name: 'Pechuga a la plancha con espinacas baby',
        mealType: MealType.dinner,
        calories: 450,
        proteinG: 45,
        carbsG: 10,
        fatG: 12,
        dateTime: dayAt(6, 20, 30),
      ),
    ];

    for (final meal in initialMeals) {
      await db.insert('meals', meal.toMap());
    }
  }

  // ==========================================
  // OPERACIONES CRUD DE PERFIL
  // ==========================================

  Future<UserProfile> getUserProfile() async {
    final db = await database;
    final res = await db.query('user_profile', where: 'id = ?', whereArgs: [1]);
    if (res.isNotEmpty) {
      return UserProfile.fromMap(res.first);
    }
    final defaultProfile = UserProfile.defaultSofia();
    await db.insert('user_profile', defaultProfile.toMap());
    return defaultProfile;
  }

  Future<int> updateUserProfile(UserProfile profile) async {
    final db = await database;
    return await db.update(
      'user_profile',
      profile.toMap(),
      where: 'id = ?',
      whereArgs: [profile.id],
    );
  }

  // ==========================================
  // OPERACIONES CRUD DE COMIDAS
  // ==========================================

  Future<int> insertMeal(MealItem meal) async {
    final db = await database;
    return await db.insert('meals', meal.toMap());
  }

  Future<List<MealItem>> getAllMeals() async {
    final db = await database;
    final res = await db.query('meals', orderBy: 'date_time DESC');
    return res.map((m) => MealItem.fromMap(m)).toList();
  }

  Future<List<MealItem>> getMealsByDate(DateTime date) async {
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day).toIso8601String();
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59).toIso8601String();

    final res = await db.query(
      'meals',
      where: 'date_time >= ? AND date_time <= ?',
      whereArgs: [startOfDay, endOfDay],
      orderBy: 'date_time ASC',
    );
    return res.map((m) => MealItem.fromMap(m)).toList();
  }

  Future<List<MealItem>> getMealsByDateRange(DateTime start, DateTime end) async {
    final db = await database;
    final startStr = start.toIso8601String();
    final endStr = end.toIso8601String();

    final res = await db.query(
      'meals',
      where: 'date_time >= ? AND date_time <= ?',
      whereArgs: [startStr, endStr],
      orderBy: 'date_time ASC',
    );
    return res.map((m) => MealItem.fromMap(m)).toList();
  }

  Future<int> deleteMeal(int id) async {
    final db = await database;
    return await db.delete('meals', where: 'id = ?', whereArgs: [id]);
  }
}
