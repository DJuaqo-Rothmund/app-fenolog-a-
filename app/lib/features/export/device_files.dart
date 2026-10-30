import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/backup.dart';
import '../../data/drive_client.dart';
import '../../data/drive_sync.dart';

/// Compartir archivos (WhatsApp, correo, Google Drive…) y elegir archivos del teléfono.
class FileSharer {
  Future<void> share(List<File> files, {String? subject}) =>
      SharePlus.instance.share(ShareParams(files: [for (final f in files) XFile(f.path)], subject: subject));

  /// En el teléfono abre «Compartir»; en el navegador descarga el archivo.
  Future<void> shareBytes(String fileName, List<int> bytes, {String? subject}) async {
    if (kIsWeb) {
      await FilePicker.saveFile(fileName: fileName, bytes: Uint8List.fromList(bytes), mimeType: mimeTypeFor(fileName));
      return;
    }
    final file = await File('${(await tempDir()).path}/$fileName').writeAsBytes(bytes);
    await share([file], subject: subject);
  }

  /// Ruta del archivo elegido (solo en el teléfono) o nulo si se cancela.
  Future<String?> pickFile(List<String> extensions) async {
    final picked = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: extensions);
    return picked.firstOrNull?.path;
  }

  /// Contenido del archivo elegido (teléfono y navegador) o nulo si se cancela.
  Future<Uint8List?> pickBytes(List<String> extensions) async {
    final picked = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: extensions);
    return picked.firstOrNull?.readAsBytes();
  }

  /// Carpeta temporal para preparar archivos antes de compartirlos.
  Future<Directory> tempDir() async {
    final dir = Directory('${(await getTemporaryDirectory()).path}/exportar');
    return dir.create(recursive: true);
  }
}

class GoogleAuthException implements Exception {
  GoogleAuthException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Permiso de la cuenta Google para escribir en su Drive (solo archivos
/// creados por la app). No necesita servidor propio: en Android, Google
/// identifica la app por su nombre de paquete y la huella de su llave de firma.
class GoogleDriveAuth {
  bool _initialized = false;
  String? _token;
  DateTime? _tokenAt;

  Future<String> token() async {
    if (_token != null && DateTime.now().difference(_tokenAt!) < const Duration(minutes: 45)) return _token!;
    try {
      if (!_initialized) {
        await GoogleSignIn.instance.initialize();
        _initialized = true;
      }
      final client = GoogleSignIn.instance.authorizationClient;
      final authz =
          await client.authorizationForScopes(const [DriveClient.scope]) ??
          await client.authorizeScopes(const [DriveClient.scope]);
      _token = authz.accessToken;
      _tokenAt = DateTime.now();
      return _token!;
    } on GoogleSignInException catch (e) {
      throw GoogleAuthException(switch (e.code) {
        GoogleSignInExceptionCode.canceled => 'Se canceló el inicio de sesión con Google.',
        GoogleSignInExceptionCode.clientConfigurationError || GoogleSignInExceptionCode.providerConfigurationError =>
          'Esta versión de la app aún no está registrada en Google Cloud para usar Drive. '
              'Mientras tanto, usa «Compartir» y elige Drive. (${e.description ?? e.code.name})',
        _ => 'No se pudo conectar con Google: ${e.description ?? e.code.name}',
      });
    }
  }

  /// Olvida el token (p. ej. si Drive respondió que expiró).
  Future<void> forget() async {
    final t = _token;
    _token = null;
    if (t != null) await GoogleSignIn.instance.authorizationClient.clearAuthorizationToken(accessToken: t);
  }

  Future<void> disconnect() async {
    _token = null;
    if (_initialized) await GoogleSignIn.instance.disconnect();
  }
}

final fileSharerProvider = Provider((ref) => FileSharer());
final googleDriveAuthProvider = Provider((ref) => GoogleDriveAuth());
final driveSyncProvider = Provider((ref) {
  final auth = ref.watch(googleDriveAuthProvider);
  return DriveSync(DriveClient(http.Client(), auth.token));
});
final backupServiceProvider = Provider((ref) => BackupService(getApplicationDocumentsDirectory));
