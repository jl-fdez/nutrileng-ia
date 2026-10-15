## 🥑 Resumen del Cambio

<!-- Describe de forma concisa qué problema resuelve este Pull Request o qué funcionalidad introduce. -->

## 📌 Issue o Solicitud Relacionada

Closes #<!-- Número del Issue aprobado por el Ing. Jorge Luis Fernández, ej. #42 -->

---

## 🏷️ Tipo de Cambio

Marca con una `x` las casillas que apliquen:

- [ ] `feat`: Nueva funcionalidad o mejora en algoritmos bioadaptativos / IA.
- [ ] `fix`: Corrección de errores o anomalías en Android / iOS.
- [ ] `refactor`: Reestructuración de código sin alterar el comportamiento.
- [ ] `chore`: Tareas de mantenimiento, dependencias o configuración de tooling.
- [ ] `docs`: Modificación de documentación técnica o guías.

---

## 📱 Plataformas Probadas

- [ ] Android (Dispositivo físico / Emulador) — Versión: `______`
- [ ] iOS (Dispositivo físico / Simulador) — Versión: `______`

---

## 📸 Capturas de Pantalla / Evidencia Visual (Si aplica)

<!-- Si el cambio involucra modificaciones en la interfaz Vitality Glassmorphism, adjunta capturas de pantalla o un GIF/video demostrativo antes y después del cambio. -->

| Antes | Después |
|---|---|
| _(Opcional)_ | _(Captura o video)_ |

---

## ✅ Checklist Obligatorio de Verificación

Marca con una `x` cada elemento para confirmar que tu contribución cumple con las políticas inmutables de calidad y gobernanza de NutriLens AI:

- [ ] **Protección de Rama:** Confirmo que este cambio NO es un commit directo a la rama `main` y proviene de una rama estandarizada (`feat/*`, `fix/*`, `chore/*`).
- [ ] **Análisis Estático (0 Issues):** He ejecutado localmente `flutter analyze` y se completa sin errores, warnings ni violaciones de linting.
- [ ] **Pruebas Automatizadas (100% OK):** He ejecutado localmente `flutter test` y todas las pruebas unitarias y de widgets pasan exitosamente.
- [ ] **Arquitectura y Diseño:** El código respeta la arquitectura Clean Architecture / Feature-First (`core/`, `data/`, `services/`, `presentation/`) y el sistema de diseño visual **Vitality Glassmorphism**.
- [ ] **Resiliencia Offline:** Cualquier integración con servicios externos (IA/PDF) contempla su respectivo fallback offline para garantizar que la app nunca falle.
- [ ] **Licencia No Comercial:** Confirmo que este código respeta los términos de la Licencia Gratuita de Uso No Comercial del proyecto.
- [ ] **Aprobación de Gobernanza:** Reconozco que este Pull Request **requiere obligatoriamente la revisión y aprobación formal del Ing. Jorge Luis Fernández** antes de poder ser fusionado en `main`.
