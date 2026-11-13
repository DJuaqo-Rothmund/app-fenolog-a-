import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

import '../../data/backup_service.dart';
import '../../providers.dart';

/// Acciones del sistema que usa la pantalla (se reemplazan en las pruebas).
class BackupFileActions {
  const BackupFileActions();

  /// Abre el menú «Compartir» de Android (Drive, correo, WhatsApp, Archivos…).
  Future<void> share(String path) => SharePlus.instance.share(
    ShareParams(
      files: [XFile(path, mimeType: 'application/zip')],
      subject: 'Copia de seguridad de FramBitácora',
    ),
  );

  /// Deja elegir un `.zip` y devuelve una ruta local para leerlo.
  Future<String?> pickBackup(String tempDir) async {
    final picked = await FilePicker.pickFile(type: FileType.custom, allowedExtensions: const ['zip']);
    if (picked == null) return null;
    final path = picked.path;
    if (path != null) return path;
    // Algunos proveedores (p. ej. Drive) entregan el archivo sin ruta local: se copia a la caché.
    final dest = File(p.join(tempDir, 'respaldo_elegido.zip'));
    final sink = dest.openWrite();
    await sink.addStream(picked.xFile.openRead());
    await sink.close();
    return dest.path;
  }
}

final backupFileActionsProvider = Provider((ref) => const BackupFileActions());

final _date = DateFormat("d 'de' MMMM 'de' y, HH:mm", 'es');

String formatBytes(int bytes) {
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
  final mb = bytes / (1024 * 1024);
  return mb < 1024 ? '${mb.toStringAsFixed(1)} MB' : '${(mb / 1024).toStringAsFixed(2)} GB';
}

/// Crear una copia de seguridad completa (datos + fotos) y restaurarla.
class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  String? _busy;
  String? _lastZip;

  BackupService get _service => ref.read(backupServiceProvider);
  BackupFileActions get _actions => ref.read(backupFileActionsProvider);

  Future<T?> _run<T>(String label, Future<T> Function() task) async {
    setState(() => _busy = label);
    try {
      return await task();
    } on BackupException catch (e) {
      _message(e.message, error: true);
    } catch (e) {
      _message('Ocurrió un error inesperado: $e', error: true);
    } finally {
      if (mounted) setState(() => _busy = null);
    }
    return null;
  }

  void _message(String text, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(text), backgroundColor: error ? Theme.of(context).colorScheme.error : null));
  }

  Future<void> _create() async {
    final zip = await _run('Creando la copia…', () => _service.create());
    if (zip == null || !mounted) return;
    setState(() => _lastZip = zip);
    await _share(zip);
  }

  Future<void> _share(String zip) => _run('Abriendo «Compartir»…', () => _actions.share(zip));

  Future<void> _restore() async {
    final path = await _run('Abriendo el archivo…', () => _actions.pickBackup(ref.read(tempDirProvider)));
    if (path == null || !mounted) return;
    final manifest = await _run('Revisando la copia…', () => _service.inspect(path));
    if (manifest == null || !mounted) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => _ConfirmRestoreDialog(manifest: manifest),
    );
    if (ok != true || !mounted) return;

    final restored = await _run('Restaurando…', () => _service.restore(path));
    if (restored == null || !mounted) return;
    _message('Copia restaurada: ${restored.projects} proyectos, ${restored.photos} fotos.');
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final busy = _busy != null;
    final lastZip = _lastZip;
    return PopScope(
      canPop: !busy,
      child: Scaffold(
        appBar: AppBar(title: const Text('Copia de seguridad')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'La copia incluye todos los proyectos, temporadas, registros y fotos de este teléfono en un solo '
              'archivo .zip. Guárdala fuera del teléfono (Drive, correo o un computador): si el teléfono se pierde '
              'o hay que reinstalar la app, con ella se recupera todo.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: busy ? null : _create,
              icon: const Icon(Icons.save_alt),
              label: const Text('Crear copia y compartir'),
            ),
            if (lastZip != null) ...[
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.inventory_2_outlined),
                  title: Text(p.basename(lastZip)),
                  subtitle: Text(File(lastZip).existsSync() ? formatBytes(File(lastZip).lengthSync()) : ''),
                  trailing: IconButton(
                    tooltip: 'Compartir otra vez',
                    icon: const Icon(Icons.share),
                    onPressed: busy ? null : () => _share(lastZip),
                  ),
                ),
              ),
            ],
            const Divider(height: 40),
            Text('Restaurar', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Reemplaza todos los datos y fotos de este teléfono por los de una copia. Sirve para pasar los datos '
              'a un teléfono nuevo o recuperarlos tras reinstalar.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: busy ? null : _restore,
              icon: const Icon(Icons.restore),
              label: const Text('Elegir copia para restaurar'),
            ),
            if (busy) ...[
              const SizedBox(height: 32),
              const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 12),
              Center(child: Text(_busy!)),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  'Con muchas fotos puede tardar unos minutos. No cierres la app.',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ConfirmRestoreDialog extends StatelessWidget {
  const _ConfirmRestoreDialog({required this.manifest});
  final BackupManifest manifest;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: const Text('¿Restaurar esta copia?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Copia del ${_date.format(manifest.createdAt)}'),
          const SizedBox(height: 8),
          Text('${manifest.projects} proyectos · ${manifest.observations} registros · ${manifest.photos} fotos'),
          const SizedBox(height: 16),
          Text(
            'Se borrarán todos los datos y fotos actuales de este teléfono y se reemplazarán por los de la copia. '
            'Esto no se puede deshacer.',
            style: TextStyle(color: scheme.error),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: scheme.error, foregroundColor: scheme.onError),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Reemplazar todo'),
        ),
      ],
    );
  }
}
