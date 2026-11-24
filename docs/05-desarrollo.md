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
- Pie de página (ambos informes): solo «Página N de M», centrado (pedido del dueño).
- **Matriz de la temporada** (Carta horizontal): unidades × semanas (desde la 1 hasta la
  actual o la última con datos), cada celda con el color y código del estadio; en ensayos
  de tratamientos se agrupa por tratamiento con su descripción; «NM» = no muestreada;
  leyenda de estadios. Más de 22 semanas se reparten en varias tablas.

Las fotos se reducen a 900 px y JPEG calidad 72 (un informe semanal con fotos pesa pocos
MB). Fuente Roboto incluida (`assets/fonts/`) para tildes y ñ. La vista previa usa el
visor del paquete `printing`; en las pruebas se reemplaza con `pdfViewerProvider`.

## Avance de la temporada (revisión antes del informe)

En cada proyecto, botón **Avance de la temporada** (también desde **Informes → Revisar la
temporada**): grilla unidades × semanas con el color y código de cada estado. Tocar una
celda abre ese registro para corregirlo; los cambios se ven al instante aquí y en los
informes. Alertas automáticas (`lib/domain/season_review.dart`):

- **Retrocede**: el estado es anterior (en la escala) al de la última semana registrada.
- **Sin foto**: tiene estado pero ninguna foto.
- **Sin estado**: tiene fotos pero no se eligió el estado.

Las semanas no muestreadas no generan alertas. En el registro, «Quitar estado» borra un
estado puesto por error.

## Apariencia (tema)

Configuración → **Apariencia**: Claro, Oscuro o Teléfono (sigue el ajuste del sistema;
es lo predeterminado). La elección se guarda con `shared_preferences`
(`themeModeProvider` en `providers.dart`; `preferencesProvider` se configura en
`main.dart` y en las pruebas queda vacío, así funciona sin guardar).

## Google Drive

Configuración → **Google Drive**: botón «Continuar con Google» (diseño del sistema de
Google), y luego «Sincronizar ahora». Nunca borra nada en Drive. En cada sincronización:

- Fotos: `FramBitácora/<proyecto>/<temporada>/Semana NN/<foto>.jpg`. Cada foto subida
  queda marcada (`photos.upload_status = 'drive'`) y no se repite; si ya existe en la
  carpeta (p. ej. tras reinstalar) solo se marca. Al cambiar de cuenta, todas vuelven a
  quedar pendientes.
- **Datos entre equipos** (teléfono y web, `lib/data/drive/data_sync.dart`): ver abajo.
- Fotos que agregó otro equipo: se buscan en Drive por nombre y se descargan.
- Copia de seguridad completa (opcional): `FramBitácora/Respaldos/*.zip`, con subida
  reanudable (no carga el archivo en memoria).

### Sincronización de datos (avance 4.1)

Google Drive es la «nube» (decisión del dueño, sin servidores). Cada equipo tiene un id
(`SyncState.deviceId`, guardado en `shared_preferences`) y su carpeta
`FramBitácora/datos/<equipo>/`, donde sube un JSON por sincronización con las filas que
cambiaron desde su última subida (`updated_at` en (subidoHasta, ahora]). Nombre del
archivo: `aaaammddThhmmssZ-uuuuuu.json` (UTC, microsegundos con 6 dígitos: ordenar por
nombre = ordenar por fecha).

1. **Leer**: los archivos nuevos de los otros equipos (el último leído de cada uno queda
   en `SyncState.seen`), en orden, cada uno en una transacción con
   `PRAGMA defer_foreign_keys`.
2. **Aplicar fila por fila**: si no existe, se inserta; si existe, **gana el
   `updated_at` más reciente**. Filas con el mismo contenido solo igualan su fecha (no
   vuelven a viajar). Columnas desconocidas se ignoran (versiones distintas de la app).
3. **Misma cosa creada en dos equipos** (`syncNaturalKeys`: catálogo del cultivo,
   registro unidad×semana, semana no muestreada): ambos se quedan con el **id menor**. El
   equipo con el id mayor cambia su id y el de todo lo que lo apunta (`syncReferences`);
   el otro anota un alias (`SyncState.aliases`) y reenvía su fila para que el primero se
   entere.
4. **Subir** lo cambiado aquí, sin reenviar lo recibido sin cambios.

Los borrados viajan como `deleted_at`. Las fotos subidas avanzan su `updated_at` al
marcarse `drive` (así el otro equipo sabe que puede bajarlas). Al restaurar una copia se
vuelve a subir todo (`SyncStateStore.afterRestore`); al cambiar de cuenta de Google se
empieza de cero (`reset`). Pruebas: `test/data/data_sync_test.dart` (dos equipos con el
mismo `FakeDrive` de `test/fake_drive.dart`).

Permiso: solo `drive.file` (la app ve únicamente lo que ella crea). Código:
`lib/data/drive/` (cliente HTTP de Drive v3 y sincronización), `lib/features/drive/`
(inicio de sesión con `google_sign_in` y pantalla). En pruebas se reemplazan
`googleAuthProvider` y `driveApiProvider`.

## Versión web (avance 5.1)

La misma app compilada para el navegador y publicada en GitHub Pages:
`https://djuaqo-rothmund.github.io/app-fenolog-a-/`. La publica el flujo
`.github/workflows/web.yml` en cada subida a la rama (rama `gh-pages`; en el repositorio,
*Settings → Pages → Deploy from a branch → gh-pages / (root)*, una sola vez).

Diferencias con el teléfono (`kIsWeb`):

- **Base**: SQLite en WebAssembly guardado en el navegador (`web/sqlite3.wasm` y
  `web/drift_worker.js`, que agrega la compilación; no se suben al repositorio).
- **Fotos**: no hay carpeta; se leen desde Drive por su nombre (`DrivePhotoSource`,
  `PhotoImage`). Las fotos que se agregan en la web se suben **al instante** a la carpeta
  de su semana (`DriveSync.uploadPhotoBytes`); el teléfono las baja al sincronizar.
- **Sincronizar** solo intercambia datos (no hay respaldo `.zip` ni fotos locales).
  Sin Drive conectado, el inicio ofrece «Conectar Google Drive».
- **Informes**: mismos PDF, armados en el mismo hilo (el navegador no tiene isolates).
- **Inicio de sesión**: ID de cliente web en `google_auth.dart` (`webClientId`).
- La restauración de copias abre la base del `.zip` con `lib/platform/file_database.dart`
  (importación condicional: nativa en el teléfono, no disponible en la web).

Probar en local: `flutter build web --no-web-resources-cdn` tras copiar los dos archivos
del motor (ver el flujo) y servir `build/web` con cualquier servidor estático.

### Registro en Google Cloud (una sola vez, lo hace el dueño)

Sin este registro, «Continuar con Google» muestra «Esta versión de la app todavía no
está registrada en Google Cloud».

1. console.cloud.google.com → crear (o elegir) un proyecto.
2. *APIs y servicios → Biblioteca* → habilitar **Google Drive API**.
3. *Pantalla de consentimiento de OAuth* → tipo **Externo**, nombre «FramBitácora»,
   correo de soporte; en *Usuarios de prueba* agregar los correos del equipo (mientras la
   app esté «En pruebas» solo ellos pueden conectarse).
4. *Credenciales → Crear credenciales → ID de cliente de OAuth* → tipo **Android**:
   - Nombre del paquete: `cl.rothmund.frambitacora`
   - Huella SHA-1 de la llave de firma (la de los secretos `ANDROID_KEYSTORE_*`):
     `A0:94:AE:C8:0A:2B:32:82:0C:7E:34:63:3D:B2:6F:B7:7F:BC:B8:F1`
5. No hay que copiar nada a la app: Google la reconoce por el paquete y la huella.
6. Para la versión web (etapa 5): otro *ID de cliente de OAuth* tipo **Aplicación web**
   con el origen autorizado `https://djuaqo-rothmund.github.io`. Ambos clientes, en el
   mismo proyecto, comparten lo creado con `drive.file`.

## Guía de fotos

`lib/features/help/photo_guide_screen.dart`, con tres pestañas: **General** (canopia: a
2–3 m, de frente a la hilera, mismo punto cada semana, sol a la espalda, planta
representativa), **Detalle** (a 10–20 cm, enfocado, fondo limpio, estado de la mayoría y
qué órgano fotografiar en cada macroestadio de la escala) y **Adicionales** (plagas,
daños, referencias). Ilustrada con dibujos originales en `app/assets/guide/` (escenas de
cómo tomar cada foto, comparaciones «Bien / Evitar» y un dibujo por macroestadio),
generados con `python3 tool/guide_svgs.py`. Los SVG no llevan texto (el lector de SVG de
Flutter no lo dibuja): las medidas se escriben encima desde la app. Se abre con el «?» de cada cajita de fotos del registro (en la
pestaña que corresponde) y desde Configuración → Ayuda. Una prueba verifica que la lista
de etapas coincida con los macroestadios del JSON del frambueso.

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
