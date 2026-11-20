# FramBitácora · contexto para Claude

Este archivo resume el proyecto y las decisiones tomadas, para continuar el trabajo en
un chat nuevo sin perder contexto. Leerlo completo antes de empezar.

## Cómo trabajar con el dueño

- Responder **siempre en español**, claro y sin jerga innecesaria.
- Avanzar **etapa por etapa**, con pruebas automáticas y explicando qué hace cada parte.
- Etapa 2: trabajar en la rama `claude/frambita-etapa-2-plan-4v5wwj` de
  `DJuaqo-Rothmund/app-fenolog-a-` (pedido del dueño); commit y push al terminar cada
  avance validado. No crear pull requests salvo que lo pida.
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
- **Etapa 2, avance 2.1 hecho:** copia de seguridad completa (`.zip`) y restauración
  (Configuración → Copia de seguridad), esquema v2 con rutas de fotos relativas.
- **Avance 2.1b hecho:** pantalla **Configuración** (engranaje) con variedades, escala,
  proyectos y copia; configuración por proyecto; ensayo de variedades con «Agregar
  variedades»; ensayo de tratamientos con diseño (n.º tratamientos, repeticiones, testigo
  T0) editable y descripción por tratamiento (esquema v3); botones de foto pequeños a la
  derecha de cada cajita. 59 pruebas pasan. Detalle en `docs/03-plan-etapas.md`.
- **Diseño moderno (Material 3):** tema central en `app/lib/app.dart` (`buildTheme`):
  tarjetas redondeadas sin bordes, campos rellenos, botones de 52 px, avisos flotantes,
  transiciones suaves y modo oscuro. Inicio con avance de la semana por proyecto; semana
  con encabezado y anillo de avance; registro y Configuración en tarjetas agrupadas
  (`IconBadge`, `SettingsGroup`, `SectionHeader` en `features/common.dart`).
- **Logo definitivo (elegido por el dueño, 15-nov-2026):** frambuesa con drupéolas que se
  convierten en circuitos y hojas verdes; vector en `app/assets/brand/symbol.svg`
  (trazado de `assets/brand/source/logo_original.jpg`). Ícono del teléfono: fondo crema +
  símbolo.
- **Íconos propios** (SVG originales): `app/assets/brand/` y `app/assets/icons/`,
  widgets `AppIcon`, `AppLogo`, `EmptyIllustration` en `features/app_icons.dart`
  (paquete `flutter_svg`, MIT). Ícono del teléfono adaptable + monocromo y pantalla de
  arranque crema con el logo. Regenerar con `bash app/tool/generate_launcher_icons.sh`.

- **Informes PDF (etapa 3.1, adelantada a pedido del dueño):** botón «Informes» en cada
  proyecto → informe semanal (Carta vertical; avance fenológico semana anterior → esta
  semana, fotos general + detalle por unidad) y matriz de la temporada (Carta horizontal,
  unidades × semanas con colores). Vista previa con zoom, compartir e imprimir (paquetes
  `pdf` y `printing`). Pensado para la jefa del dueño: sencillo, solo temporada e
  información general del ensayo. Pie de página: solo «Página N de M».
- **Avance de la temporada** (botón en cada proyecto y en Informes → «Revisar la
  temporada»): grilla unidades × semanas en la app, alertas (retrocede, sin foto, sin
  estado) y toque en una celda para corregir ese registro antes del informe. «Quitar
  estado» en el registro.
- **Guía de fotos** en la app (botón «?» en cada cajita de fotos y Configuración → Ayuda):
  qué es y cómo tomar la foto general (canopia), la de detalle (por macroestadio) y las
  adicionales; ilustrada (escenas, «Bien / Evitar» y un dibujo por etapa en
  `app/assets/guide/`, generados con `tool/guide_svgs.py`; sin texto dentro de los SVG).
- **Tema elegible** (Configuración → Apariencia): Claro, Oscuro o según el teléfono,
  guardado con `shared_preferences`.
- **Google Drive** (Configuración → Google Drive): botón «Continuar con Google» con el
  diseño de Google, sincronización de una vía de fotos por proyecto/temporada/semana y
  copia de seguridad en `FramBitácora/Respaldos`; permiso `drive.file`. Requiere el
  registro en Google Cloud (pasos y SHA-1 en `docs/05-desarrollo.md`). 87 pruebas pasan.

## Pendientes y preguntas abiertas

1. **Llave de firma del APK: resuelta.** Secretos `ANDROID_KEYSTORE_*` cargados en GitHub
   el 15-nov-2026; desde `frambitacora-apk-15` los APK salen firmados con la llave propia y
   se instalan encima de la versión anterior. La llave la guarda el dueño (nunca en el
   repositorio). Si la compilación muestra «APK sin llave propia», faltan los secretos.
2. **Historial de `main`**: el dueño pidió que no queden rastros de documentos de
   planificación antiguos; reescribir el historial en un solo commit requiere su
   **confirmación explícita** (es irreversible y el sistema de permisos lo bloquea).
3. Confirmar PowerSync vs. motor de sincronización propio antes de la etapa 4.
5. **Registro de Google Cloud para Drive**: el dueño debe crear el ID de cliente OAuth
   Android con el paquete y la SHA-1 de `docs/05-desarrollo.md`; sin eso el botón de
   Google muestra un aviso.
6. **Rama paralela `claude/funny-hypatia-g54ifr`** (30-oct, otra conversación): tiene
   etapas 2–5 hechas de otra forma (mediciones, Excel/CSV, Drive, servidor propio, web) y
   firma con una llave de pruebas distinta. No está unida a esta rama; decidir con el
   dueño qué rescatar de ahí (p. ej. mediciones, Excel/CSV).
4. Preguntas abiertas de la etapa 2 (sin respuesta aún): qué mediciones usa; un valor o
   varias muestras por unidad y semana; qué es la medición «imagen»; campos y unidades de
   los parámetros por variedad (¿por variedad o por unidad?); formato de los datos
   anteriores a importar (pedir archivo de ejemplo); alcance de «borrar semana»; copia
   automática además de la manual.

## Etapa en curso: 2 · Mediciones y datos

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
- `photos.local_path` es **relativa** a la carpeta de documentos; usar
  `PhotoStore.file(...)`. `photoStoreProvider` y `tempDirProvider` se configuran en
  `main.dart` y deben reemplazarse en las pruebas de pantallas.
- Trabajo pesado de archivos en `Isolate.run` desde funciones de nivel superior (una
  función anónima dentro de un método arrastra la base abierta y falla).
- Esquema actual: versión 3 (tabla de migraciones en `docs/05-desarrollo.md`). Las
  migraciones usan SQL directo y toleran columnas ya existentes.
- Diálogos con campos de texto: el diálogo debe ser un `StatefulWidget` dueño de sus
  `TextEditingController` (liberarlos tras `showDialog` rompe la animación de cierre).
- Pruebas de pantallas: usar `phoneScreen(tester)` (pantalla de teléfono 411 × 891) y
  `tapVisible` para tocar elementos que pueden quedar en el borde o bajo un aviso.
- PDF: cada bloque que no deba partirse entre páginas va dentro de un `pw.Stack`
  (las `Column` sí se parten). Llamar `initializeDateFormatting('es')` al inicio de cada
  función que arma un PDF (corre en otro isolate).
- No formatear `lib/data/database.g.dart` con `dart format lib` (restaurar con
  `git checkout` si pasa); formatear con la lista de archivos que excluye `*.g.dart`.
- Antes de subir: `flutter analyze`, `flutter test` y formato, todo en verde.
