# FramBitácora

Cuaderno de campo digital para el **seguimiento fenológico de cultivos**: registro semanal
del estado fenológico con fotos, notas y ubicación, que funciona **sin conexión**.
Primer cultivo: **frambueso**; preparada para muchos cultivos más (cada cultivo se define
en un archivo JSON, sin cambiar código).

## Estado

| Etapa | Estado |
|---|---|
| 0 · Fundaciones (proyecto, pruebas, compilación automática) | ✅ |
| 1 · MVP sin conexión (cultivos, variedades, proyectos, unidades, semanas, registro con fotos) | ✅ para probar en terreno |
| 2 en adelante (mediciones, informes, nube, web, IA) | Pendiente — ver [plan](docs/03-plan-etapas.md) |

## Descargar el APK de prueba

1. En GitHub, pestaña **Actions** → flujo **Android** → la ejecución más reciente en verde.
2. Al final de la página, en **Artifacts**, descargar `frambitacora-apk-N` (es un .zip con
   el archivo `app-release.apk`).
3. Copiar el APK al teléfono Android y abrirlo (permitir «instalar apps desconocidas»).

Para que cada versión nueva se instale encima de la anterior sin desinstalar, hay que
configurar una llave de firma propia (ver [docs/05-desarrollo.md](docs/05-desarrollo.md)).

## Estructura

```
app/                      Proyecto Flutter (Android)
  lib/domain/             Reglas puras: semanas, nombre de fotos, definición de cultivos
  lib/data/               Base de datos local (SQLite/Drift) y repositorios
  lib/features/           Pantallas: proyectos, registro semanal, variedades, escala
  assets/crops/           Definiciones de cultivos (frambueso)
  test/                   Pruebas automáticas
docs/                     Tecnología, arquitectura, modelo de datos, plan y decisiones
.github/workflows/        Pruebas y compilación del APK en cada cambio
```

## Documentos

| Documento | Contenido |
|---|---|
| [docs/00-tecnologia.md](docs/00-tecnologia.md) | Tecnología elegida, pros y contras |
| [docs/01-arquitectura.md](docs/01-arquitectura.md) | Arquitectura y funcionamiento sin conexión |
| [docs/02-modelo-datos.md](docs/02-modelo-datos.md) | Modelo de datos multi-cultivo |
| [docs/03-plan-etapas.md](docs/03-plan-etapas.md) | Plan por etapas |
| [docs/04-decisiones.md](docs/04-decisiones.md) | Decisiones tomadas |
| [docs/05-desarrollo.md](docs/05-desarrollo.md) | Cómo compilar, probar y agregar cultivos |

## Licencia

[MIT](LICENSE).
