# 00 · Tecnología

## Recomendación

Mantengo casi toda tu propuesta, con **tres ajustes**:

| Pieza | Tu propuesta | Recomendación | Motivo |
|---|---|---|---|
| App móvil | Flutter (Dart) | **Flutter (Dart)** ✔ | Un código para Android e iPhone, buen rendimiento en teléfonos de gama baja y buena cámara. |
| Base local | (no definida) | **SQLite con Drift** | Base de datos real en el teléfono, con consultas tipadas, migraciones y pruebas. Es la base del modo sin conexión. |
| Sincronización | (no definida) | **PowerSync** sobre Supabase (o motor propio, ver abajo) | La sincronización sin conexión entre varios teléfonos es lo más difícil del proyecto; conviene no inventarla. |
| Nube | Supabase | **Supabase** ✔ | Postgres + usuarios + almacenamiento de fotos + reglas de acceso por fila (RLS). Se puede alojar en servidor propio en el futuro. |
| Web | Flutter web, Next.js o SvelteKit | **Flutter web** (el mismo código) | Una sola base de código, mismas pantallas y reglas. Next.js solo si más adelante quieres un portal público o de marketing. |
| IA en el teléfono | YOLO → TFLite/ONNX | **Clasificador ligero propio (MobileNetV3 / EfficientNet-Lite) → LiteRT (TFLite)**; detección con cajas más adelante | Ver «IA: clasificador primero, detección después». |

### Por qué Flutter (y no React Native / Kotlin Multiplatform)

- **Pros:** un código para Android, iPhone y web; interfaz idéntica en todos; acceso a
  cámara, GPS, archivos y notificaciones; buen soporte de SQLite y TFLite.
- **Contras:** Flutter web genera páginas más pesadas que una web clásica (carga inicial
  de 2-4 MB); para iPhone necesitas un Mac (o un servicio de compilación en la nube como
  Codemagic) y una cuenta de Apple Developer (USD 99/año).

### Sincronización: dos caminos

| | **A · PowerSync** (recomendado) | **B · Motor propio** (Drift + Supabase) |
|---|---|---|
| Qué es | Servicio que replica Postgres (Supabase) a SQLite en cada teléfono y sube los cambios locales en cola. | Escribimos nosotros la cola de cambios, la descarga incremental y la resolución de conflictos. |
| Pros | Probado; tiene SDK oficial para Flutter (incluida web); maneja reconexiones, descarga parcial por usuario y orden de cambios. Tiene edición abierta que se puede alojar en servidor propio. | Sin dependencia de otro servicio ni costo extra; control total. |
| Contras | Un servicio más (plan gratuito limitado; los planes pagados tienen costo mensual). | Semanas de trabajo extra y riesgo de errores sutiles (datos perdidos o duplicados). |

En ambos casos el modelo de datos es el mismo (identificadores UUID creados en el
teléfono, marcas de tiempo, borrado lógico), así que se puede cambiar de A a B sin
rehacer la app.

### IA: clasificador primero, detección después

1. **Primero, un clasificador** (foto → estadio fenológico, top-3 con confianza) con
   arquitecturas ligeras de licencia permisiva: **MobileNetV3** o **EfficientNet-Lite**,
   entrenadas con PyTorch o Keras y exportadas a TFLite (LiteRT) para el teléfono y a
   ONNX para la web. Es lo que realmente se necesita para sugerir el estadio y funciona
   bien en teléfonos de gama media.
2. **Después, detección con cajas** (contar flores, frutos, brotes) con un detector de
   licencia permisiva, p. ej. **YOLOX** o **RT-DETR** (Apache-2.0). Las versiones YOLO de
   Ultralytics son AGPL-3.0, por eso no se usan dentro de la app.

El entrenamiento se hace en un computador o en la nube (Python), **fuera de la app**. La
app solo carga un archivo de modelo por cultivo y lo ejecuta en el teléfono.

## Resumen de la pila

```
Flutter (Dart) ─ Android / iPhone / web
 ├─ Riverpod            estado de la app
 ├─ go_router           navegación
 ├─ Drift (SQLite)      base local (fuente de verdad en el teléfono)
 ├─ PowerSync           sincronización con la nube
 ├─ camera / image      fotos y miniaturas
 ├─ LiteRT (TFLite)     IA en el teléfono (ONNX Runtime Web en la web)
 └─ pdf / excel         informes y exportación

Supabase
 ├─ Auth                usuarios (Google + correo)
 ├─ Postgres + RLS      datos y permisos por organización
 ├─ Storage             fotos e informes
 └─ Edge Functions      tareas de servidor (p. ej. reunir datos de entrenamiento)

Entrenamiento de IA (fuera de la app)
 └─ Python + PyTorch    entrenar → exportar TFLite/ONNX → publicar modelo por cultivo
```
