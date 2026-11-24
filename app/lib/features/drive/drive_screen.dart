import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../../data/drive/data_sync.dart';
import '../../data/drive/drive_client.dart';
import '../../data/drive/drive_sync.dart';
import '../../providers.dart';
import '../common.dart';
import 'auto_sync.dart';
import 'google_auth.dart';

final _when = DateFormat("d 'de' MMMM, HH:mm", 'es');

/// Botón con el diseño del sistema de Google: fondo claro (u oscuro en modo
/// oscuro), borde gris, la «G» de colores y el texto en negrita.
class GoogleButton extends StatelessWidget {
  const GoogleButton({super.key, required this.label, required this.onPressed, this.busy = false});
  final String label;
  final VoidCallback? onPressed;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final fg = dark ? const Color(0xFFE3E3E3) : const Color(0xFF1F1F1F);
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: busy ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: dark ? const Color(0xFF131314) : Colors.white,
          foregroundColor: fg,
          disabledForegroundColor: fg.withValues(alpha: 0.5),
          side: BorderSide(color: dark ? const Color(0xFF8E918F) : const Color(0xFFC4C7C5), width: 1.5),
          shape: const StadiumBorder(),
          elevation: dark ? 0 : 1,
          shadowColor: Colors.black26,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            busy
                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5))
                : SvgPicture.asset('assets/icons/google_g.svg', width: 22, height: 22, excludeFromSemantics: true),
            const SizedBox(width: 14),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: fg),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Conectar la cuenta de Google y subir fotos y respaldos a Drive.
class DriveScreen extends ConsumerStatefulWidget {
  const DriveScreen({super.key});

  @override
  ConsumerState<DriveScreen> createState() => _DriveScreenState();
}

class _DriveScreenState extends ConsumerState<DriveScreen> {
  bool _connecting = false;
  bool _includeBackup = !kIsWeb;
  ({String step, int done, int total})? _progress;

  void _message(String text, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(text), backgroundColor: error ? Theme.of(context).colorScheme.error : null));
  }

  Future<void> _account(Future<void> Function(DriveAccountNotifier n) action) async {
    setState(() => _connecting = true);
    try {
      await action(ref.read(driveAccountProvider.notifier));
    } on GoogleAuthException catch (e) {
      _message(e.message, error: true);
    } on DriveException catch (e) {
      _message(e.message, error: true);
    } catch (e) {
      _message('No se pudo conectar con Google: $e', error: true);
    } finally {
      if (mounted) setState(() => _connecting = false);
    }
  }

  Future<void> _sync() async {
    setState(() => _progress = (step: 'Preparando', done: 0, total: 0));
    try {
      final r = await ref
          .read(syncCoordinatorProvider.notifier)
          .run(
            includeBackup: _includeBackup,
            progress: (step, done, total) {
              if (mounted) setState(() => _progress = (step: step, done: done, total: total));
            },
          );
      if (r == null) {
        _message('Ya se está sincronizando sola; espera un momento y vuelve a intentarlo.');
        return;
      }
      final parts = [
        if (!kIsWeb) r.uploaded == 1 ? '1 foto subida' : '${r.uploaded} fotos subidas',
        if (r.alreadyThere > 0) '${r.alreadyThere} ya estaban',
        if (r.missing > 0) '${r.missing} sin archivo en el teléfono',
        if (r.downloaded > 0) r.downloaded == 1 ? '1 foto bajada' : '${r.downloaded} fotos bajadas',
        if (r.sent > 0) r.sent == 1 ? '1 dato enviado' : '${r.sent} datos enviados',
        if (r.received > 0) r.received == 1 ? '1 cambio recibido' : '${r.received} cambios recibidos',
        if (r.backupName != null) 'copia de seguridad subida',
      ];
      _message(
        r.otherDevices == 0 && kIsWeb
            ? 'Aún no hay datos del teléfono en Drive. En el teléfono, con la versión más nueva de la app: '
                  'Configuración → Google Drive → Sincronizar ahora. Luego sincroniza aquí otra vez.'
            : parts.isEmpty
            ? 'Listo: sin cambios nuevos.'
            : 'Listo: ${parts.join(' · ')}.',
      );
    } on GoogleAuthException catch (e) {
      _message(e.message, error: true);
    } on DriveException catch (e) {
      _message(e.message, error: true);
    } catch (e) {
      _message('La sincronización se detuvo: $e. Puedes reintentar; no se repiten las fotos ya subidas.', error: true);
    } finally {
      if (mounted) setState(() => _progress = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final account = ref.watch(driveAccountProvider);
    final pending = ref.watch(drivePendingProvider).value;
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final status = ref.watch(syncCoordinatorProvider);
    final auto = ref.watch(autoSyncEnabledProvider);
    final busy = _connecting || _progress != null || status.running;

    return PopScope(
      canPop: _progress == null,
      child: Scaffold(
        appBar: AppBar(title: const Text('Google Drive')),
        body: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [scheme.primaryContainer, scheme.secondaryContainer.withValues(alpha: 0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (account != null) ...[
                    Text(
                      'Google Drive conectado · ${account.email}',
                      textAlign: TextAlign.center,
                      style: text.bodyMedium?.copyWith(color: scheme.onPrimaryContainer),
                    ),
                    const SizedBox(height: 12),
                    GoogleButton(
                      label: 'Cambiar cuenta de Google',
                      busy: _connecting,
                      onPressed: busy ? null : () => _account((n) => n.changeAccount()),
                    ),
                  ] else ...[
                    Text(
                      'Sincroniza tus datos y fotos con tu Google Drive',
                      textAlign: TextAlign.center,
                      style: text.titleMedium?.copyWith(color: scheme.onPrimaryContainer),
                    ),
                    const SizedBox(height: 12),
                    GoogleButton(
                      label: 'Continuar con Google',
                      busy: _connecting,
                      onPressed: busy ? null : () => _account((n) => n.connect()),
                    ),
                  ],
                ],
              ),
            ),
            if (account != null) ...[
              const SectionHeader('Sincronizar'),
              SettingsGroup(
                children: [
                  ListTile(
                    leading: const Icon(Icons.photo_library_outlined),
                    title: Text(
                      pending == null
                          ? 'Revisando fotos…'
                          : pending == 0
                          ? 'Todas las fotos están en Drive'
                          : pending == 1
                          ? '1 foto por subir'
                          : '$pending fotos por subir',
                    ),
                    subtitle: Text(
                      status.running && _progress == null
                          ? 'Sincronizando…'
                          : account.lastSync == null
                          ? 'Aún no se ha sincronizado'
                          : 'Última sincronización: ${_when.format(account.lastSync!)}',
                    ),
                  ),
                  SwitchListTile(
                    secondary: const Icon(Icons.sync),
                    title: const Text('Sincronizar automáticamente'),
                    subtitle: const Text(
                      'Al abrir la app, al volver a ella, cada 10 minutos y poco después de cada cambio '
                      '(sin la copia de seguridad, que es manual)',
                    ),
                    value: auto,
                    onChanged: (v) => ref.read(autoSyncEnabledProvider.notifier).set(v),
                  ),
                  if (status.problem case final problem?)
                    ListTile(
                      leading: Icon(Icons.info_outline, color: scheme.error),
                      title: Text(problem, style: TextStyle(color: scheme.error)),
                    ),
                  if (!kIsWeb)
                    SwitchListTile(
                      secondary: const Icon(Icons.backup_outlined),
                      title: const Text('Incluir copia de seguridad completa'),
                      subtitle: const Text('Datos y fotos en un .zip, para restaurar en otro teléfono'),
                      value: _includeBackup,
                      onChanged: busy ? null : (v) => setState(() => _includeBackup = v),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    child: FilledButton.icon(
                      onPressed: busy ? null : _sync,
                      icon: const Icon(Icons.cloud_upload_outlined),
                      label: const Text('Sincronizar ahora'),
                    ),
                  ),
                ],
              ),
              if (_progress case final pr?)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(pr.total > 0 && pr.done < pr.total ? '${pr.step}: ${pr.done + 1} de ${pr.total}' : pr.step),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(value: pr.total > 0 && pr.done < pr.total ? pr.done / pr.total : null),
                      const SizedBox(height: 6),
                      Text('Necesita internet (mejor con Wi-Fi). No cierres la app.', style: text.bodySmall),
                    ],
                  ),
                ),
            ],
            const SectionHeader('Cómo queda en tu Drive'),
            const SettingsGroup(
              children: [
                _FolderRow(depth: 0, name: DriveSync.rootFolder, note: 'Carpeta principal'),
                _FolderRow(depth: 1, name: 'Proyecto / Temporada / Semana 07', note: 'Fotos con su nombre estándar'),
                _FolderRow(depth: 1, name: DriveSync.backupsFolder, note: 'Copias de seguridad (.zip)'),
                _FolderRow(depth: 1, name: syncDataFolder, note: 'Cambios de cada equipo (teléfono y web)'),
              ],
            ),
            const SectionHeader('Privacidad'),
            const Padding(
              padding: EdgeInsets.fromLTRB(28, 0, 24, 0),
              child: Text(
                'La app solo pide permiso para los archivos que ella misma crea: no puede ver ni tocar el resto '
                'de tu Drive. Sube, pero nunca borra. Sin internet todo sigue funcionando; sincroniza cuando '
                'tengas conexión. Si un mismo registro se cambió en el teléfono y en la web, queda el cambio '
                'más reciente.',
              ),
            ),
            if (account != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: TextButton.icon(
                  onPressed: busy ? null : () => _account((n) => n.disconnect()),
                  icon: const Icon(Icons.link_off),
                  label: const Text('Desconectar Google Drive'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FolderRow extends StatelessWidget {
  const _FolderRow({required this.depth, required this.name, required this.note});
  final int depth;
  final String name;
  final String note;

  @override
  Widget build(BuildContext context) => ListTile(
    dense: true,
    contentPadding: EdgeInsets.only(left: 16.0 + depth * 24, right: 16),
    leading: Icon(depth == 0 ? Icons.folder : Icons.folder_outlined, color: Theme.of(context).colorScheme.primary),
    title: Text(name),
    subtitle: Text(note),
  );
}
