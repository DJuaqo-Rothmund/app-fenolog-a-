# FramBitácora · contexto para Claude

Este archivo resume el proyecto y las decisiones tomadas, para continuar el trabajo en
un chat nuevo sin perder contexto. Leerlo completo antes de empezar.

## Cómo trabajar con el dueño

- Responder **siempre en español**, claro y sin jerga innecesaria.
- Avanzar **etapa por etapa**, con pruebas automáticas y explicando qué hace cada parte.
- Trabajar en la rama `main` de `DJuaqo-Rothmund/app-fenolog-a-`; commit y push al
  terminar cada avance validado. No crear pull requests salvo que lo pida.
- Todo el código, textos, diseños e íconos son **originales**, escritos desde cero.
  No incorporar ni mencionar código o material de otras aplicaciones.
- No volver a discutir licencias: el proyecto es **MIT** (`LICENSE`).

## Qué es

App de **seguimiento fenológico de cultivos** para trabajo en terreno **sin conexión**.
Primer cultivo: frambueso (escala BBCH). Diseñada multi-cultivo: cada cultivo (escala,
estadios, colores) se define en un JSON en `app/assets/crops/`.

## Decisiones

| Tema | Decisión |
|---|---|
| Plataforma | Solo **Android** por ahora (Flutter; iPhone y web después) |
| Usuarios | El dueño y su equipo (una organización) |
| Volumen | ≈ 500 fotos por temporada |
| Base local | SQLite con **Drift**; todas las tablas con UUID, `created_at`, `updated_at`, `deleted_at` (listas para sincronizar) |
| Estado | **Riverpod 3** (providers en `app/lib/providers.dart`) |
| Nube (etapa 4) | Supabase + **PowerSync** recomendado (motor propio como alternativa; el dueño aún no confirma) |
| IA (etapa 6) | Clasificador ligero (MobileNetV3 / EfficientNet-Lite) → TFLite. No usar YOLO de Ultralytics (AGPL) |
| Fotos | `aaaammdd_<CULTIVO>_<UNIDAD>_<G|D|X><n>.jpg`, 2048 px, calidad 85 |
| Semana 1 | Lunes de la semana que contiene el 7-sep (configurable por temporada) |
| Registro completo | Estado fenológico + al menos una foto |

Documentación completa en `docs/` (tecnología, arquitectura, modelo de datos, plan,
decisiones, guía de desarrollo).

## Estado actual

- **Etapa 0 (fundaciones) y etapa 1 (MVP sin conexión): hechas.** 38 pruebas pasan,
  `flutter analyze` limpio, GitHub Actions compila el APK (artifact `frambitacora-apk-N`).
- Funciones del MVP: cultivos/escala con colores, variedades (crear, editar, archivar),
  proyectos (ensayo de variedades, de tratamientos × repeticiones o predio; lista o
  cuadrícula), temporadas, unidades, navegación por semanas, semana no muestreada, barra
  de avance, registro con estado, fotos (cámara/galería), notas y GPS.
- Pendiente de **prueba en terreno** por el dueño.

## Pendientes y preguntas abiertas

1. **Llave de firma del APK**: sin ella cada versión obliga a desinstalar (se pierden
   datos). Pasos en `docs/05-desarrollo.md` (secretos `ANDROID_KEYSTORE_BASE64`, etc.).
2. **Historial de `main`**: el dueño pidió que no queden rastros de documentos de
   planificación antiguos; reescribir el historial en un solo commit requiere su
   **confirmación explícita** (es irreversible y el sistema de permisos lo bloquea).
3. Confirmar PowerSync vs. motor de sincronización propio antes de la etapa 4.

## Próxima etapa: 2 · Mediciones y datos

- Mediciones definidas por el usuario (numéricas, texto, opción, imagen) por cultivo o
  proyecto; planilla editable por semana; borrar medición o semana.
- Parámetros por variedad y temporada (rendimiento, cañas, laterales, campos propios).
- Exportar la temporada a Excel (.xlsx); importar temporadas anteriores desde CSV/ZIP.
- Copia de seguridad local completa (datos + fotos) y restauración.
- Después: etapa 3 (informes PDF, línea de tiempo), 4 (nube), 5 (web), 6 (IA), 7 (cuenta
  maestra con consentimiento), 8 (extras). Ver `docs/03-plan-etapas.md`.

## Notas técnicas

- Flutter **3.47.9** estable, Dart 3.13, Java 17. Proyecto en `app/`.
- Tras cambiar tablas: `dart run build_runner build --delete-conflicting-outputs` y subir
  `database.g.dart` (CI verifica que esté al día). Aumentar `schemaVersion` y escribir la
  migración cuando cambie el esquema de una base ya instalada.
- Formato: `dart format` con ancho 120 (`analysis_options.yaml`); **no** formatear
  `*.g.dart` (CI los excluye).
- Pruebas de pantallas con Drift: las consultas corren fuera del reloj falso; usar
  `tester.runAsync` y la función `finish()` de `test/widget/app_flow_test.dart` para
  desmontar la app y cerrar la base sin timers pendientes.
- Las fechas se guardan como texto ISO (`build.yaml`), útil para sincronizar con Postgres.
- Antes de subir: `flutter analyze`, `flutter test` y formato, todo en verde.
