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
| `lib/data/photo_store.dart` | Copia las fotos a la carpeta de la app con su nombre uniforme. La base guarda la ruta **relativa** (`fotos/<temporada>/<archivo>`). |
| `lib/data/backup_service.dart` | Copia de seguridad completa (`.zip` con `manifest.json`, la base y `fotos/`) y restauración. |
| `lib/features/backup/` | Pantalla «Copia de seguridad» (desde Configuración). |
| `lib/features/settings/` | **Configuración** (engranaje en la pantalla de inicio): variedades, escala, proyectos, copia de seguridad; y configuración de cada proyecto (nombre, temporada, diseño, tratamientos, unidades, archivo). |
| `lib/reports/` | Informes PDF: modelos de datos (`report_models.dart`), dibujo del PDF en hoja Carta (`pdf_reports.dart`, se arma en otro isolate) y reducción de fotos (`photo_shrink.dart`). |
| `lib/data/report_repository.dart` | Reúne los datos del informe semanal y de la matriz desde la base. |
| `lib/features/reports/reports_screen.dart` | Menú «Informes» del proyecto y vista previa (zoom, compartir, imprimir). |
| `lib/features/projects/treatment_design.dart` | Diseño del ensayo de tratamientos: n.º de tratamientos, repeticiones y testigo T0. |
| `lib/features/...` | Pantallas. |

## Copia de seguridad

Configuración (engranaje) → **Copia de seguridad**.

- **Crear copia y compartir:** arma un `.zip` con todos los datos y fotos y abre el menú
  «Compartir» de Android para guardarlo en Drive, enviarlo por correo, etc. Con ≈ 500 fotos
  pesa unos 150-300 MB. En el teléfono solo queda la última copia (en la caché).
- **Restaurar:** elegir un `.zip`; la app muestra fecha y cantidades y pide confirmar.
  Reemplaza **todo** lo del teléfono. Una copia de una versión anterior de la app se
  actualiza sola al restaurarla; una de una versión más nueva se rechaza.
- Contenido del `.zip`: `manifest.json` (app, formato, versión del esquema, fecha,
  cantidades), `frambitacora.sqlite` (copia de la base hecha con `VACUUM INTO`) y `fotos/`.
- Seguridad: solo se extraen esos nombres; se ignoran rutas absolutas o con `..`. Si la
  copia de tablas falla, la transacción se deshace y los datos actuales quedan intactos.

## Migraciones de la base

| Versión | Cambio |
|---|---|
| 1 | Esquema inicial (etapa 1). |
| 2 | Las fotos guardan su ruta relativa en vez de la ruta completa del teléfono. |
| 3 | Tabla `treatments` (código, descripción, testigo, orden) y `projects.replicates`. Los ensayos de tratamientos existentes reciben sus tratamientos desde sus unidades. |

Las migraciones están en `AppDatabase.migration` y usan SQL directo para no depender del
esquema más nuevo.

## Logo e íconos

Dibujos originales, en vectores (SVG):

- `app/assets/brand/symbol.svg`: **logo elegido por el dueño** (frambuesa cuyas drupéolas
  se convierten en circuitos, con hojas verdes), trazado a vectores desde
  `app/assets/brand/source/logo_original.jpg` con `python3 tool/trace_logo.py`
  (requiere `pip install potracer`).
- `app/assets/brand/`: a partir del símbolo, `python3 tool/brand_svgs.py` arma el logo con
  recuadro crema, el ícono adaptable de Android (fondo crema, símbolo y versión monocroma)
  y la ilustración de pantalla vacía.
- `app/assets/icons/`: íconos de línea de 24 × 24 (variedad, tratamiento, predio, cámara,
  galería, escala, copia, notas, GPS, configuración, semana). En la app se usan con
  `AppIcon(AppIcons.camera)`; toman el tamaño y color del entorno.
- Íconos del teléfono (`android/app/src/main/res/`): `bash tool/generate_launcher_icons.sh`
  los vuelve a generar desde los SVG (requiere Node con Playwright).

## Informes PDF

En cada proyecto, botón **Informes** (arriba a la derecha):

- **Informe semanal** (Carta vertical): encabezado con logo, ensayo, temporada y semana;
  información general y avance; tabla «Avance fenológico» (semana anterior → esta semana,
  fotos, notas); un bloque por unidad con sus fotos general y de detalle (1 o 2 por tipo,
  o sin fotos). Cada bloque queda entero en una página.
- **Matriz de la temporada** (Carta horizontal): unidades × semanas (desde la 1 hasta la
  actual o la última con datos), cada celda con el color y código del estadio; en ensayos
  de tratamientos se agrupa por tratamiento con su descripción; «NM» = no muestreada;
  leyenda de estadios. Más de 22 semanas se reparten en varias tablas.

Las fotos se reducen a 900 px y JPEG calidad 72 (un informe semanal con fotos pesa pocos
MB). Fuente Roboto incluida (`assets/fonts/`) para tildes y ñ. La vista previa usa el
visor del paquete `printing`; en las pruebas se reemplaza con `pdfViewerProvider`.

## Configuración de proyectos

- **Ensayo de variedades:** «Agregar variedades» muestra el catálogo con casillas (y botón
  «Nueva»); crea una unidad por variedad y no repite las que ya están.
- **Ensayo de tratamientos:** al crearlo se elige n.º de tratamientos, repeticiones y si
  tiene testigo (T0). Se crean los tratamientos `T0…Tn` y una unidad por tratamiento y
  repetición (`T1 R2`), en orden de campo (bloque por bloque). En Configuración se cambia
  el diseño (se agregan las unidades que faltan y se quitan las que sobran, conservando
  sus registros) y se escribe la descripción de cada tratamiento (producto, dosis…), que
  también aparece en la lista semanal.
- **Predio:** unidades una a una (equipo de riego + sector).

## Agregar un cultivo

1. Copiar `app/assets/crops/rubus-idaeus.json` con otro nombre y editar código, nombre,
   inicio de temporada, macroestadios y estadios (código, nombre, descripción y color).
2. Agregar la ruta en `bundledCropAssets` (`lib/data/crop_importer.dart`).
3. Para corregir una escala ya instalada, subir su `version`: la app actualiza los textos y
   colores sin borrar estadios usados.

## Llave de firma del APK

Para que cada versión nueva **se instale encima de la anterior** (sin desinstalar ni
perder datos), todas deben firmarse con la misma llave. Android solo actualiza una app si
la llave coincide.

1. Crear la llave una vez:

   ```bash
   keytool -genkeypair -v -keystore frambitacora.jks -storetype PKCS12 -keyalg RSA -keysize 2048 -validity 10000 -alias frambitacora
   ```

   ```bash
   base64 -w0 frambitacora.jks
   ```

2. En GitHub → Settings → Secrets and variables → Actions → *New repository secret*,
   crear `ANDROID_KEYSTORE_BASE64` (el texto del segundo comando),
   `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS` (`frambitacora`) y
   `ANDROID_KEY_PASSWORD`.
3. Guardar la llave (o el texto base64) en un lugar seguro y privado. **Nunca** subirla
   al repositorio: es público y cualquiera podría firmar versiones falsas.

Con los secretos cargados, GitHub Actions firma con esa llave; si faltan, la compilación
muestra el aviso «APK sin llave propia». El cambio de la llave de depuración a la llave
propia obliga a desinstalar **una sola vez**; desde ahí, las versiones se actualizan
encima. El número de versión (`versionCode`) sube solo con cada compilación.
