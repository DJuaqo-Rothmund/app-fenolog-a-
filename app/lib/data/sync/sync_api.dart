import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class SyncException implements Exception {
  SyncException(this.message, {this.status});
  final String message;
  final int? status;
  @override
  String toString() => message;
}

typedef SyncUser = ({String id, String email, String name, String role});

SyncUser userFromJson(Map<String, dynamic> j) =>
    (id: j['id'] as String, email: j['email'] as String, name: j['name'] as String? ?? '', role: j['role'] as String);

Map<String, Object?> userToJson(SyncUser u) => {'id': u.id, 'email': u.email, 'name': u.name, 'role': u.role};

/// Una fila que viaja entre el teléfono y el servidor.
typedef SyncRow = ({String table, Map<String, Object?> data, int updatedAt});

/// Cliente HTTP del servidor propio de FramBitácora.
class SyncApi {
  SyncApi(this._http, String baseUrl, {this.token}) : baseUrl = baseUrl.replaceFirst(RegExp(r'/+$'), '');
  final http.Client _http;
  final String baseUrl;
  final String? token;

  Uri _uri(String path, [Map<String, String>? query]) => Uri.parse('$baseUrl$path').replace(queryParameters: query);

  Map<String, String> get _headers => {
    'content-type': 'application/json; charset=utf-8',
    if (token != null) 'authorization': 'Bearer $token',
  };

  Future<Map<String, dynamic>> _send(Future<http.Response> Function() request) async {
    final http.Response r;
    try {
      r = await request().timeout(const Duration(seconds: 60));
    } on SocketException {
      throw SyncException('No hay conexión con el servidor.');
    } on http.ClientException catch (e) {
      throw SyncException('No hay conexión con el servidor (${e.message}).');
    } on Exception catch (e) {
      if (e.toString().contains('TimeoutException')) throw SyncException('El servidor no respondió a tiempo.');
      rethrow;
    }
    Map<String, dynamic> body;
    try {
      body = r.bodyBytes.isEmpty ? {} : jsonDecode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>;
    } on FormatException {
      throw SyncException('La dirección no corresponde a un servidor de FramBitácora.', status: r.statusCode);
    }
    if (r.statusCode >= 400) {
      throw SyncException(body['error'] as String? ?? 'Error ${r.statusCode} del servidor.', status: r.statusCode);
    }
    return body;
  }

  Future<({String token, SyncUser user})> login(String email, String password, {String device = ''}) async {
    final b = await _send(
      () => _http.post(
        _uri('/auth/login'),
        headers: _headers,
        body: jsonEncode({'email': email, 'password': password, 'device': device}),
      ),
    );
    return (token: b['token'] as String, user: userFromJson(b['user'] as Map<String, dynamic>));
  }

  Future<SyncUser> me() async =>
      userFromJson((await _send(() => _http.get(_uri('/auth/me'), headers: _headers)))['user'] as Map<String, dynamic>);

  Future<void> logout() => _send(() => _http.post(_uri('/auth/logout'), headers: _headers));

  Future<({int accepted, List<String> stale})> push(List<SyncRow> rows) async {
    final b = await _send(
      () => _http.post(
        _uri('/sync/push'),
        headers: _headers,
        body: jsonEncode({
          'rows': [
            for (final r in rows) {'table': r.table, 'data': r.data, 'updatedAt': r.updatedAt},
          ],
        }),
      ),
    );
    return (accepted: b['accepted'] as int, stale: (b['stale'] as List).cast<String>());
  }

  Future<({List<SyncRow> rows, int next, bool more})> pull(int since) async {
    final b = await _send(() => _http.get(_uri('/sync/pull', {'since': '$since'}), headers: _headers));
    return (
      rows: [
        for (final r in (b['rows'] as List).cast<Map<String, dynamic>>())
          (
            table: r['table'] as String,
            data: (r['data'] as Map<String, dynamic>).cast<String, Object?>(),
            updatedAt: r['updatedAt'] as int,
          ),
      ],
      next: b['next'] as int,
      more: b['more'] as bool,
    );
  }

  Future<void> putPhoto(String id, File file) => _send(
    () => _http.put(
      _uri('/photos/$id'),
      headers: {'content-type': 'image/jpeg', 'authorization': 'Bearer $token'},
      body: file.readAsBytesSync(),
    ),
  );

  /// Bytes de la foto, o nulo si aún no está en el servidor.
  Future<List<int>?> getPhoto(String id) async {
    final r = await _http.get(_uri('/photos/$id'), headers: {'authorization': 'Bearer $token'});
    if (r.statusCode == 404) return null;
    if (r.statusCode != 200) throw SyncException('No se pudo descargar una foto (error ${r.statusCode}).');
    return r.bodyBytes;
  }

  Future<List<({SyncUser user, bool disabled})>> users() async {
    final b = await _send(() => _http.get(_uri('/users'), headers: _headers));
    return [
      for (final u in (b['users'] as List).cast<Map<String, dynamic>>())
        (user: userFromJson(u), disabled: u['disabled'] as bool),
    ];
  }

  Future<void> addUser({required String email, required String name, required String role, required String password}) =>
      _send(
        () => _http.post(
          _uri('/users'),
          headers: _headers,
          body: jsonEncode({'email': email, 'name': name, 'role': role, 'password': password}),
        ),
      );

  Future<void> updateUser(String id, {String? role, bool? disabled, String? password}) => _send(
    () => _http.patch(
      _uri('/users/$id'),
      headers: _headers,
      body: jsonEncode({'role': ?role, 'disabled': ?disabled, 'password': ?password}),
    ),
  );
}
