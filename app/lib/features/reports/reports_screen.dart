import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../../data/database.dart';
import '../../providers.dart';
import '../../reports/pdf_reports.dart';
import '../app_icons.dart';
import '../common.dart';

/// Cómo se muestra un PDF ya armado (se reemplaza en las pruebas, donde no hay
/// visor de PDF del sistema).
final pdfViewerProvider = Provider<Widget Function(Uint8List pdf, String fileName)>(
  (ref) =>
      (pdf, fileName) => PdfPreview(
        build: (_) => pdf,
        initialPageFormat: PdfPageFormat.letter,
        pdfFileName: fileName,
        canChangePageFormat: false,
        canChangeOrientation: false,
        canDebug: false,
        allowPrinting: true,
        allowSharing: true,
        loadingWidget: const Center(child: CircularProgressIndicator()),
      ),
);

/// Nombre de archivo seguro: sin tildes, espacios ni símbolos.
String reportFileName(String kind, String project, String suffix) {
  const from = 'áéíóúüñÁÉÍÓÚÜÑ';
  const to = 'aeiouunAEIOUUN';
  var name = project;
  for (var i = 0; i < from.length; i++) {
    name = name.replaceAll(from[i], to[i]);
  }
  name = name.replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_').replaceAll(RegExp(r'^_+|_+$'), '');
  return '${kind}_${name}_$suffix.pdf';
}

/// Menú de informes de un proyecto.
Future<void> showReportsSheet(
  BuildContext context, {
  required Project project,
  required Season season,
  required int week,
  required int currentWeek,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  builder: (_) => _ReportsSheet(project: project, season: season, week: week, currentWeek: currentWeek),
);

class _ReportsSheet extends ConsumerStatefulWidget {
  const _ReportsSheet({required this.project, required this.season, required this.week, required this.currentWeek});
  final Project project;
  final Season season;
  final int week;
  final int currentWeek;

  @override
  ConsumerState<_ReportsSheet> createState() => _ReportsSheetState();
}

class _ReportsSheetState extends ConsumerState<_ReportsSheet> {
  bool _photos = true;
  int _perKind = 1;

  void _open(String title, String fileName, Future<Uint8List> Function(WidgetRef ref) generate) {
    final navigator = Navigator.of(context);
    navigator.pop();
    navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => ReportPreviewScreen(title: title, fileName: fileName, generate: generate),
      ),
    );
  }

  void _weekly() {
    final p = widget.project, s = widget.season, week = widget.week;
    final photos = _photos, perKind = _perKind;
    _open('Informe semanal · Semana $week', reportFileName('Informe_semanal', p.name, 'S$week'), (ref) async {
      final assets = await ref.read(reportAssetsProvider.future);
      final report = await ref
          .read(reportRepositoryProvider)
          .weekly(
            projectId: p.id,
            seasonId: s.id,
            week: week,
            includePhotos: photos,
            maxPhotosPerKind: perKind,
            shrink: ref.read(photoShrinkerProvider),
          );
      return buildWeeklyPdfInIsolate(report, assets);
    });
  }

  void _matrix() {
    final p = widget.project, s = widget.season, current = widget.currentWeek;
    _open('Matriz de la temporada', reportFileName('Matriz', p.name, s.name), (ref) async {
      final assets = await ref.read(reportAssetsProvider.future);
      final report = await ref
          .read(reportRepositoryProvider)
          .matrix(projectId: p.id, seasonId: s.id, currentWeek: current);
      return buildMatrixPdfInIsolate(report, assets);
    });
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Text('Informes en PDF', style: text.titleLarge),
            ),
            SettingsGroup(
              children: [
                ListTile(
                  leading: const IconBadge.app(AppIcons.report, size: 40),
                  title: Text('Informe semanal · Semana ${widget.week}'),
                  subtitle: const Text('Avance fenológico por unidad y fotos de la semana'),
                ),
                SwitchListTile(
                  title: const Text('Incluir fotos'),
                  subtitle: const Text('General y de detalle de cada unidad'),
                  value: _photos,
                  onChanged: (v) => setState(() => _photos = v),
                ),
                if (_photos)
                  ListTile(
                    title: const Text('Fotos por tipo'),
                    trailing: SegmentedButton<int>(
                      segments: const [
                        ButtonSegment(value: 1, label: Text('1')),
                        ButtonSegment(value: 2, label: Text('2')),
                      ],
                      selected: {_perKind},
                      onSelectionChanged: (v) => setState(() => _perKind = v.first),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  child: FilledButton.icon(
                    onPressed: _weekly,
                    icon: const AppIcon(AppIcons.report),
                    label: const Text('Generar informe semanal'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SettingsGroup(
              children: [
                ListTile(
                  leading: const IconBadge.app(AppIcons.week, size: 40),
                  title: const Text('Matriz de la temporada'),
                  subtitle: Text('Estado de cada unidad en cada semana · temporada ${widget.season.name}'),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  child: FilledButton.tonalIcon(
                    onPressed: _matrix,
                    icon: const AppIcon(AppIcons.week),
                    label: const Text('Generar matriz'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Arma el informe y lo muestra con zoom, páginas, compartir e imprimir.
class ReportPreviewScreen extends ConsumerStatefulWidget {
  const ReportPreviewScreen({super.key, required this.title, required this.fileName, required this.generate});
  final String title;
  final String fileName;
  final Future<Uint8List> Function(WidgetRef ref) generate;

  @override
  ConsumerState<ReportPreviewScreen> createState() => _ReportPreviewScreenState();
}

class _ReportPreviewScreenState extends ConsumerState<ReportPreviewScreen> {
  late final Future<Uint8List> _pdf = widget.generate(ref);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: FutureBuilder<Uint8List>(
        future: _pdf,
        builder: (context, snap) {
          if (snap.hasError) {
            return EmptyState(icon: Icons.error_outline, message: 'No se pudo armar el informe.\n${snap.error}');
          }
          if (!snap.hasData) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Armando el informe…'),
                  SizedBox(height: 4),
                  Text('Con muchas fotos puede tardar unos segundos.'),
                ],
              ),
            );
          }
          return ref.read(pdfViewerProvider)(snap.data!, widget.fileName);
        },
      ),
    );
  }
}
