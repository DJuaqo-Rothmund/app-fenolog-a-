import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// Error comprensible al hablar con Google Drive.
class DriveException implements Exception {
  DriveException(this.message, {this.status});
  final String message;
  final int? status;
  @override
  String toString() => message;
}

/// Un archivo o carpeta de Drive.
typedef DriveEntry = ({String id, String name, bool isFolder});

/// Lo que la sincronización necesita de Drive (se reemplaza en las pruebas).
abstract class DriveApi {
  /// Correo y nombre de la cuenta conectada.
  Future<({String email, String name})> about();

  /// Id de la carpeta [name] dentro de [parentId] («root» = Mi unidad); la crea si no existe.
  Future<String> folder(String name, {String parentId = 'root'});

  /// Nombres de los archivos que ya hay en la carpeta.
  Future<Set<String>> names(String parentId);

  /// Sube un archivo a la carpeta y devuelve su id.
  Future<String> upload(File file, {required String name, required String parentId, required String mime});

  /// Archivos y carpetas que hay dentro de [parentId].
  Future<List<DriveEntry>> list(String parentId);

  /// Sube un contenido pequeño (p. ej. un archivo de cambios) y devuelve su id.
  Future<String> uploadBytes(List<int> bytes, {required String name, required String parentId, required String mime});

  /// Descarga el contenido de un archivo.
  Future<List<int>> download(String fileId);

  /// Id de un archivo (no carpeta) con ese nombre, en cualquier carpeta de la app.
  Future<String?> findFile(String name);
}

/// Cliente mínimo de la API de Google Drive v3. Usa solo el permiso
/// `drive.file`: la app ve únicamente las carpetas y archivos que ella creó.
class DriveClient implements DriveApi {
  DriveClient(this._http, this._token);
  final http.Client _http;

  /// Entrega un token de acceso válido de la cuenta conectada.
  final Future<String> Function() _token;

  static const scope = 'https://www.googleapis.com/auth/drive.file';
  static const _api = 'https://www.googleapis.com/drive/v3';
  static const _uploadUrl = 'https://www.googleapis.com/upload/drive/v3/files';
  static const folderMime = 'application/vnd.google-apps.folder';

  Future<Map<String, String>> _headers([Map<String, String> extra = const {}]) async => {
    'Authorization': 'Bearer ${await _token()}',
    ...extra,
  };

  Never _fail(int status, String what) {
    final detail = switch (status) {
      401 => 'la sesión de Google expiró; vuelve a conectar la cuenta',
      403 => 'Google Drive rechazó el permiso o no queda espacio',
      404 => 'no se encontró la carpeta en Drive',
      _ => 'error $status',
    };
    throw DriveException('No se pudo $what: $detail.', status: status);
  }

  static String _quote(String s) => s.replaceAll(r'\', r'\\').replaceAll("'", r"\'");

  Future<List<Map<String, dynamic>>> _list(String q, {bool withType = false}) async {
    final out = <Map<String, dynamic>>[];
    String? page;
    do {
      final uri = Uri.parse('$_api/files').replace(
        queryParameters: {
          'q': q,
          'fields': withType ? 'nextPageToken, files(id, name, mimeType)' : 'nextPageToken, files(id, name)',
          'pageSize': '1000',
          'spaces': 'drive',
          'pageToken': ?page,
        },
      );
      final r = await _http.get(uri, headers: await _headers());
      if (r.statusCode != 200) _fail(r.statusCode, 'leer Drive');
      final data = jsonDecode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>;
      out.addAll((data['files'] as List).cast<Map<String, dynamic>>());
      page = data['nextPageToken'] as String?;
    } while (page != null);
    return out;
  }

  @override
  Future<({String email, String name})> about() async {
    final r = await _http.get(
      Uri.parse('$_api/about?fields=user(emailAddress,displayName)'),
      headers: await _headers(),
    );
    if (r.statusCode != 200) _fail(r.statusCode, 'leer la cuenta de Google');
    final user = (jsonDecode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>)['user'] as Map<String, dynamic>;
    return (email: user['emailAddress'] as String? ?? '', name: user['displayName'] as String? ?? '');
  }

  @override
  Future<String> folder(String name, {String parentId = 'root'}) async {
    final found = await _list(
      "'${_quote(parentId)}' in parents and name = '${_quote(name)}' and mimeType = '$folderMime' and trashed = false",
    );
    if (found.isNotEmpty) return found.first['id'] as String;
    final r = await _http.post(
      Uri.parse('$_api/files?fields=id'),
      headers: await _headers({'Content-Type': 'application/json; charset=UTF-8'}),
      body: jsonEncode({
        'name': name,
        'mimeType': folderMime,
        'parents': [parentId],
      }),
    );
    if (r.statusCode != 200) _fail(r.statusCode, 'crear la carpeta «$name»');
    return (jsonDecode(r.body) as Map<String, dynamic>)['id'] as String;
  }

  @override
  Future<Set<String>> names(String parentId) async => {
    for (final f in await _list("'${_quote(parentId)}' in parents and trashed = false")) f['name'] as String,
  };

  @override
  Future<List<DriveEntry>> list(String parentId) async => [
    for (final f in await _list("'${_quote(parentId)}' in parents and trashed = false", withType: true))
      (id: f['id'] as String, name: f['name'] as String, isFolder: f['mimeType'] == folderMime),
  ];

  @override
  Future<String?> findFile(String name) async {
    final found = await _list("name = '${_quote(name)}' and mimeType != '$folderMime' and trashed = false");
    return found.isEmpty ? null : found.first['id'] as String;
  }

  @override
  Future<List<int>> download(String fileId) async {
    final r = await _http.get(
      Uri.parse('$_api/files/${Uri.encodeComponent(fileId)}?alt=media'),
      headers: await _headers(),
    );
    if (r.statusCode != 200) _fail(r.statusCode, 'descargar un archivo');
    return r.bodyBytes;
  }

  @override
  Future<String> uploadBytes(List<int> bytes, {required String name, required String parentId, required String mime}) =>
      _upload(Stream.value(bytes), bytes.length, name: name, parentId: parentId, mime: mime);

  /// Subida «reanudable»: primero se pide una dirección de subida y luego se envía
  /// el archivo como flujo, sin cargarlo entero en memoria (sirve para respaldos grandes).
  @override
  Future<String> upload(File file, {required String name, required String parentId, required String mime}) async =>
      _upload(file.openRead(), await file.length(), name: name, parentId: parentId, mime: mime);

  Future<String> _upload(
    Stream<List<int>> content,
    int length, {
    required String name,
    required String parentId,
    required String mime,
  }) async {
    final start = await _http.post(
      Uri.parse('$_uploadUrl?uploadType=resumable&fields=id'),
      headers: await _headers({
        'Content-Type': 'application/json; charset=UTF-8',
        'X-Upload-Content-Type': mime,
        'X-Upload-Content-Length': '$length',
      }),
      body: jsonEncode({
        'name': name,
        'parents': [parentId],
      }),
    );
    final location = start.headers['location'];
    if (start.statusCode != 200 || location == null) _fail(start.statusCode, 'subir «$name»');

    final put = http.StreamedRequest('PUT', Uri.parse(location))
      ..headers.addAll({'Content-Type': mime, 'Content-Length': '$length'})
      ..contentLength = length;
    content.listen(put.sink.add, onDone: put.sink.close, onError: put.sink.addError);
    final r = await http.Response.fromStream(await _http.send(put));
    if (r.statusCode != 200 && r.statusCode != 201) _fail(r.statusCode, 'subir «$name»');
    return (jsonDecode(r.body) as Map<String, dynamic>)['id'] as String;
  }
}
