import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/pdf_reports.dart';
import '../../data/season_analysis.dart';
import '../../data/season_data.dart';
import '../../data/season_tables.dart';
import '../../domain/measurement.dart';
import '../../domain/project_kind.dart';
import '../../domain/stats.dart';
import '../../providers.dart';
import '../common.dart';
import '../export/device_files.dart';

final seasonDataProvider = FutureProvider.autoDispose.family<SeasonData, String>(
  (ref, seasonId) => loadSeasonData(ref.watch(databaseProvider), seasonId),
);

Future<ReportFonts> loadReportFonts() async => ReportFonts(
  await rootBundle.load('assets/fonts/Roboto-Regular.ttf'),
  await rootBundle.load('assets/fonts/Roboto-Bold.ttf'),
);

/// Informes de una temporada: curva fenológica, matriz de estadios,
/// comparación estadística e informes PDF para compartir.
class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key, required this.project, required this.season, required this.week});
  final Project project;
  final Season season;

  /// Semana que se estaba mirando (para el informe semanal).
  final int week;

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  late GroupBy _groupBy = GroupBy.defaultFor(ProjectKind.fromName(widget.project.kind));
  bool _busy = false;

  Future<void> _sharePdf(String name, Future<Uint8List> Function(PdfReports r) build) async {
    setState(() => _busy = true);
    try {
      final reports = PdfReports(await loadReportFonts());
      await ref
          .read(fileSharerProvider)
          .shareBytes('$name.pdf', await build(reports), subject: 'FramBitácora · ${widget.project.name}');
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No se pudo crear el PDF: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String get _base => '${safeFileName(widget.project.name)}_${safeFileName(widget.season.name)}';

  Future<void> _pdfMenu(SeasonData d) async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(title: Text('Informe PDF')),
            ListTile(
              leading: const Icon(Icons.view_week_outlined),
              title: Text('Semanal · semana ${widget.week}'),
              subtitle: const Text('Estado, notas, mediciones y fotos de cada unidad'),
              onTap: () => Navigator.pop(context, 'week'),
            ),
            ListTile(
              leading: const Icon(Icons.timeline),
              title: const Text('Temporada completa'),
              subtitle: Text('Curva (${_groupBy.label.toLowerCase()}), matriz, mediciones y parámetros'),
              onTap: () => Navigator.pop(context, 'season'),
            ),
            if (d.usedVarieties.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.local_florist_outlined),
                title: const Text('Ficha por variedad'),
                onTap: () => Navigator.pop(context, 'variety'),
              ),
          ],
        ),
      ),
    );
    if (!mounted || choice == null) return;
    switch (choice) {
      case 'week':
        // En el navegador las fotos no están como archivo local.
        await _sharePdf('${_base}_S${widget.week}', (r) => r.weekly(d, widget.week, withPhotos: !kIsWeb));
      case 'season':
        await _sharePdf('${_base}_temporada', (r) => r.season(d, groupBy: _groupBy));
      case 'variety':
        final v = await showDialog<Variety>(
          context: context,
          builder: (context) => SimpleDialog(
            title: const Text('Variedad'),
            children: [
              for (final v in d.usedVarieties)
                SimpleDialogOption(onPressed: () => Navigator.pop(context, v), child: Text(v.name)),
            ],
          ),
        );
        if (v != null) await _sharePdf('${_base}_${safeFileName(v.name)}', (r) => r.varietySheet(d, v));
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(seasonDataProvider(widget.season.id));
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Informes · ${widget.season.name}'),
          actions: [
            if (data.value case final d?)
              IconButton(
                tooltip: 'Informe PDF',
                icon: const Icon(Icons.picture_as_pdf_outlined),
                onPressed: _busy ? null : () => _pdfMenu(d),
              ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Curva'),
              Tab(text: 'Matriz'),
              Tab(text: 'Comparar'),
            ],
          ),
        ),
        body: Column(
          children: [
            if (_busy) const LinearProgressIndicator(),
            Expanded(
              child: asyncView(
                data,
                (d) => TabBarView(
                  children: [
                    _CurveTab(data: d, groupBy: _groupBy, onGroupBy: (g) => setState(() => _groupBy = g)),
                    _MatrixTab(data: d),
                    _CompareTab(
                      data: d,
                      groupBy: _groupBy,
                      onGroupBy: (g) => setState(() => _groupBy = g),
                      onPdf: (title, result) =>
                          _sharePdf('${_base}_comparacion', (r) => r.comparison(d, title: title, result: result)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupByPicker extends StatelessWidget {
  const _GroupByPicker({required this.value, required this.onChanged});
  final GroupBy value;
  final ValueChanged<GroupBy> onChanged;

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<GroupBy>(
    initialValue: value,
    decoration: const InputDecoration(labelText: 'Agrupar por', border: OutlineInputBorder(), isDense: true),
    items: [for (final g in GroupBy.values) DropdownMenuItem(value: g, child: Text(g.label))],
    onChanged: (g) => onChanged(g!),
  );
}

class _CurveTab extends StatelessWidget {
  const _CurveTab({required this.data, required this.groupBy, required this.onGroupBy});
  final SeasonData data;
  final GroupBy groupBy;
  final ValueChanged<GroupBy> onGroupBy;

  @override
  Widget build(BuildContext context) {
    final curves = data.curves(groupBy);
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    if (curves.isEmpty) {
      return const EmptyState(icon: Icons.show_chart, message: 'Aún no hay estadios registrados en esta temporada.');
    }
    final weeks = [
      for (final c in curves)
        for (final p in c.points) p.week,
    ];
    final idx = [
      for (final c in curves)
        for (final p in c.points) p.stageIndex,
    ];
    final minX = weeks.reduce((a, b) => a < b ? a : b).toDouble();
    final maxX = weeks.reduce((a, b) => a > b ? a : b).toDouble();
    final minY = idx.reduce((a, b) => a < b ? a : b).floorToDouble();
    final maxY = idx.reduce((a, b) => a > b ? a : b).ceilToDouble();
    final yStep = ((maxY - minY) / 8).ceilToDouble().clamp(1, 100).toDouble();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _GroupByPicker(value: groupBy, onChanged: onGroupBy),
        const SizedBox(height: 16),
        SizedBox(
          height: 320,
          child: LineChart(
            LineChartData(
              minX: minX,
              maxX: maxX == minX ? minX + 1 : maxX,
              minY: minY,
              maxY: maxY == minY ? minY + 1 : maxY,
              gridData: FlGridData(
                horizontalInterval: yStep,
                verticalInterval: 1,
                getDrawingHorizontalLine: (_) => FlLine(color: scheme.outlineVariant, strokeWidth: 0.5),
                getDrawingVerticalLine: (_) => FlLine(color: scheme.outlineVariant, strokeWidth: 0.5),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(),
                rightTitles: const AxisTitles(),
                bottomTitles: AxisTitles(
                  axisNameWidget: Text('Semana', style: text.bodySmall),
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: ((maxX - minX) / 8).ceilToDouble().clamp(1, 100).toDouble(),
                    getTitlesWidget: (v, meta) => SideTitleWidget(
                      meta: meta,
                      child: Text('${v.toInt()}', style: text.bodySmall),
                    ),
                  ),
                ),
                leftTitles: AxisTitles(
                  axisNameWidget: Text('Estadio', style: text.bodySmall),
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    interval: yStep,
                    getTitlesWidget: (v, meta) {
                      final i = v.round();
                      if (i < 0 || i >= data.stages.length || v != v.roundToDouble()) return const SizedBox();
                      return SideTitleWidget(
                        meta: meta,
                        child: Text(data.stages[i].code, style: text.bodySmall),
                      );
                    },
                  ),
                ),
              ),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (spots) => [
                    for (final s in spots)
                      LineTooltipItem(
                        '${curves[s.barIndex].name}\nS${s.x.toInt()} · ${data.stages[s.y.round().clamp(0, data.stages.length - 1)].code}',
                        TextStyle(
                          color: Color(seriesColors[s.barIndex % seriesColors.length]),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
              lineBarsData: [
                for (final (i, c) in curves.indexed)
                  LineChartBarData(
                    spots: [for (final p in c.points) FlSpot(p.week.toDouble(), p.stageIndex)],
                    color: Color(seriesColors[i % seriesColors.length]),
                    barWidth: 2.5,
                    dotData: const FlDotData(show: true),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 6,
          children: [
            for (final (i, c) in curves.indexed)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 14, height: 4, color: Color(seriesColors[i % seriesColors.length])),
                  const SizedBox(width: 6),
                  Text(c.name),
                ],
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Cada línea muestra el estadio por semana. En grupos con varias unidades es el promedio de su posición en la escala.',
          style: text.bodySmall,
        ),
      ],
    );
  }
}

class _MatrixTab extends StatelessWidget {
  const _MatrixTab({required this.data});
  final SeasonData data;

  @override
  Widget build(BuildContext context) {
    final weeks = data.weeks;
    if (weeks.isEmpty || data.units.isEmpty) {
      return const EmptyState(icon: Icons.grid_on, message: 'Aún no hay registros en esta temporada.');
    }
    final text = Theme.of(context).textTheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Table(
          defaultColumnWidth: const FixedColumnWidth(44),
          columnWidths: const {0: IntrinsicColumnWidth()},
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(
              children: [
                const SizedBox(),
                for (final w in weeks)
                  Tooltip(
                    message: 'Desde el ${shortDate.format(data.weekStart(w))}',
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text('S$w', textAlign: TextAlign.center, style: text.labelMedium),
                    ),
                  ),
              ],
            ),
            for (final u in data.units)
              TableRow(
                children: [
                  Padding(padding: const EdgeInsets.only(right: 8), child: Text(u.label)),
                  for (final w in weeks)
                    Padding(
                      padding: const EdgeInsets.all(2),
                      child: Center(
                        child: data.notSampledWeeks.contains(w) && data.record(u.id, w)?.stage == null
                            ? Text('NM', style: text.labelSmall)
                            : StageBadge(
                                code: data.record(u.id, w)?.stage?.code,
                                color: data.record(u.id, w)?.stage?.color,
                                size: 34,
                              ),
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

/// Qué se compara.
enum _Variable { measurement, stage, weekReached }

class _CompareTab extends StatefulWidget {
  const _CompareTab({required this.data, required this.groupBy, required this.onGroupBy, required this.onPdf});
  final SeasonData data;
  final GroupBy groupBy;
  final ValueChanged<GroupBy> onGroupBy;
  final void Function(String title, ComparisonResult result) onPdf;

  @override
  State<_CompareTab> createState() => _CompareTabState();
}

class _CompareTabState extends State<_CompareTab> {
  late var _variable = widget.data.numericObservationDefs.isEmpty ? _Variable.weekReached : _Variable.measurement;
  late MeasurementDef? _def = widget.data.numericObservationDefs.firstOrNull;
  late int? _week = widget.data.weeks.lastOrNull;
  late PhenoStage? _stage =
      widget.data.stages.where((s) => s.code.startsWith('6')).firstOrNull ?? widget.data.stages.firstOrNull;

  SeasonData get d => widget.data;

  ({String title, List<Sample> samples})? get _selection {
    switch (_variable) {
      case _Variable.measurement:
        if (_def == null || _week == null) return null;
        return (title: '${_def!.name}, semana $_week', samples: d.measurementSamples(_def!, _week!, widget.groupBy));
      case _Variable.stage:
        if (_week == null) return null;
        return (title: 'Estadio en la semana $_week', samples: d.stageSamples(_week!, widget.groupBy));
      case _Variable.weekReached:
        if (_stage == null) return null;
        return (
          title: 'Semana en que se alcanzó ${_stage!.code} (${_stage!.name})',
          samples: d.weekReachedSamples(_stage!, widget.groupBy),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final sel = _selection;
    ComparisonResult? result;
    String? error;
    if (sel != null) {
      try {
        result = compareGroups(sel.samples);
      } on StatsException catch (e) {
        error = e.message;
      }
    }
    String n(double? x, [int dec = 2]) => x == null || x.isNaN
        ? '—'
        : x.isInfinite
        ? '∞'
        : formatNumber(double.parse(x.toStringAsFixed(dec)));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _GroupByPicker(value: widget.groupBy, onChanged: widget.onGroupBy),
        const SizedBox(height: 12),
        DropdownButtonFormField<_Variable>(
          initialValue: _variable,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Comparar', border: OutlineInputBorder(), isDense: true),
          items: [
            if (d.numericObservationDefs.isNotEmpty)
              const DropdownMenuItem(value: _Variable.measurement, child: Text('Una medición en una semana')),
            const DropdownMenuItem(value: _Variable.stage, child: Text('El estadio en una semana')),
            const DropdownMenuItem(value: _Variable.weekReached, child: Text('Semana en que se alcanzó un estadio')),
          ],
          onChanged: (v) => setState(() => _variable = v!),
        ),
        const SizedBox(height: 12),
        if (_variable == _Variable.measurement)
          DropdownButtonFormField<MeasurementDef>(
            initialValue: _def,
            decoration: const InputDecoration(labelText: 'Medición', border: OutlineInputBorder(), isDense: true),
            items: [for (final m in d.numericObservationDefs) DropdownMenuItem(value: m, child: Text(m.name))],
            onChanged: (m) => setState(() => _def = m),
          ),
        if (_variable != _Variable.weekReached && d.weeks.isNotEmpty) ...[
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            initialValue: _week,
            decoration: const InputDecoration(labelText: 'Semana', border: OutlineInputBorder(), isDense: true),
            items: [for (final w in d.weeks) DropdownMenuItem(value: w, child: Text('Semana $w'))],
            onChanged: (w) => setState(() => _week = w),
          ),
        ],
        if (_variable == _Variable.weekReached)
          DropdownButtonFormField<PhenoStage>(
            initialValue: _stage,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Estadio', border: OutlineInputBorder(), isDense: true),
            items: [
              for (final s in d.stages)
                DropdownMenuItem(
                  value: s,
                  child: Text('${s.code} · ${s.name}', overflow: TextOverflow.ellipsis),
                ),
            ],
            onChanged: (s) => setState(() => _stage = s),
          ),
        const SizedBox(height: 16),
        if (error != null) Text(error, style: TextStyle(color: Theme.of(context).colorScheme.error)),
        if (result case final r?) ...[
          Card(
            color: r.significant ? Theme.of(context).colorScheme.primaryContainer : null,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                r.significant
                    ? 'Hay diferencias significativas (p = ${n(r.groups.p, 4)}).'
                    : 'No hay diferencias significativas (p = ${n(r.groups.p, 4)}).',
                style: text.titleSmall,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text('Medias (letras distintas = diferencia significativa, LSD α = 0,05)', style: text.titleSmall),
          const SizedBox(height: 4),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(3),
              1: FlexColumnWidth(1),
              2: FlexColumnWidth(2),
              3: FlexColumnWidth(1.5),
            },
            children: [
              TableRow(
                children: [
                  for (final h in ['Grupo', 'n', 'Media', 'LSD']) Text(h, style: text.labelLarge),
                ],
              ),
              for (final m in r.means)
                TableRow(children: [Text(m.group), Text('${m.n}'), Text(n(m.mean)), Text(m.letters)]),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${r.blocked ? 'ANOVA en bloques (repeticiones)' : 'ANOVA de una vía'} · '
            'F = ${n(r.groups.f)} · CV = ${n(r.cv, 1)} %'
            '${r.lsd == null ? '' : ' · LSD = ${n(r.lsd, 3)}'}',
            style: text.bodySmall,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => widget.onPdf(sel!.title, r),
            icon: const Icon(Icons.picture_as_pdf_outlined),
            label: const Text('Compartir en PDF'),
          ),
        ],
      ],
    );
  }
}
