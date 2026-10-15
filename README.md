# 🥑 NutriLens AI (NIA) — Mobile Beta v0.1.0

<p align="center">
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20(Mobile%20Only)-0A84FF?style=for-the-badge&logo=android&logoColor=white" alt="Mobile Only (Android & iOS)" />
  <img src="https://img.shields.io/badge/Flutter-3.x%20%7C%20Dart%203.x-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter SDK" />
  <img src="https://img.shields.io/badge/Database-SQLite%20Native%20(sqflite)-003B57?style=for-the-badge&logo=sqlite&logoColor=white" alt="SQLite" />
  <img src="https://img.shields.io/badge/AI-Gemini%201.5%20Multimodal%20Structured%20Outputs-8E75C2?style=for-the-badge&logo=google-gemini&logoColor=white" alt="Gemini 1.5 Multimodal" />
  <img src="https://img.shields.io/badge/Licencia-Gratuita%20No%20Comercial-2ECC71?style=for-the-badge" alt="Licencia Gratuita No Comercial" />
  <img src="https://img.shields.io/badge/Version-v0.1.0%20Beta-FF9500?style=for-the-badge" alt="Beta v0.1.0" />
</p>

> ### 💡 ¿Qué es NutriLens AI?
> **NutriLens AI (NIA)** es un asistente nutricional bioadaptativo para dispositivos móviles (**Android e iOS**) diseñado para simplificar el registro de alimentos mediante **Inteligencia Artificial Multimodal (Google Gemini 1.5)** y almacenamiento local **SQLite**.
> 
> Permite escanear comidas con la cámara o describirlas por texto/dictado, detectando ingredientes y **ajustando con precisión matemática las calorías y macronutrientes según notas de preparación invisibles** (por ejemplo: restar calorías por café sin azúcar o aderezos sin grasa). Todo sincronizado con un motor clínico basado en la fórmula **Mifflin-St Jeor** para mantener tu balance calórico diario y semanal de forma 100% privada y offline.

---

## 📑 Tabla de Contenidos
1. [Resumen Ejecutivo y Visión](#-resumen-ejecutivo-y-visión)
2. [Arquitectura Móvil (Clean Architecture / Feature-First)](#-arquitectura-móvil-clean-architecture--feature-first)
3. [Motor Bioadaptativo Mifflin-St Jeor](#-motor-bioadaptativo-mifflin-st-jeor)
4. [Stack Tecnológico Móvil](#-stack-tecnológico-móvil)
5. [Pantallas Móviles en Beta v0.1.0](#-pantallas-móviles-en-beta-v010)
6. [Instalación y Compilación (Android & iOS)](#-instalación-y-compilación-android--ios)
7. [Resiliencia Offline y Seguridad](#-resiliencia-offline-y-seguridad)
8. [Equipo y Convocatoria a la Comunidad](#-equipo-y-convocatoria-a-la-comunidad)
9. [Agradecimientos Especiales](#-agradecimientos-especiales)
10. [Licencia y Condiciones de Uso](#-licencia-y-condiciones-de-uso)

---

## 🌟 Resumen Ejecutivo y Visión

**NutriLens AI (NIA)** es un asistente nutricional inteligente de alta precisión diseñado exclusivamente para dispositivos móviles (**Android e iOS**). Combina visión computacional de última generación impulsada por **Google Gemini 1.5**, modelado matemático metabólico adaptativo y almacenamiento local persistente de latencia cero sobre **SQLite nativo**.

La misión de NutriLens AI es eliminar la fricción clásica del registro de alimentos (pesaje manual tedioso, búsqueda infinita en bases de datos genéricas y aproximaciones erróneas) ofreciendo una experiencia visual fluida e intuitiva basada en **Vitality Glassmorphism**, capaz de detectar ingredientes visibles, interpretar notas de preparación invisible (aceites, cocción, aderezos no consumidos) y rebalancear dinámicamente las metas calóricas y de macronutrientes.

```
┌────────────────────────────────────────────────────────────────────────┐
│                        NUTRILENS AI (NIA) MOBILE                       │
│                                                                        │
│   [ Cámara / Galería ] ────► [ Gemini 1.5 Multimodal ] ────► [ JSON ]  │
│             │                                                  │       │
│             ▼                                                  ▼       │
│   [ SQLite Persistente ] ◄─── [ Motor Mifflin-St Jeor ] ◄──────┘       │
│             │                                                          │
│             ▼                                                          │
│   [ Vitality Glassmorphism UI ] ───► [ Reportes Clínicos PDF ]         │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 🏛️ Arquitectura Móvil (Clean Architecture / Feature-First)

El proyecto implementa una arquitectura desacoplada y orientada al dominio en 4 capas estrictas, maximizando la testabilidad, el rendimiento a 60/120 FPS y el mantenimiento a largo plazo:

```
lib/
├── core/                  # Fundamentos de plataforma, temas y seguridad
│   ├── constants/         # Colores del sistema bio-tech y dimensiones
│   ├── di/                # Inyección de dependencias
│   ├── security/          # ApiKeyVault con ofuscación XOR y compilación segura
│   └── theme/             # Tema Vitality Glassmorphism & Plus Jakarta Sans
├── data/                  # Capa de datos y persistencia SQLite nativa
│   ├── datasources/       # AppDatabase con auto-seeding y migraciones
│   ├── models/            # UserProfile, MealItem, AiAnalysisResult
│   └── repositories/      # NutritionRepository (contrato reactivo de datos)
├── services/              # Servicios externos y procesamiento local
│   ├── gemini_ai_service.dart   # Cliente multimodal Gemini 1.5 + Fallback Offline
│   └── pdf_export_service.dart  # Motor de generación y reporte clínico en PDF
└── presentation/          # Capa de UI y experiencia de usuario táctil
    ├── screens/           # DashboardScreen, ScanScreen, HistoryScreen, ProfileScreen
    └── widgets/           # DualRingMetabolicPainter, WeeklyBarChartPainter, GlassCards
```

### Detalle por Capas:

1. **Presentation Layer (UI / UX Táctil Móvil):**
   - **Estética Vitality Glassmorphism:** Superficies translúcidas con blur gaussiano, bordes bio-luminosos (`#10B981`, `#059669`) y gradientes metabólicos de contraste optimizado.
   - **CustomPainters Matemáticos:** Renderizado vectorial por hardware para el **Anillo Metabólico Dual** (calorías consumidas vs. quemadas activas) y las **Gráficas de Barras Semanales** con detección de metas cumplidas.
   - **Optimización 100% Mobile:** Totalmente adaptada a áreas seguras (*SafeArea*), muescas (*notches*), teclados virtuales flotantes y ergonomía táctil a una sola mano.

2. **Core Layer (Infraestructura y Seguridad):**
   - **Temas Bio-Tech:** Paleta cromática biométrica (Emerald `#10B981`, Amber `#F59E0B`, Indigo `#6366F1`, Burn Orange `#F97316`).
   - **`ApiKeyVault` Seguro:** Gestión de tokens mediante inyección segura en tiempo de compilación con `--dart-define=GEMINI_API_KEY=...`, almacenamiento ofuscado simétrico (XOR + Base64) y soporte para claves personalizadas en caliente desde la configuración del perfil.

3. **Data Layer (Persistencia SQLite Nativa):**
   - Implementado con `sqflite` y `path_provider` para iOS y Android.
   - **Auto-seeding inteligente:** Inicialización automática con el perfil de usuario bioadaptativo y un historial realista de comidas de 7 días (desayuno, almuerzo, cena, snacks) con macronutrientes balanceados.
   - Operaciones CRUD atómicas y consultas optimizadas por fecha con agregaciones inmediatas de calorías y macros.

4. **Services Layer (IA Multimodal y Reportes Clínicos):**
   - **Integración Multimodal Gemini 1.5:** Análisis simultáneo de fotografía + descripción + notas con salida estricta en JSON estructurado (*Structured Outputs*).
   - **Motor Resiliente Offline:** En caso de operar en modo avión, zonas sin cobertura o sin API Key, el servicio ejecuta una estimación nutricional algorítmica instantánea sin interrumpir el flujo del usuario.
   - **Motor de Exportación PDF Clínico:** Generación en el dispositivo de reportes clínicos profesionales listos para compartir con médicos y nutricionistas vía AirPrint, Android Print Manager o mensajería.

---

## ⚡ Motor Bioadaptativo Mifflin-St Jeor

NutriLens AI cuenta con un motor metabólico clínico integrado que calcula con rigor fisiológico las necesidades energéticas individuales:

$$\text{BMR}_{\text{Mujer}} = (10 \times \text{peso [kg]}) + (6.25 \times \text{altura [cm]}) - (5 \times \text{edad [años]}) - 161$$

$$\text{BMR}_{\text{Hombre}} = (10 \times \text{peso [kg]}) + (6.25 \times \text{altura [cm]}) - (5 \times \text{edad [años]}) + 5$$

$$\text{TDEE} = \text{BMR} \times \text{Factor de Actividad}$$

$$\text{Meta Calórica Diaria} = \text{TDEE} \times (1 + \text{Ajuste de Objetivo})$$

### Distribución de Macronutrientes en Tiempo Real:
- **Carbohidratos (4 kcal/g):** $\frac{\text{Meta} \times \%_{\text{Carbs}}}{4}$
- **Proteínas (4 kcal/g):** $\frac{\text{Meta} \times \%_{\text{Proteínas}}}{4}$
- **Grasas (9 kcal/g):** $\frac{\text{Meta} \times \%_{\text{Grasas}}}{9}$
- **Validación Automática:** Los sliders de la pantalla de perfil aseguran siempre una suma exactamente igual al **100%**, recalculando instantáneamente los gramos recomendados.

---

## 🛠️ Stack Tecnológico Móvil

| Componente | Tecnología | Propósito |
|---|---|---|
| **Framework Base** | **Flutter 3.x** | SDK de desarrollo móvil nativo de alto rendimiento para Android e iOS |
| **Lenguaje** | **Dart 3.x** | Lenguaje tipado seguro y compilación AOT nativa para ARM64 |
| **Persistencia Local** | **SQLite (`sqflite`)** | Motor de base de datos relacional local embebido en el dispositivo |
| **File System Móvil** | **`path_provider`** | Resolución de directorios nativos de documentos y caché en Android e iOS |
| **Inteligencia Artificial** | **Google Gemini 1.5 API** | Modelo multimodal (Visión + Texto) con esquema JSON estructurado |
| **Seguridad de Tokens** | **`ApiKeyVault` (XOR Engine)** | Ofuscación simétrica en memoria e inyección `--dart-define` |
| **Generación de Reportes** | **`pdf` + `printing`** | Maquetación e impresión nativa de fichas clínicas y exportación |
| **Tipografía** | **`google_fonts` (Plus Jakarta Sans)** | Tipografía de grado biomédico de máxima legibilidad en displays móviles |
| **Captura Multimedia** | **`image_picker`** | Acceso a la cámara nativa del sistema operativo y galería multimedia |
| **Formateo y Fechas** | **`intl`** | Localización de divisas, métricas, porcentajes y fechas |

---

## 📱 Pantallas Móviles en Beta v0.1.0

### 1. Dashboard Principal ("Hoy")
* **Anillo Metabólico Dual (CustomPainter):** Visualización concéntrica de calorías ingeridas frente a la meta y gasto basal/activo.
* **Métricas Clave:** Contador de calorías restantes con indicador dinámico de superávit o déficit, días de racha acumulada y porcentaje de adherencia.
* **Desglose de Macros:** Barras de progreso de Proteínas, Carbohidratos y Grasas con gramos consumidos vs. objetivo.
* **Insight Bioadaptativo:** Tarjeta inteligente con recomendaciones personalizadas según el momento del día y las comidas registradas.
* **Feed de Comidas de Hoy:** Tarjetas detalladas de Desayuno, Almuerzo, Cena y Snacks con tiempos, calorías, macronutrientes y acciones rápidas.

### 2. Registro y Análisis IA ("Escanear")
* **Visor de Cámara con Encuadre Holográfico:** Interfaz de escaneo táctil con guías de encuadre bio-tech y botones para cámara o galería.
* **Pins Interactivos de Alimentos:** Detección visual con pines flotantes que identifican ingredientes individuales.
* **Dictado por Voz y Entrada de Texto:** Modalidad de captura para registrar alimentos mediante comandos de voz o texto libre.
* **Ajuste Fino por Notas Invisibles:** Capacidad exclusiva de compensar cocciones, aceites o ingredientes no consumidos (ej. *"sin aderezo ni aceite de oliva"* restando dinámicamente `-65 kcal` y reajustando macros).
* **Modal Bottom Sheet Nutricional:** Confirmación interactiva previa al guardado en SQLite con desglose completo y opción de ajuste manual.

### 3. Historial Semanal y Exportación PDF ("Historial")
* **Tira de Días Semanales:** Carrusel interactivo de los últimos 7 días con indicadores de meta calórica alcanzada (✓).
* **Métricas Agregadas:** Promedio de consumo calórico diario y déficit neto alcanzado en la semana.
* **Gráfico de Barras Consumo vs. Meta:** CustomPainter vectorial con barras comparativas que destacan días en superávit o déficit.
* **Feed Filtrable:** Filtrado instantáneo por día y tipo de comida.
* **Exportación Clínica en PDF:** Botón de un toque para compilar y visualizar el reporte semanal clínico listo para imprimir o enviar por correo/mensajería.

### 4. Perfil & Motor Metabólico ("Perfil")
* **Calculadora Mifflin-St Jeor en Tiempo Real:** Ajustes dinámicos de peso actual, peso meta, altura, edad, género y factor de actividad.
* **Sliders Interactivos de Macros (Suma 100%):** Controladores táctiles con validación estricta de suma total para carbohidratos, proteínas y grasas.
* **Switches de Automatización:** Compensación metabólica automática por IA y recordatorios inteligentes de comidas.
* **Gestión de API Key:** Configuración segura de clave personalizada de Gemini con opción de limpieza inmediata.

---

## 🚀 Instalación y Compilación (Android & iOS)

> **Nota:** NutriLens AI es una aplicación móvil nativa. Requiere el SDK de Flutter configurado en tu entorno de desarrollo.

### Prerrequisitos Comunes
- **Flutter SDK:** versión 3.13 o superior (`flutter --version`)
- **Dart SDK:** versión 3.0 o superior
- **Git**

```bash
# Clonar el repositorio
git clone https://github.com/tu-usuario/nutrilengia.git
cd nutrilengia

# Descargar las dependencias
flutter pub get
```

---

### 🤖 Ejecución en Android

#### Requisitos de Android:
- **Android Studio** (Koala / Ladybug o superior) con SDK Tools actualizados.
- **Java Development Kit (JDK):** Versión 17 recomendada.
- **Android SDK:** API Level 24 (Android 7.0) como mínimo, API Level 34+ para compilación óptima.
- Dispositivo físico Android con depuración USB activada o un emulador AVD activo.

#### Comando de Ejecución:
```bash
# Ejecución en emulador o dispositivo físico Android con tu API Key de Gemini:
flutter run -d android --dart-define=GEMINI_API_KEY=tu_gemini_api_key_aqui
```

Para generar el APK de lanzamiento optimizado:
```bash
flutter build apk --release --dart-define=GEMINI_API_KEY=tu_gemini_api_key_aqui
```

---

### 🍎 Ejecución en iOS

#### Requisitos de iOS:
- Sistema Operativo **macOS** (Sonoma o superior).
- **Xcode** 15 o superior instalado con herramientas de línea de comandos (`xcode-select --install`).
- **CocoaPods** instalado (`sudo gem install cocoapods` o vía `brew install cocoapods`).
- Simulador de iOS o iPhone físico con perfil de desarrollador configurado.

#### Preparación y Comando de Ejecución:
```bash
# Instalar los pods nativos de iOS
cd ios
pod install
cd ..

# Ejecución en simulador o dispositivo físico iOS:
flutter run -d ios --dart-define=GEMINI_API_KEY=tu_gemini_api_key_aqui
```

Para compilar el archivo `.ipa` de lanzamiento:
```bash
flutter build ipa --release --dart-define=GEMINI_API_KEY=tu_gemini_api_key_aqui
```

---

## 🛡️ Resiliencia Offline y Seguridad

1. **Funcionamiento Autónomo sin Conexión:**
   NutriLens AI está diseñado para **no fallar nunca**. Si el dispositivo se encuentra sin conexión a Internet o si no se ha configurado ninguna clave de API (`GEMINI_API_KEY`), la aplicación conmuta de forma transparente e imperceptible a su **motor de inferencia nutricional algorítmico local**. Las comidas se registran y computan con exactitud en la base de datos local SQLite.

2. **Seguridad Biométrica y Privacidad Local:**
   Toda la información del perfil del usuario, medidas antropométricas y registros de ingesta permanecen estrictamente confinados en el almacenamiento del dispositivo móvil (`sqflite`). No existe telemetría invasiva ni almacenamiento de datos privados en servidores de terceros.

3. **Seguridad de Tokens:**
   La clave de Google Gemini se procesa a través de `ApiKeyVault`, permitiendo compilaciones seguras sin dejar secretos expuestos en el código fuente.

---

## 👥 Equipo y Convocatoria a la Comunidad

### Desarrollador Móvil Principal
- **Ing. Jorge Luis Fernández** — *Arquitecto de Solución y Desarrollador Móvil Principal.*

---

### 🤝 Convocatoria Abierta a Colaboradores
¡NutriLens AI es un proyecto abierto y en activa expansión! Si eres:
- 📱 **Desarrollador Flutter / Dart:** interesado en optimizaciones de rendimiento, animaciones fluidas o integración nativa.
- 🎨 **Diseñador UI/UX:** con propuestas para enriquecer el sistema visual *Vitality Glassmorphism* o la accesibilidad táctil.
- 🥗 **Profesional de la Salud, Nutrición o Medicina Deportiva:** que desee validar algoritmos bioadaptativos o proponer nuevas fórmulas clínicas.
- 🧪 **Tester / QA:** que desee probar la beta en distintos modelos de dispositivos Android e iOS y reportar edge cases.

Te invitamos formalmente a:
1. Abrir un **Issue** para reportar fallos, inconsistencias o proponer nuevas funcionalidades.
2. Enviar un **Pull Request** siguiendo la arquitectura por capas y las guías de estilo del proyecto.
3. Compartir ideas y debatir en los canales de discusión del repositorio.

---

## 🙏 Agradecimientos Especiales

- A **toda la comunidad activa de colaboradores** que día a día prueban la aplicación, envían sugerencias y contribuyen con código de calidad.
- A la **comunidad global de Flutter y Dart**, por proveer el ecosistema de desarrollo móvil multiplataforma más robusto y versátil de la industria.
- A los equipos de **Google AI** por el desarrollo de la API de Gemini 1.5 y sus innovaciones en comprensión multimodal estructurada.

---

## ⚖️ Licencia y Condiciones de Uso

Este proyecto se distribuye bajo una **Licencia de Uso Libre y Gratuito No Comercial**:

- ✅ **Uso Personal Libre:** Eres libre de descargar, compilar, instalar y usar NutriLens AI en tus propios dispositivos móviles de forma completamente gratuita.
- ✅ **Estudio y Aprendizaje:** Tienes derecho a estudiar el código fuente, bifurcarlo (*fork*) para fines de investigación académica o aprendizaje personal.
- 🚫 **Restricción Comercial Estricta:** **Queda estrictamente prohibida** la venta, comercialización, monetización directa o indirecta, redistribución de binarios con fines de lucro o uso de este software como parte de cualquier producto o servicio comercial sin la autorización previa, expresa y por escrito del autor principal.

---

<p align="center">
  <b>NutriLens AI (NIA)</b> • Transformando la nutrición inteligente en el bolsillo de cada usuario.
</p>
