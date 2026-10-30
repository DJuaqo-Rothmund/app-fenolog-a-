# 05 · Desarrollo

## Requisitos

- Flutter 3.47 (estable) y Java 17.
- Android Studio o el SDK de Android para compilar e instalar en un teléfono.

## Comandos (desde la carpeta `app/`)

```bash
flutter pub get                       # descargar dependencias
dart run build_runner build           # regenerar código de la base de datos (tras cambiar tablas)
flutter analyze                       # revisar el código
flutter test                          # pruebas automáticas
flutter run                           # ejecutar en un teléfono conectado
flutter build apk --release           # generar el APK
```

GitHub Actions ejecuta lo mismo en cada cambio a `main` (`.github/workflows/android.yml`)
y publica el APK como *artifact*.

## Qué hace cada parte

| Archivo | Para qué sirve |
|---|---|
| `lib/main.dart` | Arranque: abre la base local y carga los cultivos incluidos. |
| `lib/app.dart` | Tema visual (verde hoja y rojo fruto) e idioma español. |
| `lib/domain/season_weeks.dart` | Cálculo de semanas de temporada, semana ISO y semana 1 por defecto. |
| `lib/domain/photo_naming.dart` | Nombre uniforme de las fotos. |
| `lib/domain/crop_definition.dart` | Lee y valida el JSON de un cultivo. |
| `lib/domain/completeness.dart` | Regla de registro completo (estado + al menos una foto) y avance semanal. |
| `lib/domain/project_kind.dart` | Tipos de proyecto y etiqueta automática de unidades. |
| `lib/data/database.dart` | Tablas de la base local. Todas tienen UUID, fechas y borrado lógico para sincronizar después. |
| `lib/data/crop_importer.dart` | Carga los cultivos JSON en la base; actualiza la escala si sube la versión. |
| `lib/data/*_repository.dart` | Lectura y escritura de datos (catálogo, proyectos, registros y fotos). |
| `lib/data/photo_store.dart` | Copia las fotos a la carpeta de la app con su nombre uniforme. |
| `lib/domain/measurement.dart` | Tipos de medición y validación de valores (coma o punto decimal, mínimo, máximo, opciones). |
| `lib/domain/csv_import.dart` | Lectura de planillas CSV de temporadas anteriores. |
| `lib/domain/stats.dart` | ANOVA (una vía o bloques completos al azar), LSD de Fisher y letras de agrupación. |
| `lib/data/measurement_repository.dart` | Mediciones definidas por proyecto y sus valores. |
| `lib/data/season_data.dart` | Carga todos los datos de una temporada (para exportar e informar). |
| `lib/data/season_analysis.dart` | Curvas fenológicas, semana en que se alcanza un estadio y muestras para comparar. |
| `lib/data/season_tables.dart` / `excel_export.dart` | Tablas de la temporada, Excel y CSV. |
| `lib/data/csv_importer.dart` | Carga un CSV en una temporada. |
| `lib/data/backup.dart` | Respaldo completo (.zip) y restauración. |
| `lib/data/drive_client.dart` / `drive_sync.dart` | Subida a Google Drive personal. |
| `lib/data/pdf_reports.dart` | Informes PDF: semanal, temporada, ficha por variedad y comparación. |
| `lib/features/...` | Pantallas. |

## Agregar un cultivo

1. Copiar `app/assets/crops/rubus-idaeus.json` con otro nombre y editar código, nombre,
   inicio de temporada, macroestadios y estadios (código, nombre, descripción y color).
2. Agregar la ruta en `bundledCropAssets` (`lib/data/crop_importer.dart`).
3. Para corregir una escala ya instalada, subir su `version`: la app actualiza los textos y
   colores sin borrar estadios usados.

## Llave de firma del APK

Sin llave propia, cada compilación de GitHub se firma con una llave de depuración distinta
y Android obliga a desinstalar (y perder los datos) antes de instalar la versión nueva.
Para evitarlo, crear una vez una llave y guardarla como secretos del repositorio:

```bash
keytool -genkey -v -keystore frambitacora.jks -keyalg RSA -keysize 2048 -validity 10000 -alias frambitacora
```

```bash
base64 -w0 frambitacora.jks
```

En GitHub → Settings → Secrets and variables → Actions, crear:
`ANDROID_KEYSTORE_BASE64` (el texto del segundo comando), `ANDROID_KEYSTORE_PASSWORD`,
`ANDROID_KEY_ALIAS` (`frambitacora`) y `ANDROID_KEY_PASSWORD`. Guardar el archivo `.jks` en
un lugar seguro y **nunca** subirlo al repositorio.

## Google Drive personal

La app sube archivos al Drive de la persona con el permiso `drive.file` (solo ve lo que
ella misma creó). No requiere servidor propio, pero Google exige registrar la app **una
vez**:

1. En [Google Cloud Console](https://console.cloud.google.com/) crear un proyecto
   (p. ej. «FramBitácora») y habilitar **Google Drive API**.
2. **Pantalla de consentimiento OAuth**: tipo «Externo», nombre FramBitácora, el correo
   de contacto, y agregar el permiso `.../auth/drive.file`. Mientras esté en modo
   «Prueba», agregar como **usuarios de prueba** los correos del equipo (hasta 100).
3. **Credenciales → Crear ID de cliente OAuth → Android**: paquete
   `cl.rothmund.frambitacora` y la huella **SHA-1** de la llave de firma:

   ```bash
   keytool -list -v -keystore frambitacora.jks -alias frambitacora
   ```

   Si aún no hay llave propia, el APK de GitHub se firma con una llave de depuración que
   cambia en cada compilación y Drive no funcionará; por eso conviene configurar primero
   la llave de firma (sección anterior).

No hay que copiar ningún dato en el código: Google reconoce la app por el paquete y la
huella. Sin este registro, «Subir a mi Google Drive» muestra un aviso y se puede usar
«Compartir» → Drive, que funciona siempre.

Estructura en Drive:

```
FramBitácora/
  <Proyecto>/<Temporada>/<Proyecto>_<Temporada>.xlsx
  <Proyecto>/<Temporada>/fotos/Semana 01/20260908_FRB_HERITAGE_G1.jpg
  Respaldos/FramBitacora_respaldo_20261030_0905.zip
```

## Formato CSV para importar temporadas anteriores

Separador `;` (también acepta `,` o tabulador). Primera fila con encabezados:

| Columna | Obligatoria | Ejemplo |
|---|---|---|
| `Semana` o `Fecha` | Sí (una de las dos) | `3` o `21-09-2025` |
| `Unidad` | Sí | `Heritage`, `T1 R2` (si no existe, se crea) |
| `Código estadio` (o `Estadio`, `BBCH`) | No | `61` o `Inicio de floración` |
| `Notas` | No | |
| Nombre de una medición semanal | No | `Largo de brote (cm)` → `12,5` |

Es el mismo formato del CSV que exporta la app.
