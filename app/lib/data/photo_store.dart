import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Guarda los archivos de foto en una carpeta propia de la app.
class PhotoStore {
  PhotoStore({Future<Directory> Function()? baseDir}) : _baseDir = baseDir ?? getApplicationDocumentsDirectory;

  final Future<Directory> Function() _baseDir;

  /// Copia [sourcePath] a `fotos/<folder>/<fileName>`. Si ya existe un archivo
  /// con ese nombre, agrega un sufijo para no sobrescribirlo.
  Future<String> save({required String sourcePath, required String folder, required String fileName}) async {
    final dir = Directory(p.join((await _baseDir()).path, 'fotos', folder));
    await dir.create(recursive: true);
    var target = File(p.join(dir.path, fileName));
    var n = 2;
    while (await target.exists()) {
      target = File(p.join(dir.path, '${p.basenameWithoutExtension(fileName)}-$n${p.extension(fileName)}'));
      n++;
    }
    await File(sourcePath).copy(target.path);
    return target.path;
  }

  Future<void> delete(String path) async {
    final f = File(path);
    if (await f.exists()) await f.delete();
  }
}
