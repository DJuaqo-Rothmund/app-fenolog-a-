import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/sampling_repository.dart';
import '../../domain/completeness.dart';
import '../../domain/project_kind.dart';
import '../../domain/season_weeks.dart';
import '../../providers.dart';
import '../common.dart';
import '../export/export_screen.dart';
import '../measurements/measurement_defs_screen.dart';
import '../measurements/variety_params_screen.dart';
import '../reports/reports_screen.dart';
import '../sampling/observation_screen.dart';
import 'unit_form.dart';

/// Un proyecto: navegación por semanas y lista de unidades con su estado.
class ProjectScreen extends ConsumerStatefulWidget {
  const ProjectScreen({super.key, required this.projectId});
  final String projectId;

  @override
  ConsumerState<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends ConsumerState<ProjectScreen> {
  int? _week;
  String? _seasonId;

  int _currentWeek(Season s) => seasonWeekFor(ref.read(todayProvider), s.week1Start).clamp(1, 1 << 30);

  /// Pide nombre y semana 1 de una temporada. Devuelve nulo si se cancela.
  Future<({String name, DateTime week1})?> _seasonDialog(
    String title,
    String initialName,
    DateTime initialWeek1,
  ) async {
    final name = TextEditingController(text: initialName);
    var week1 = initialWeek1;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialog) => AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Semana 1 desde'),
                subtitle: Text(longDate.format(week1)),
                trailing: const Icon(Icons.edit_calendar),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: week1,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setDialog(() => week1 = mondayOf(picked));
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Guardar')),
          ],
        ),
      ),
    );
    final text = name.text.trim();
    disposeAfterClose([name]);
    return ok == true && text.isNotEmpty ? (name: text, week1: week1) : null;
  }

  Future<void> _editSeason(Season season) async {
    final r = await _seasonDialog('Temporada', season.name, season.week1Start);
    if (r != null) await ref.read(projectRepositoryProvider).updateSeason(season.id, name: r.name, week1Start: r.week1);
  }

  Future<void> _newSeason(Project project) async {
    final crop = await ref.read(cropProvider(project.cropId).future);
    final week1 = defaultWeek1Start(ref.read(todayProvider), crop.seasonStartMonth, crop.seasonStartDay);
    if (!mounted) return;
    final r = await _seasonDialog('Nueva temporada', defaultSeasonName(week1), week1);
    if (r == null) return;
    final id = await ref
        .read(projectRepositoryProvider)
        .createSeason(projectId: project.id, name: r.name, week1Start: r.week1);
    setState(() {
      _seasonId = id;
      _week = null;
    });
  }

  Future<void> _pickSeason(List<Season> seasons, Season current) async {
    final picked = await showDialog<Season>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Temporada'),
        children: [
          for (final s in seasons)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, s),
              child: Row(
                children: [
                  Icon(s.id == current.id ? Icons.radio_button_checked : Icons.radio_button_unchecked, size: 20),
                  const SizedBox(width: 12),
                  Text(s.name),
                ],
              ),
            ),
        ],
      ),
    );
    if (picked != null && picked.id != current.id) {
      setState(() {
        _seasonId = picked.id;
        _week = null;
      });
    }
  }

  void _open(Widget screen) => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => screen));

  Future<void> _unitActions(Project project, Unit unit) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: Text(unit.label, style: Theme.of(context).textTheme.titleMedium)),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Editar unidad'),
              onTap: () => Navigator.pop(context, 'edit'),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Eliminar unidad'),
              onTap: () => Navigator.pop(context, 'delete'),
            ),
          ],
        ),
      ),
    );
    if (!mounted) return;
    if (action == 'edit') {
      await showUnitForm(context, project: project, unit: unit);
    } else if (action == 'delete' &&
        await confirm(
          context,
          title: 'Eliminar unidad',
          message: '«${unit.label}» dejará de aparecer. Sus registros anteriores se conservan.',
        )) {
      await ref.read(projectRepositoryProvider).deleteUnit(unit.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final project = ref.watch(projectProvider(widget.projectId));
    final seasons = ref.watch(seasonsProvider(widget.projectId));
    final seasonList = seasons.value ?? const <Season>[];
    final season = seasonList.where((s) => s.id == _seasonId).firstOrNull ?? seasonList.firstOrNull;

    return asyncView(project, (p) {
      return Scaffold(
        appBar: AppBar(
          title: Text(p.name),
          actions: [
            PopupMenuButton<String>(
              onSelected: (v) async {
                final s = season;
                switch (v) {
                  case 'measurements':
                    _open(MeasurementDefsScreen(projectId: p.id));
                  case 'reports' when s != null:
                    _open(ReportsScreen(project: p, season: s, week: _week ?? _currentWeek(s)));
                  case 'export' when s != null:
                    _open(ExportScreen(project: p, season: s));
                  case 'params' when s != null:
                    _open(VarietyParamsScreen(project: p, season: s));
                  case 'pick-season' when s != null:
                    await _pickSeason(seasonList, s);
                  case 'new-season':
                    await _newSeason(p);
                  case 'season' when s != null:
                    await _editSeason(s);
                  case 'archive':
                    await ref.read(projectRepositoryProvider).setProjectArchived(p.id, !p.archived);
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'reports', child: Text('Informes y gráficos')),
                const PopupMenuItem(value: 'export', child: Text('Exportar, Drive e importar')),
                const PopupMenuDivider(),
                const PopupMenuItem(value: 'measurements', child: Text('Mediciones')),
                const PopupMenuItem(value: 'params', child: Text('Parámetros por variedad')),
                const PopupMenuDivider(),
                if (seasonList.length > 1) const PopupMenuItem(value: 'pick-season', child: Text('Cambiar temporada')),
                const PopupMenuItem(value: 'new-season', child: Text('Nueva temporada')),
                const PopupMenuItem(value: 'season', child: Text('Editar temporada')),
                const PopupMenuDivider(),
                PopupMenuItem(value: 'archive', child: Text(p.archived ? 'Desarchivar proyecto' : 'Archivar proyecto')),
              ],
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => showUnitForm(context, project: p),
          icon: const Icon(Icons.add),
          label: const Text('Unidad'),
        ),
        body: asyncView(seasons, (_) {
          final s = season;
          if (s == null) return const EmptyState(icon: Icons.event_busy, message: 'Este proyecto no tiene temporada.');
          final week = _week ?? _currentWeek(s);
          return _WeekView(
            project: p,
            season: s,
            week: week,
            currentWeek: _currentWeek(s),
            onWeekChanged: (w) => setState(() => _week = w),
            onUnitLongPress: (u) => _unitActions(p, u),
          );
        }),
      );
    });
  }
}

class _WeekView extends ConsumerWidget {
  const _WeekView({
    required this.project,
    required this.season,
    required this.week,
    required this.currentWeek,
    required this.onWeekChanged,
    required this.onUnitLongPress,
  });
  final Project project;
  final Season season;
  final int week;
  final int currentWeek;
  final ValueChanged<int> onWeekChanged;
  final ValueChanged<Unit> onUnitLongPress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rows = ref.watch(weekRowsProvider((projectId: project.id, seasonId: season.id, week: week)));
    final notSampled = ref.watch(weekNotSampledProvider((seasonId: season.id, week: week))).value ?? false;
    final start = seasonWeekStart(week, season.week1Start);
    final iso = isoWeek(start);
    final text = Theme.of(context).textTheme;

    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 12),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      tooltip: 'Semana anterior',
                      onPressed: week > 1 ? () => onWeekChanged(week - 1) : null,
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text('Semana $week', style: text.titleLarge),
                          Text(
                            'Semana ${iso.week} del año ${iso.year} · desde el ${shortDate.format(start)}',
                            style: text.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                          Text('Temporada ${season.name}', style: text.bodySmall),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Semana siguiente',
                      onPressed: () => onWeekChanged(week + 1),
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
                if (week != currentWeek)
                  TextButton.icon(
                    onPressed: () => onWeekChanged(currentWeek),
                    icon: const Icon(Icons.today),
                    label: const Text('Ir a la semana actual'),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: asyncView(
                    rows,
                    (list) => _Progress(
                      progress: WeekProgress(complete: list.where((r) => r.isComplete).length, total: list.length),
                      notSampled: notSampled,
                    ),
                  ),
                ),
                SwitchListTile(
                  dense: true,
                  title: const Text('Semana no muestreada'),
                  value: notSampled,
                  onChanged: (v) => ref.read(samplingRepositoryProvider).setWeekNotSampled(season.id, week, v),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: asyncView(rows, (list) {
            if (list.isEmpty) {
              return EmptyState(
                icon: Icons.add_location_alt_outlined,
                message:
                    'Agrega las unidades del proyecto con el botón «Unidad».\n'
                    '${ProjectKind.fromName(project.kind).help}.',
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.only(bottom: 88),
              itemCount: list.length,
              itemBuilder: (_, i) => _UnitTile(
                row: list[i],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => ObservationScreen(project: project, season: season, unit: list[i].unit, week: week),
                  ),
                ),
                onLongPress: () => onUnitLongPress(list[i].unit),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress({required this.progress, required this.notSampled});
  final WeekProgress progress;
  final bool notSampled;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final label = notSampled
        ? 'Semana marcada como no muestreada'
        : progress.isDone
        ? '¡Semana completa! ${progress.complete} de ${progress.total} registros'
        : '${progress.complete} de ${progress.total} registros completos';
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: notSampled ? 0 : progress.fraction,
            minHeight: 10,
            color: progress.isDone ? scheme.secondary : scheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (progress.isDone && !notSampled) Icon(Icons.celebration, size: 18, color: scheme.secondary),
            const SizedBox(width: 4),
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ],
    );
  }
}

class _UnitTile extends StatelessWidget {
  const _UnitTile({required this.row, required this.onTap, required this.onLongPress});
  final UnitWeekRow row;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final stage = row.stageName == null ? 'Sin estado' : '${row.stageCode} · ${row.stageName}';
    final photos = row.photoCount == 1 ? '1 foto' : '${row.photoCount} fotos';
    return ListTile(
      leading: StageBadge(code: row.stageCode, color: row.stageColor),
      title: Text(row.unit.label),
      subtitle: Text('$stage · $photos'),
      trailing: row.isComplete
          ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary, semanticLabel: 'Completo')
          : const Icon(Icons.radio_button_unchecked, semanticLabel: 'Pendiente'),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }
}
