# 03 · Plan por etapas

Cada etapa termina con: código revisado, **pruebas automáticas pasando**, una versión
instalable (APK) y una explicación de qué hace cada parte.

Cambio sugerido al orden que propusiste: **la nube va antes que la IA**, porque la IA
necesita fotos etiquetadas de varios teléfonos para entrenarse bien. Igual, el modelo de
datos está preparado para sincronizar desde el día 1, así que ningún orden obliga a
rehacer nada.

| Etapa | Contenido | Resultado |
|---|---|---|
| **0 · Fundaciones** | Proyecto Flutter, estructura de carpetas, análisis de código, pruebas, compilación automática en GitHub Actions (APK de prueba). | ✅ Hecha. |
| **1 · MVP sin conexión** | Ver detalle abajo. | ✅ Primera versión lista para probar. |
| **2 · Mediciones y datos** | Mediciones definidas por el usuario (planilla editable), parámetros por variedad, exportar a Excel, importar temporadas anteriores desde CSV, copia de seguridad local completa. | Datos completos y portables. |
| **3 · Informes** | Línea de tiempo con curva fenológica, informes PDF (semanal, período, ficha por variedad, matriz comparativa), compartir por WhatsApp/correo. Luego comparación de tratamientos (ANOVA, LSD). | Informes para entregar. |
| **4 · Nube y sincronización** | Usuarios (Google + correo), Supabase, sincronización entre teléfonos, cola de subida de fotos (solo Wi-Fi opcional), roles por organización. | Varios teléfonos trabajando juntos. |
| **5 · Web** | Misma app en el navegador: consulta, edición en oficina, informes. | Acceso desde computador. |
| **6 · IA en el teléfono** | Sugerencia top-3 del estadio desde la foto de detalle, reglas agronómicas (no retroceder, ritmo semanal), registro de aceptado/corregido, modelo descargable por cultivo. | IA que ayuda en terreno. |
| **7 · Cuenta maestra** | Consentimiento por usuario, vista de entrenamiento, exportación del conjunto de datos, entrenamiento en Python y publicación de nuevos modelos. | IA que mejora con los datos de todos. |
| **8 · Extras** | Recordatorio semanal, mapas sin conexión, juego de entrenamiento de IA, segundo cultivo de prueba, iPhone en tiendas. | |

## Etapa 1 · MVP sin conexión (detalle)

Estado: implementada, con pruebas automáticas. Pendiente de prueba en terreno.

1. **Cultivos y escala:** carga del frambueso desde `app/assets/crops/rubus-idaeus.json` (escala BBCH
   con textos redactados por nosotros), visor de escala por macroestadio con colores.
2. **Variedades:** crear, editar, archivar.
3. **Proyectos:** crear ensayo de variedades, ensayo de tratamientos × repeticiones o
   predio; vista lista/cuadrícula.
4. **Unidades:** crear unidades del proyecto (variedad, tratamiento + repetición o
   sector + equipo de riego).
5. **Temporada y semanas:** semana 1 configurable, navegación entre semanas, «ir a la
   semana actual», marcar semana no muestreada, barra de avance.
6. **Registro:** estado fenológico, fotos general/detalle/extra desde cámara o galería,
   notas, GPS opcional; regla de completitud.
7. **Pruebas:** cálculo de semanas, completitud, nombres de fotos, orden de estadios,
   repositorios con base en memoria y pruebas de las pantallas principales.

**Fuera del MVP:** informes, IA, nube, web, mapas, recordatorios, celebración animada al
completar la semana (hoy es un mensaje con ícono).

## Etapa 2 · Mediciones y datos (detalle)

| Avance | Contenido | Estado |
|---|---|---|
| 2.1 | Copia de seguridad completa (datos + fotos) y restauración; rutas de fotos relativas (esquema v2) | ✅ Hecho |
| 2.1b | Configuración central (variedades, escala, proyectos, copia); ensayos de tratamientos con diseño (tratamientos × repeticiones, testigo T0) y descripción por tratamiento (esquema v3); botones de foto compactos | ✅ Hecho |
| 2.1c | Diseño moderno (Material 3): tema propio, inicio con avance semanal, semana con anillo de avance, tarjetas agrupadas; modo oscuro | ✅ Hecho |
| 2.2 | Definir mediciones (número, entero, texto, opción, imagen) por cultivo o proyecto | Pendiente |
| 2.3 | Mediciones en el registro y planilla semanal editable; borrar medición o semana | Pendiente |
| 2.4 | Parámetros por variedad y temporada | Pendiente |
| 2.5 | Exportar la temporada a Excel (.xlsx) | Pendiente |
| 2.6 | Importar temporadas anteriores desde CSV/ZIP con vista previa | Pendiente |

## Etapa 3 · Informes (adelantada)

| Avance | Contenido | Estado |
|---|---|---|
| 3.1 | Informe semanal PDF (avance por unidad + fotos general y detalle) y matriz de la temporada; vista previa, compartir e imprimir; hoja Carta | ✅ Hecho |
| 3.2 | Ficha por variedad con curva fenológica | Pendiente |
| 3.3 | Mediciones en los informes (cuando exista el avance 2.2) y comparación de tratamientos | Pendiente |
