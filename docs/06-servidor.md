# 06 · Servidor propio y sincronización

Motor propio, sin Supabase: un servidor pequeño escrito en Dart (el mismo lenguaje de la
app) con **PostgreSQL** como base de datos. El código está en `server/`.

## Cómo funciona

```mermaid
sequenceDiagram
  participant T as Teléfono (SQLite)
  participant S as Servidor (PostgreSQL)
  T->>T: Cada cambio queda en sync_outbox (trigger)
  T->>S: POST /sync/push (filas cambiadas + fecha)
  S->>S: Guarda si es más nueva; le asigna un correlativo
  T->>S: PUT /photos/<id> (fotos pendientes)
  T->>S: GET /sync/pull?since=N
  S-->>T: Filas con correlativo > N
  T->>T: Aplica las más nuevas que las locales
  T->>S: GET /photos/<id> (fotos que faltan)
```

- **Sin conexión primero:** la app nunca espera al servidor. Sincroniza al abrir, cada 10
  minutos y con el botón de la nube.
- **Conflictos:** gana la edición más reciente de cada fila (registro, unidad,
  variedad…). Los registros de una unidad en una semana tienen el mismo identificador en
  todos los teléfonos, así que dos personas que registran la misma unidad la misma semana
  editan **un** registro, no dos.
- **Fotos:** se suben aparte; los demás teléfonos las descargan solas.
- **Roles:** *Dueño* (todo + administra el equipo), *Editor* (registra y edita),
  *Solo lectura* (recibe, no envía).
- **Hora del teléfono:** la regla «gana la más reciente» usa el reloj de cada teléfono;
  conviene dejarlos en hora automática.

## Instalar el servidor

Se necesita un computador siempre encendido con Docker y un dominio (o subdominio). Lo
más simple es un servidor virtual pequeño (1 CPU, 1-2 GB de RAM, 25 GB de disco: ≈ 5-6 USD
al mes en Hetzner, DigitalOcean o Vultr). Con ~500 fotos por temporada (≈ 250 MB) el
disco alcanza para muchos años.

1. Crear el servidor virtual con Ubuntu e instalar Docker:

   ```bash
   curl -fsSL https://get.docker.com | sh
   ```

2. Apuntar un subdominio (p. ej. `frambitacora.midominio.cl`) a la IP del servidor
   (registro DNS tipo A).
3. Descargar el repositorio en el servidor (la imagen se arma con la app web y el
   servidor), entrar a `server/`, crear `.env` a partir de `.env.ejemplo` y completar
   `DOMAIN`, `DB_PASSWORD`, `OWNER_EMAIL` y `OWNER_PASSWORD`:

   ```bash
   git clone https://github.com/DJuaqo-Rothmund/app-fenolog-a-.git frambitacora
   cd frambitacora/server && cp .env.ejemplo .env && nano .env
   ```

4. Levantar todo (servidor, PostgreSQL y HTTPS automático):

   ```bash
   docker compose up -d
   ```

5. La **versión web** queda en la misma dirección: abrir `https://frambitacora.midominio.cl`
   en el navegador del computador e iniciar sesión con la nube (la dirección ya viene
   escrita).
6. En la app: nube de la pantalla de inicio → dirección `https://frambitacora.midominio.cl`,
   el correo y la contraseña del dueño → **Conectar**. La primera sincronización envía
   todo lo que ya estaba en el teléfono.
7. En **Equipo**, agregar a cada persona; la app muestra la contraseña inicial para
   enviársela.

### Respaldos del servidor

```bash
docker compose exec db pg_dump -U frambitacora frambitacora > respaldo_$(date +%F).sql
docker run --rm -v server_fotos:/f -v "$PWD":/out alpine tar czf /out/fotos_$(date +%F).tgz -C /f .
```

Conviene programarlo cada noche (cron) y copiar los archivos fuera del servidor (p. ej. a
Google Drive).

## Versión web (etapa 5)

Es la misma app compilada para el navegador. Guarda sus datos en el navegador (SQLite en
WebAssembly sobre IndexedDB) y se sincroniza con el servidor igual que un teléfono.

- Sirve para **consultar, editar en la oficina, sacar informes PDF, Excel y CSV, e
  importar CSV**. Los archivos se descargan en vez de «compartir».
- Las **fotos se ven** directo desde el servidor, pero se toman desde el teléfono.
- No tiene respaldo local ni subida a Google Drive (eso vive en el teléfono; el servidor
  ya guarda todo).
- Cada ejecución de GitHub Actions publica `frambitacora-web-N` con la web compilada; la
  imagen Docker del servidor la incluye y la entrega en `/`.

Para probarla en el computador sin servidor: `cd app && flutter run -d chrome`.

## Desarrollo

```bash
cd server
dart pub get
dart test        # necesita PostgreSQL de pruebas (ver abajo)
```

Para las pruebas se usa un PostgreSQL local en el puerto 5433, base `frambitacora_test`,
usuario `postgres` sin contraseña:

```bash
docker run -d --name pg-pruebas -p 5433:5432 -e POSTGRES_DB=frambitacora_test -e POSTGRES_HOST_AUTH_METHOD=trust postgres:16
```

La prueba `app/test/data/sync_test.dart` levanta el servidor real y sincroniza dos
«teléfonos» de prueba entre sí; si no hay PostgreSQL, se omite.
