import 'dart:io';

import 'package:frambitacora_server/server.dart';
import 'package:postgres/postgres.dart';
import 'package:shelf/shelf_io.dart' as io;

/// Configuración por variables de entorno:
/// - `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD`: PostgreSQL.
/// - `PHOTOS_DIR`: carpeta de las fotos (por defecto `./fotos`).
/// - `PORT`: puerto HTTP (por defecto 8080).
/// - `WEB_DIR`: carpeta con la versión web compilada (opcional; se entrega en `/`).
/// - `OWNER_EMAIL`, `OWNER_PASSWORD`: dueño inicial (solo si aún no hay usuarios).
Future<void> main() async {
  final env = Platform.environment;
  final pool = Pool<void>.withEndpoints(
    [
      Endpoint(
        host: env['DB_HOST'] ?? 'localhost',
        port: int.parse(env['DB_PORT'] ?? '5432'),
        database: env['DB_NAME'] ?? 'frambitacora',
        username: env['DB_USER'] ?? 'frambitacora',
        password: env['DB_PASSWORD'],
      ),
    ],
    settings: PoolSettings(
      maxConnectionCount: 8,
      sslMode: env['DB_SSL'] == 'require' ? SslMode.require : SslMode.disable,
    ),
  );
  final web = env['WEB_DIR'];
  final server = SyncServer(
    pool,
    photosDir: Directory(env['PHOTOS_DIR'] ?? 'fotos'),
    webDir: web == null || !Directory(web).existsSync() ? null : Directory(web),
  );
  await server.init(ownerEmail: env['OWNER_EMAIL'], ownerPassword: env['OWNER_PASSWORD']);

  final port = int.parse(env['PORT'] ?? '8080');
  await io.serve(server.handler, InternetAddress.anyIPv4, port);
  stdout.writeln('FramBitácora: servidor escuchando en el puerto $port');
}
