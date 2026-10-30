# 05 · Preguntas abiertas

## Respuestas (30-10-2026)

| # | Tema | Decisión |
|---|---|---|
| 1 | Nombre | **FramBitácora** |
| 2 | Plataformas | **Solo Android** por ahora |
| 3 | Usuarios | **Solo el dueño y su equipo** (una organización) |
| 5 | Volumen | **≈ 500 fotos por temporada** → cabe en planes gratuitos si las fotos se comprimen (≈ 300 KB c/u ≈ 150 MB) |
| 11 | Fotos etiquetadas | **Sí hay** fotos propias con su estadio para un primer entrenamiento |
| 12 | Sincronización | Pendiente: explicar PowerSync; si no convence, motor propio |
| 13-14 | Repositorio y licencia | **Queda público por ahora**; el código se entregará después al equipo de TI de la empresa. Licencia por definir (ver 04-licencia.md) |

## Preguntas originales

Respuestas necesarias antes de empezar la etapa 0/1. Entre paréntesis, lo que haré si no
hay respuesta.

## Producto

1. **Nombre de la app:** ¿tienes uno? (provisional: «Fenología»).
2. **Plataformas al inicio:** ¿solo Android en el MVP y iPhone después? ¿Tienes Mac o
   prefieres compilar iPhone en la nube? (Android primero).
3. **Usuarios:** ¿solo tú y tu equipo, o desde el inicio varias empresas separadas? ¿Qué
   roles necesitas (administrador, muestreador, solo lectura)? (Una organización; roles
   dueño / editor / lector).
4. **Idioma:** ¿solo español o también inglés? (Español, preparado para traducir).
5. **Volumen esperado por temporada:** número de proyectos, unidades por proyecto, fotos
   por registro y teléfonos. Sirve para estimar costos de nube. (≈ 5 proyectos × 30
   unidades × 30 semanas × 3 fotos).

## Campo

6. **Semana 1:** ¿por defecto la semana del 7 de septiembre para frambueso en todas las
   temporadas, editable? (Sí).
7. **Ensayos de tratamientos × repeticiones:** ¿entran en el MVP o pueden esperar a los
   informes con ANOVA? (Entran en el MVP como tipo de proyecto; el análisis va en la etapa 3).
8. **Mapa en el MVP:** ¿basta con el GPS del teléfono o necesitas marcar en mapa desde el
   comienzo? (Solo GPS en el MVP).
9. **Datos anteriores:** ¿tienes temporadas pasadas en CSV o planillas que quieras
   importar? (Importación en la etapa 2).

## IA

10. **Qué debe hacer primero la IA:** ¿sugerir el estadio desde la foto (clasificación) o
    también contar órganos con cajas (flores, frutos)? (Clasificación primero).
11. **Fotos ya etiquetadas:** ¿tienes fotos propias con su estadio para un primer
    entrenamiento? ¿Cuántas, aproximadamente?

## Nube y costos

12. **Presupuesto mensual** para servicios: Supabase (plan gratuito → Pro ≈ USD 25/mes) y
    PowerSync (plan gratuito → pagado). ¿Prefieres el camino PowerSync o el motor de
    sincronización propio? (PowerSync).
13. **Repositorio privado:** ¿lo pasamos a privado? (Recomendado; solo tú puedes hacerlo en
    GitHub → Settings → General → Danger Zone → Change visibility).
14. **Licencia:** ¿confirmas licencia propietaria? (Sí, «todos los derechos reservados»).
