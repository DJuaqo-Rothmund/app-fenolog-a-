import 'dart:io';

import 'package:path/path.dart' as p;

/// Carpeta (dentro de la carpeta de la app) donde viven las fotos.
const photosFolder = 'fotos';

/// Guarda los archivos de foto en una carpeta propia de la app.
///
/// La base de datos guarda la ruta **relativa** (`fotos/<temporada>/<archivo>`),
/// así una copia de seguridad se puede restaurar en otro teléfono o tras
/// reinstalar, donde la carpeta de la app tiene otra ruta completa.
class PhotoStore {
  PhotoStore(this.rootPath);

  /// Carpeta de documentos de la app (en las pruebas, una carpeta temporal).
  final String rootPath;

  /// Carpeta completa de fotos.
  Directory get photosDir => Directory(p.join(rootPath, photosFolder));

  /// Archivo correspondiente a una ruta relativa guardada en la base.
  File file(String relativePath) => File(p.join(rootPath, relativePath));

  /// Copia [sourcePath] a `fotos/<folder>/<fileName>` y devuelve la ruta
  /// relativa. Si ya existe un archivo con ese nombre, agrega un sufijo para no
  /// sobrescribirlo.
  Future<String> save({required String sourcePath, required String folder, required String fileName}) async {
    final dir = Directory(p.join(photosDir.path, folder));
    await dir.create(recursive: true);
    var name = fileName;
    var n = 2;
    while (await File(p.join(dir.path, name)).exists()) {
      name = '${p.basenameWithoutExtension(fileName)}-$n${p.extension(fileName)}';
      n++;
    }
    await File(sourcePath).copy(p.join(dir.path, name));
    return p.posix.join(photosFolder, folder, name);
  }

  Future<void> delete(String relativePath) async {
    final f = file(relativePath);
    if (await f.exists()) await f.delete();
  }
}

/// Convierte la ruta completa que guardaba la versión 1 de la base
/// (`/data/user/0/…/fotos/<temporada>/<archivo>`) en una ruta relativa
/// (`fotos/<temporada>/<archivo>`). Si ya es relativa, la deja igual.
String relativePhotoPath(String storedPath) {
  final normalized = storedPath.replaceAll(r'\', '/');
  if (normalized.startsWith('$photosFolder/')) return normalized;
  final i = normalized.lastIndexOf('/$photosFolder/');
  return i < 0 ? normalized : normalized.substring(i + 1);
}
