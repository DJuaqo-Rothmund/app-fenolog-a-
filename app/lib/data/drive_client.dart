import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class DriveException implements Exception {
  DriveException(this.message, {this.status});
  final String message;
  final int? status;
  @override
  String toString() => message;
}

/// Cliente mínimo de la API de Google Drive v3. Solo usa el permiso
/// `drive.file`: la app ve únicamente las carpetas y archivos que ella creó.
class DriveClient {
  DriveClient(this._http, this._token);
  final http.Client _http;

  /// Entrega un token de acceso válido.
  final Future<String> Function() _token;

  static const scope = 'https://www.googleapis.com/auth/drive.file';
  static const _api = 'https://www.googleapis.com/drive/v3/files';
  static const _upload = 'https://www.googleapis.com/upload/drive/v3/files';
  static const folderMime = 'application/vnd.google-apps.folder';

  Future<Map<String, String>> _headers([Map<String, String> extra = const {}]) async => {
    'Authorization': 'Bearer ${await _token()}',
    ...extra,
  };

  Never _fail(http.BaseResponse r, String body, String what) {
    final detail = r.statusCode == 401
        ? 'la sesión de Google expiró'
        : r.statusCode == 403
        ? 'Google Drive rechazó el permiso o no hay espacio'
        : 'error ${r.statusCode}';
    throw DriveException('No se pudo $what: $detail. $body'.trim(), status: r.statusCode);
  }

  static String _q(String s) => s.replaceAll(r'\', r'\\').replaceAll("'", r"\'");

  /// Archivos (no borrados) dentro de [parentId]: nombre → id.
  Future<Map<String, String>> list(String parentId, {bool foldersOnly = false}) async {
    final result = <String, String>{};
    String? pageToken;
    do {
      final q = "'${_q(parentId)}' in parents and trashed = false${foldersOnly ? " and mimeType = '$folderMime'" : ''}";
      final uri = Uri.parse(_api).replace(
        queryParameters: {
          'q': q,
          'fields': 'nextPageToken, files(id, name)',
          'pageSize': '1000',
          'spaces': 'drive',
          'pageToken': ?pageToken,
        },
      );
      final r = await _http.get(uri, headers: await _headers());
      if (r.statusCode != 200) _fail(r, r.body, 'leer la carpeta de Drive');
      final data = jsonDecode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>;
      for (final f in (data['files'] as List).cast<Map<String, dynamic>>()) {
        result[f['name'] as String] = f['id'] as String;
      }
      pageToken = data['nextPageToken'] as String?;
    } while (pageToken != null);
    return result;
  }

  /// Devuelve la carpeta [name] dentro de [parentId] (o «Mi unidad»), creándola si no existe.
  Future<String> folder(String name, {String parentId = 'root'}) async {
    final existing = (await list(parentId, foldersOnly: true))[name];
    if (existing != null) return existing;
    final r = await _http.post(
      Uri.parse('$_api?fields=id'),
      headers: await _headers({'Content-Type': 'application/json; charset=UTF-8'}),
      body: jsonEncode({
        'name': name,
        'mimeType': folderMime,
        'parents': [parentId],
      }),
    );
    if (r.statusCode != 200) _fail(r, r.body, 'crear la carpeta «$name»');
    return (jsonDecode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>)['id'] as String;
  }

  /// Sube [file] con subida reanudable (sirve para archivos grandes). Si se
  /// indica [replaceId], reemplaza el contenido de ese archivo.
  Future<String> uploadFile(
    File file, {
    required String name,
    required String parentId,
    required String mimeType,
    String? replaceId,
  }) async {
    final length = await file.length();
    final start = replaceId == null
        ? http.Request('POST', Uri.parse('$_upload?uploadType=resumable&fields=id'))
        : http.Request('PATCH', Uri.parse('$_upload/$replaceId?uploadType=resumable&fields=id'));
    start.headers.addAll(
      await _headers({
        'Content-Type': 'application/json; charset=UTF-8',
        'X-Upload-Content-Type': mimeType,
        'X-Upload-Content-Length': '$length',
      }),
    );
    start.body = jsonEncode({
      'name': name,
      if (replaceId == null) 'parents': [parentId],
    });
    final started = await _http.send(start);
    final startBody = await started.stream.bytesToString();
    final location = started.headers['location'];
    if (started.statusCode != 200 || location == null) _fail(started, startBody, 'subir «$name»');

    final put = http.StreamedRequest('PUT', Uri.parse(location))
      ..headers.addAll(await _headers({'Content-Type': mimeType}))
      ..contentLength = length;
    final sent = _http.send(put);
    await put.sink.addStream(file.openRead());
    await put.sink.close();
    final done = await sent;
    final body = await done.stream.bytesToString();
    if (done.statusCode != 200 && done.statusCode != 201) _fail(done, body, 'subir «$name»');
    return (jsonDecode(body) as Map<String, dynamic>)['id'] as String;
  }
}

String mimeTypeFor(String fileName) => switch (fileName.split('.').last.toLowerCase()) {
  'jpg' || 'jpeg' => 'image/jpeg',
  'png' => 'image/png',
  'xlsx' => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  'csv' => 'text/csv',
  'pdf' => 'application/pdf',
  'zip' => 'application/zip',
  _ => 'application/octet-stream',
};
