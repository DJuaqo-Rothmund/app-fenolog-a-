import 'dart:io';

import 'package:frambitacora/data/drive/drive_client.dart';

/// Drive en memoria: carpetas y archivos con su contenido. Varios equipos de
/// prueba pueden compartir el mismo [FakeDrive] (como si fuera la misma cuenta).
class FakeDrive implements DriveApi {
  final folders = <String, String>{'root': ''}; // id → ruta
  final _files = <String, ({String parent, String name, List<int> bytes})>{}; // id → archivo
  final uploads = <String>[]; // rutas completas subidas

  /// Contenido de un archivo por su ruta completa (p. ej. `/FramBitácora/Respaldos/x.zip`).
  List<int>? contentOf(String path) =>
      _files.values.where((f) => '${folders[f.parent]}/${f.name}' == path).firstOrNull?.bytes;

  /// Rutas de todos los archivos.
  Iterable<String> get paths => _files.values.map((f) => '${folders[f.parent]}/${f.name}');

  @override
  Future<({String email, String name})> about() async => (email: 'ana@ejemplo.cl', name: 'Ana');

  @override
  Future<String> folder(String name, {String parentId = 'root'}) async {
    final path = '${folders[parentId]}/$name';
    final found = folders.entries.where((e) => e.value == path).firstOrNull;
    if (found != null) return found.key;
    final id = 'carpeta${folders.length}';
    folders[id] = path;
    return id;
  }

  @override
  Future<Set<String>> names(String parentId) async => {
    for (final f in _files.values)
      if (f.parent == parentId) f.name,
  };

  @override
  Future<String> upload(File file, {required String name, required String parentId, required String mime}) async =>
      uploadBytes(await file.readAsBytes(), name: name, parentId: parentId, mime: mime);

  @override
  Future<String> uploadBytes(
    List<int> bytes, {
    required String name,
    required String parentId,
    required String mime,
  }) async {
    final id = 'archivo${_files.length + 1}';
    _files[id] = (parent: parentId, name: name, bytes: List.of(bytes));
    uploads.add('${folders[parentId]}/$name');
    return id;
  }

  @override
  Future<List<DriveEntry>> list(String parentId) async {
    final prefix = '${folders[parentId]}/';
    return [
      for (final e in folders.entries)
        if (e.value.startsWith(prefix) && !e.value.substring(prefix.length).contains('/'))
          (id: e.key, name: e.value.substring(prefix.length), isFolder: true),
      for (final e in _files.entries)
        if (e.value.parent == parentId) (id: e.key, name: e.value.name, isFolder: false),
    ];
  }

  @override
  Future<List<int>> download(String fileId) async => _files[fileId]!.bytes;

  @override
  Future<String?> findFile(String name) async => _files.entries.where((e) => e.value.name == name).firstOrNull?.key;
}
