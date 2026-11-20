import 'package:google_sign_in/google_sign_in.dart';

import '../../data/drive/drive_client.dart';

/// Error comprensible al conectar con Google.
class GoogleAuthException implements Exception {
  GoogleAuthException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Permiso de Google para escribir en Drive (se reemplaza en las pruebas).
abstract class GoogleAuth {
  /// Token de acceso a Drive. Si hace falta, muestra el selector de cuentas y
  /// el permiso de Google.
  Future<String> token();

  /// Olvida la cuenta y el permiso (para cambiar de cuenta o desconectar).
  Future<void> signOut();
}

/// Inicio de sesión real con el sistema de cuentas de Google del teléfono.
///
/// Solo pide el permiso `drive.file`. No necesita servidor propio: en Android,
/// Google reconoce la app por su nombre de paquete y la huella (SHA-1) de su
/// llave de firma, registradas en Google Cloud.
class GoogleSignInAuth implements GoogleAuth {
  bool _initialized = false;
  String? _token;
  DateTime? _tokenAt;

  Future<void> _init() async {
    if (_initialized) return;
    await GoogleSignIn.instance.initialize();
    _initialized = true;
  }

  @override
  Future<String> token() async {
    if (_token != null && DateTime.now().difference(_tokenAt!) < const Duration(minutes: 45)) return _token!;
    try {
      await _init();
      final client = GoogleSignIn.instance.authorizationClient;
      final authz =
          await client.authorizationForScopes(const [DriveClient.scope]) ??
          await client.authorizeScopes(const [DriveClient.scope]);
      _token = authz.accessToken;
      _tokenAt = DateTime.now();
      return _token!;
    } on GoogleSignInException catch (e) {
      throw GoogleAuthException(switch (e.code) {
        GoogleSignInExceptionCode.canceled => 'Se canceló la conexión con Google.',
        GoogleSignInExceptionCode.clientConfigurationError || GoogleSignInExceptionCode.providerConfigurationError =>
          'Esta versión de la app todavía no está registrada en Google Cloud para usar Drive '
              '(falta registrar su huella SHA-1). Detalle: ${e.description ?? e.code.name}',
        _ => 'No se pudo conectar con Google: ${e.description ?? e.code.name}',
      });
    }
  }

  @override
  Future<void> signOut() async {
    final t = _token;
    _token = null;
    try {
      await _init();
      if (t != null) await GoogleSignIn.instance.authorizationClient.clearAuthorizationToken(accessToken: t);
      await GoogleSignIn.instance.disconnect();
    } on GoogleSignInException {
      // Si no había sesión, no hay nada que cerrar.
    }
  }
}
