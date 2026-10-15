# 🥑 Guía de Contribución y Gobernanza — NutriLens AI (NIA)

¡Gracias por tu interés en contribuir a **NutriLens AI (NIA)**! Para mantener la estabilidad, excelencia técnica, cohesión visual y rigor metabólico del proyecto, todas las colaboraciones deben adherirse estrictamente a las directrices de gobernanza y calidad descritas en este documento.

---

## 🚨 REGLA INMUTABLE: Prohibición de Commits Directos a `main`

> ### ⛔ ATENCIÓN: POLÍTICA DE PROTECCIÓN DE RAMAS
> **Está estrictamente prohibido realizar commits directos o `git push` a la rama `main`.**
> 
> La rama `main` representa exclusivamente código en estado de producción estable y verificado. Cualquier cambio sin excepción debe pasar por el flujo de desarrollo en ramas secundarias, validación automatizada y **revisión/aprobación formal del mantenedor principal**.

---

## 👑 Liderazgo del Proyecto y Propiedad del Repositorio

El diseño de arquitectura, gobernanza y mantenimiento principal de **NutriLens AI** está bajo la dirección del:

* **Ing. Jorge Luis Fernández** — *Arquitecto de Solución, Desarrollador Móvil Principal y Mantenedor del Repositorio.*

Cualquier incorporación de código, refactorización estructural, integración de nuevos modelos de IA o alteración a los motores metabólicos requiere obligatoriamente su revisión y aprobación explícita.

---

## 🔄 Flujo de Trabajo Obligatorio para Colaboradores

Para garantizar una integración limpia y sin conflictos, todos los colaboradores deben seguir el siguiente procedimiento paso a paso:

```
┌─────────────────────────────────┐
│ 1. Crear Feature Proposal/Issue │ ──► ¿Aprobado por Ing. Jorge Luis Fernández?
└─────────────────────────────────┘                       │ (Sí)
                                                          ▼
┌─────────────────────────────────┐           ┌──────────────────────┐
│  3. Crear Rama Estandarizada    │ ◄──────── │ 2. Fork / Clone Repo │
│   (feat/*, fix/*, chore/*)      │           └──────────────────────┘
└─────────────────────────────────┘
                │
                ▼
┌─────────────────────────────────┐
│ 4. Desarrollo Local & Calidad   │
│   • flutter analyze (0 issues)  │
│   • flutter test (100% OK)      │
└─────────────────────────────────┘
                │
                ▼
┌─────────────────────────────────┐
│ 5. Abrir Pull Request a 'main'  │ ──► Completar plantilla obligatoria
└─────────────────────────────────┘
                │
                ▼
┌─────────────────────────────────┐
│ 6. Code Review y Merge          │ ──► Aprobación final: Ing. Jorge Luis Fernández
└─────────────────────────────────┘
```

### 1. Propuesta de Funcionalidad o Reporte de Error (Issue Obligatorio)
Antes de redactar código nuevo:
- Abre un **Issue** en GitHub utilizando la plantilla correspondiente:
  - **`feature_proposal.yml`**: Para nuevas funcionalidades, cambios de UI o ajustes en algoritmos.
  - **`bug_report.yml`**: Para reportar fallos en Android o iOS.
- **Espera la discusión y aprobación del Ing. Jorge Luis Fernández** antes de invertir tiempo de desarrollo. Las contribuciones no alineadas con el roadmap o la arquitectura serán rechazadas.

### 2. Fork y Clonación del Repositorio
Crea un fork de NutriLens AI en tu cuenta personal de GitHub y clónalo localmente:
```bash
git clone https://github.com/tu-usuario/nutrilengia.git
cd nutrilengia
git remote add upstream https://github.com/jorge-nutrilens/nutrilengia.git
```

### 3. Nomenclatura Estandarizada de Ramas
Crea una rama específica para tu contribución partiendo de la última versión de `main`:
- `feat/<nombre-descriptivo-kebab-case>`: Nuevas funcionalidades o mejoras.
- `fix/<nombre-descriptivo-kebab-case>`: Corrección de errores y bugs.
- `refactor/<nombre-descriptivo-kebab-case>`: Reestructuración de código sin alterar comportamiento.
- `chore/<nombre-descriptivo-kebab-case>`: Tareas de mantenimiento, dependencias o tooling.
- `docs/<nombre-descriptivo-kebab-case>`: Actualización de documentación.

*Ejemplo:*
```bash
git checkout -b feat/voice-dictation-haptic
```

### 4. Estándares de Calidad y Verificación Local (Gates de Aceptación)
Antes de solicitar revisión, tu rama debe cumplir con un **100% de conformidad**:
1. **Análisis Estático Impecable:**
   ```bash
   flutter analyze
   ```
   *Debe reportar `No issues found!`. No se aceptarán PRs con advertencias (warnings) ni violaciones de linting.*
2. **Suite de Pruebas Unitaria y de Widgets Exitosa:**
   ```bash
   flutter test
   ```
   *Todas las pruebas deben ejecutarse y aprobarse al 100%. Si introduces una nueva funcionalidad o corriges un bug, debes incluir sus correspondientes tests unitarios/widget tests.*
3. **Formateo de Código:**
   ```bash
   dart format --set-exit-if-changed .
   ```

### 5. Convención de Commits (Conventional Commits)
Redacta mensajes de commit descriptivos, claros y en imperativo:
- `feat(scan): add haptic feedback upon barcode detection`
- `fix(metabolic): correct Mifflin-St Jeor sedentary activity factor calculation`
- `refactor(database): optimize meal query indexing by date`
- `docs(readme): update ios build configuration notes`

### 6. Creación del Pull Request (PR)
- Envía tu Pull Request apuntando a la rama `main` del repositorio original.
- **Es obligatorio completar cada sección de la plantilla de PR (`.github/pull_request_template.md`)**, incluyendo el checklist de verificación.
- Enlaza el Issue aprobado previamente (`Closes #123` o `Fixes #123`).

### 7. Proceso de Revisión y Aprobación
- Ningún PR podrá ser fusionado sin la aprobación formal del **Ing. Jorge Luis Fernández**.
- Si el revisor solicita cambios, aplícalos en la misma rama y actualiza el PR con comentarios claros.

---

## 🏛️ Directrices de Arquitectura y Estilo de Código

NutriLens AI sigue una arquitectura modular y desacoplada para garantizar rendimiento constante a 60/120 FPS y resiliencia offline.

### 1. Clean Architecture / Feature-First
- **`lib/core/`**: Infraestructura transversal, tema *Vitality Glassmorphism*, inyección de dependencias (`di/`), utilidades criptográficas y seguridad (`ApiKeyVault`).
- **`lib/data/`**: Modelos inmutables, data sources SQLite nativas (`sqflite`), migraciones de base de datos y repositorios de datos.
- **`lib/services/`**: Clientes de servicios externos (Gemini AI multimodal, generación PDF). Toda llamada externa debe contar con fallback offline resiliente.
- **`lib/presentation/`**: Pantallas (`screens/`) y componentes reutilizables (`widgets/`).
  - La lógica de negocio no debe residir directamente en los widgets de presentación.
  - Utiliza `CustomPainter` para visualizaciones complejas vectoriales (anillos metabólicos, gráficos semanales).

### 2. Sistema de Diseño: Vitality Glassmorphism
- **Estética Visual:** Superficies translúcidas con desenfoque gaussiano (*BackdropFilter*), bordes bioluminiscentes con gradientes esmeralda (`#10B981`) y ámbar (`#F59E0B`).
- **Mobile-First Exclusivo:** Toda interfaz debe ser diseñada para pantallas táctiles de teléfonos (Android e iOS), respetando `SafeArea`, muescas (*notches*), teclados virtuales y ergonomía a una mano.
- **Tipografía:** Utilizar exclusivamente la familia tipográfica oficial **Plus Jakarta Sans** a través de `google_fonts`.

### 3. Buenas Prácticas de Código Dart
- Declara constructores `const` siempre que sea posible.
- Evita el uso de `dynamic` y tipos débiles; utiliza tipado estricto.
- Asegura el cierre adecuado de controladores (`dispose()` en `TextEditingController`, `AnimationController`, `StreamSubscription`).
- Nunca expongas claves o secretos directamente en el código fuente. Utiliza `--dart-define` y `ApiKeyVault`.

---

## ⚖️ Licencia y Propiedad Intelectual

NutriLens AI está protegido bajo una **Licencia de Uso Libre y Gratuito No Comercial**:
- Al contribuir con código, documentación o recursos al proyecto, aceptas que tus contribuciones se incorporarán bajo los mismos términos de licencia no comercial.
- Queda prohibida la inclusión de dependencias, librerías o código de terceros con licencias restrictivas o incompatibles con el uso libre no comercial.

---

¡Gracias por formar parte de la construcción de la nutrición inteligente bioadaptativa en **NutriLens AI**! 🚀
