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
