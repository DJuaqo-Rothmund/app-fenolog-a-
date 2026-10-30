import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/csv_importer.dart';
import '../../data/database.dart';
import '../../data/drive_client.dart';
import '../../data/drive_sync.dart';
import '../../data/excel_export.dart';
import '../../data/season_data.dart';
import '../../data/season_tables.dart';
import '../../providers.dart';
import 'device_files.dart';

/// Sacar y meter datos de una temporada: Excel, CSV, Google Drive e
/// importación de temporadas anteriores.
class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key, required this.project, required this.season});
  final Project project;
  final Season season;

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  String? _status;
  double? _progress;

  bool get _busy => _status != null;

  String get _baseName => '${safeFileName(widget.project.name)}_${safeFileName(widget.season.name)}';

  Future<void> _run(String status, Future<void> Function() task) async {
    setState(() {
      _status = status;
      _progress = null;
    });
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
      content: SingleChildScrollView(child: Text(text)),
      actions: [FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Aceptar'))],
    ),
  );

  Future<SeasonData> _data() => loadSeasonData(ref.read(databaseProvider), widget.season.id);

  Future<File> _writeExcel(SeasonData d) async {
    final dir = await ref.read(fileSharerProvider).tempDir();
    return File('${dir.path}/$_baseName.xlsx').writeAsBytes(buildSeasonWorkbook(d));
  }

  Future<void> _shareExcel() => _run('Preparando Excel…', () async {
    final file = await _writeExcel(await _data());
    await ref.read(fileSharerProvider).share([file], subject: 'FramBitácora · ${widget.project.name}');
  });

  Future<void> _shareCsv() => _run('Preparando CSV…', () async {
    final sharer = ref.read(fileSharerProvider);
    final dir = await sharer.tempDir();
    // Con marca BOM para que Excel reconozca las tildes.
    final file = await File('${dir.path}/${_baseName}_registros.csv')
        .writeAsString('﻿${toCsv(recordsTable(await _data()))}');
    await sharer.share([file], subject: 'FramBitácora · ${widget.project.name}');
  });

  Future<void> _uploadDrive() => _run('Conectando con Google Drive…', () async {
    final data = await _data();
    final excel = await _writeExcel(data);
    final sync = ref.read(driveSyncProvider);
    Future<DriveUploadResult> upload() => sync.uploadSeason(
      data,
      workbook: excel,
      onProgress: (done, total) {
        if (mounted) {
          setState(() {
            _status = 'Subiendo fotos a Drive: $done de $total';
            _progress = total == 0 ? null : done / total;
          });
        }
      },
    );
    DriveUploadResult result;
    try {
      result = await upload();
    } on DriveException catch (e) {
      if (e.status != 401) rethrow;
      await ref.read(googleDriveAuthProvider).forget();
      result = await upload();
    }
    if (!mounted) return;
    await _message(
      'Listo en Google Drive',
      'Carpeta: $driveRootFolder › ${widget.project.name} › ${widget.season.name}\n\n'
          'Excel actualizado.\n'
          'Fotos subidas: ${result.uploadedPhotos}\n'
          'Fotos que ya estaban: ${result.skippedPhotos}'
          '${result.missingPhotos > 0 ? '\nFotos sin archivo en el teléfono: ${result.missingPhotos}' : ''}',
    );
  });

  Future<void> _importCsv() async {
    final path = await ref.read(fileSharerProvider).pickFile(['csv', 'txt']);
    if (path == null) return;
    await _run('Importando…', () async {
      final summary = await SeasonCsvImporter(
        ref.read(databaseProvider),
        ref.read(projectRepositoryProvider),
        ref.read(samplingRepositoryProvider),
        ref.read(measurementRepositoryProvider),
      ).import(widget.season.id, await File(path).readAsString());
      if (!mounted) return;
      await _message(
        'Importación',
        [
          'Registros importados: ${summary.imported}',
          if (summary.createdUnits.isNotEmpty) 'Unidades nuevas: ${summary.createdUnits.join(', ')}',
          if (summary.ignoredColumns.isNotEmpty) 'Columnas no reconocidas: ${summary.ignoredColumns.join(', ')}',
          if (summary.errors.isNotEmpty) '\nAvisos:\n${summary.errors.join('\n')}',
        ].join('\n'),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Exportar · ${widget.season.name}')),
      body: ListView(
        children: [
          if (_busy) ...[
            LinearProgressIndicator(value: _progress),
            Padding(padding: const EdgeInsets.all(12), child: Text(_status!)),
          ],
          const _Header('Compartir'),
          ListTile(
            leading: const Icon(Icons.table_chart_outlined),
            title: const Text('Planilla Excel de la temporada'),
            subtitle: const Text(
              'Registros, matriz de estadios, parámetros y escala. Envíala por correo, '
              'WhatsApp o guárdala en Drive.',
            ),
            enabled: !_busy,
            onTap: _shareExcel,
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Registros en CSV'),
            subtitle: const Text('Archivo de texto que abre cualquier planilla.'),
            enabled: !_busy,
            onTap: _shareCsv,
          ),
          const _Header('Google Drive personal'),
          ListTile(
            leading: const Icon(Icons.add_to_drive),
            title: const Text('Subir a mi Google Drive'),
            subtitle: const Text(
              'Excel y fotos ordenadas por semana en la carpeta «FramBitácora». '
              'Las fotos ya subidas no se repiten. Usa internet: mejor con Wi-Fi.',
            ),
            enabled: !_busy,
            onTap: _uploadDrive,
          ),
          const _Header('Importar'),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('Importar registros desde CSV'),
            subtitle: const Text(
              'Columnas: Semana (o Fecha), Unidad, Código estadio, Notas y mediciones. '
              'Es el mismo formato del CSV exportado. Se cargan en esta temporada.',
            ),
            enabled: !_busy,
            onTap: _importCsv,
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
    child: Text(
      text,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.primary),
    ),
  );
}
