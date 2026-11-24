import 'dart:typed_data';

import 'database.dart';
import 'drive/drive_client.dart';
import 'photo_store.dart';

/// De dónde salen los bytes de una foto: en el teléfono, de su carpeta; en la
/// web, de Google Drive (el navegador no tiene carpeta de fotos).
abstract class PhotoSource {
  Future<Uint8List?> bytes(Photo photo);

  /// Guarda en memoria una foto recién subida, para mostrarla sin descargarla.
  void remember(Photo photo, Uint8List bytes) {}
}

class FilePhotoSource extends PhotoSource {
  FilePhotoSource(this.store);
  final PhotoStore store;

  @override
  Future<Uint8List?> bytes(Photo photo) async {
    final f = store.file(photo.localPath);
    return await f.exists() ? f.readAsBytes() : null;
  }
}

/// Fotos leídas desde Drive (por su nombre), con una memoria de las últimas usadas.
class DrivePhotoSource extends PhotoSource {
  DrivePhotoSource(this.drive, {this.capacity = 120});
  final DriveApi drive;
  final int capacity;
  final _cache = <String, Uint8List>{}; // en orden de uso (el primero es el más antiguo)
  final _loading = <String, Future<Uint8List?>>{};

  @override
  Future<Uint8List?> bytes(Photo photo) {
    final hit = _cache.remove(photo.fileName);
    if (hit != null) return Future.value(_cache[photo.fileName] = hit);
    // Ojo: la limpieza no debe devolver el futuro quitado (whenComplete lo esperaría
    // y la descarga se esperaría a sí misma).
    return _loading[photo.fileName] ??= _fetch(photo).whenComplete(() {
      _loading.remove(photo.fileName);
    });
  }

  Future<Uint8List?> _fetch(Photo photo) async {
    final id = await drive.findFile(photo.fileName);
    if (id == null) return null;
    final b = Uint8List.fromList(await drive.download(id));
    remember(photo, b);
    return b;
  }

  @override
  void remember(Photo photo, Uint8List bytes) {
    _cache[photo.fileName] = bytes;
    while (_cache.length > capacity) {
      _cache.remove(_cache.keys.first);
    }
  }
}
