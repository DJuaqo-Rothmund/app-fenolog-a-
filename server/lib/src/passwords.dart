import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

final _random = Random.secure();

/// Texto aleatorio seguro (para tokens e identificadores).
String randomToken([int bytes = 32]) =>
    base64Url.encode(List<int>.generate(bytes, (_) => _random.nextInt(256))).replaceAll('=', '');

String sha256Hex(String s) => sha256.convert(utf8.encode(s)).toString();

const _iterations = 120000;

/// PBKDF2-HMAC-SHA256. Formato guardado: `pbkdf2$<iteraciones>$<sal>$<hash>`.
String hashPassword(String password, {String? salt, int iterations = _iterations}) {
  salt ??= randomToken(16);
  final key = _pbkdf2(utf8.encode(password), utf8.encode(salt), iterations, 32);
  return 'pbkdf2\$$iterations\$$salt\$${base64.encode(key)}';
}

bool verifyPassword(String password, String stored) {
  final parts = stored.split('\$');
  if (parts.length != 4 || parts[0] != 'pbkdf2') return false;
  final expected = hashPassword(password, salt: parts[2], iterations: int.parse(parts[1]));
  // Comparación en tiempo constante.
  if (expected.length != stored.length) return false;
  var diff = 0;
  for (var i = 0; i < stored.length; i++) {
    diff |= expected.codeUnitAt(i) ^ stored.codeUnitAt(i);
  }
  return diff == 0;
}

Uint8List _pbkdf2(List<int> password, List<int> salt, int iterations, int length) {
  final hmac = Hmac(sha256, password);
  final out = BytesBuilder();
  for (var block = 1; out.length < length; block++) {
    var u = hmac.convert([...salt, block >> 24 & 0xff, block >> 16 & 0xff, block >> 8 & 0xff, block & 0xff]).bytes;
    final t = Uint8List.fromList(u);
    for (var i = 1; i < iterations; i++) {
      u = hmac.convert(u).bytes;
      for (var j = 0; j < t.length; j++) {
        t[j] ^= u[j];
      }
    }
    out.add(t);
  }
  return out.toBytes().sublist(0, length);
}
