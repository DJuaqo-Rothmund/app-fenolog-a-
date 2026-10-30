import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/drive_client.dart';
import '../../data/drive_sync.dart';
import '../../providers.dart';
import '../common.dart';
import 'device_files.dart';

/// Copia de seguridad completa (todos los proyectos y fotos) y restauración.
class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  String? _status;

  Future<void> _run(String status, Future<void> Function() task) async {
    setState(() => _status = status);
    try {
      await task();
    } catch (e) {
      if (mounted) await _message('No se pudo completar', '$e');
    } finally {
      if (mounted) setState(() => _status = null);
    }
  }

  Future<void> _message(String title, String text) => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(text),
      actions: [FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Aceptar'))],
    ),
  );

  Future<void> _share() => _run('Creando respaldo…', () async {
    final sharer = ref.read(fileSharerProvider);
    final zip = await ref
        .read(backupServiceProvider)
        .create(ref.read(databaseProvider), outDir: await sharer.tempDir());
    await sharer.share([zip], subject: 'Respaldo FramBitácora');
  });

  Future<void> _uploadDrive() => _run('Creando respaldo…', () async {
    final zip = await ref
        .read(backupServiceProvider)
        .create(ref.read(databaseProvider), outDir: await ref.read(fileSharerProvider).tempDir());
    if (mounted) setState(() => _status = 'Subiendo a Google Drive…');
    final sync = ref.read(driveSyncProvider);
    try {
      await sync.uploadBackup(zip);
    } on DriveException catch (e) {
      if (e.status != 401) rethrow;
      await ref.read(googleDriveAuthProvider).forget();
      await sync.uploadBackup(zip);
    }
    if (mounted) await _message('Respaldo en Google Drive', 'Guardado en $driveRootFolder › Respaldos.');
  });

  Future<void> _restore() async {
    final path = await ref.read(fileSharerProvider).pickFile(['zip']);
    if (path == null || !mounted) return;
    final ok = await confirm(
      context,
      title: 'Restaurar respaldo',
      message:
          'Se reemplazarán TODOS los datos y fotos de este teléfono por los del respaldo. '
          'Si tienes datos nuevos, crea antes un respaldo de ellos.',
      action: 'Restaurar',
    );
    if (!ok) return;
    await _run('Revisando respaldo…', () async {
      await ref.read(backupServiceProvider).stageRestore(path);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          title: Text('Respaldo listo'),
          content: Text(
            'Cierra la app por completo (desde las apps recientes) y vuelve a abrirla. '
            'Al abrir se instalará el respaldo.',
          ),
        ),
      );
    });
  }

  Future<void> _disconnect() async {
    await ref.read(googleDriveAuthProvider).disconnect();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cuenta Google desconectada')));
  }

  @override
  Widget build(BuildContext context) {
    final busy = _status != null;
    return Scaffold(
      appBar: AppBar(title: const Text('Respaldo')),
      body: ListView(
        children: [
          if (busy) ...[
            const LinearProgressIndicator(),
            Padding(padding: const EdgeInsets.all(12), child: Text(_status!)),
          ],
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'El respaldo es un archivo .zip con todos los proyectos, registros, mediciones y fotos. '
              'Sirve para no perder datos si se pierde el teléfono o para pasarlos a otro.',
            ),
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Crear respaldo y compartir'),
            subtitle: const Text('Guárdalo en Drive, envíalo por correo o cópialo al computador.'),
            enabled: !busy,
            onTap: _share,
          ),
          ListTile(
            leading: const Icon(Icons.add_to_drive),
            title: const Text('Crear respaldo en mi Google Drive'),
            subtitle: const Text('Se guarda en FramBitácora › Respaldos.'),
            enabled: !busy,
            onTap: _uploadDrive,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings_backup_restore),
            title: const Text('Restaurar desde un respaldo'),
            subtitle: const Text('Reemplaza los datos de este teléfono.'),
            enabled: !busy,
            onTap: _restore,
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Desconectar cuenta Google'),
            enabled: !busy,
            onTap: _disconnect,
          ),
        ],
      ),
    );
  }
}
