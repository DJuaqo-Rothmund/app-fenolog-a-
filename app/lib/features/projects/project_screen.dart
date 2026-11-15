import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/sampling_repository.dart';
import '../../domain/completeness.dart';
import '../../domain/project_kind.dart';
import '../../domain/season_weeks.dart';
import '../../providers.dart';
import '../app_icons.dart';
import '../common.dart';
import '../reports/reports_screen.dart';
import '../review/season_review_screen.dart';
import '../sampling/observation_screen.dart';
import '../settings/project_settings_screen.dart';
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

  int _currentWeek(Season s) => seasonWeekFor(ref.read(todayProvider), s.week1Start).clamp(1, 1 << 30);

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
    final season = ref.watch(currentSeasonProvider(widget.projectId));

    return asyncView(project, (p) {
      return Scaffold(
        appBar: AppBar(
          title: Text(p.name),
          actions: [
            if (season.value case final s?) SeasonReviewButton(project: p, season: s),
            if (season.value case final s?)
              IconButton(
                tooltip: 'Informes',
                icon: const AppIcon(AppIcons.report),
                onPressed: () => showReportsSheet(
                  context,
                  project: p,
                  season: s,
                  week: _week ?? _currentWeek(s),
                  currentWeek: _currentWeek(s),
                ),
              ),
            IconButton(
              tooltip: 'Configurar proyecto',
              icon: const AppIcon(AppIcons.settings),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(builder: (_) => ProjectSettingsScreen(projectId: p.id)),
              ),
            ),
          ],
        ),
        // En los ensayos de tratamientos las unidades salen del diseño (Configuración).
        floatingActionButton: ProjectKind.fromName(p.kind) == ProjectKind.treatmentTrial
            ? null
            : FloatingActionButton.extended(
                onPressed: () => showUnitForm(context, project: p),
                icon: const Icon(Icons.add),
                label: const Text('Unidad'),
              ),
        body: asyncView(season, (s) {
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
    // Descripción de cada tratamiento (dosis, producto…) para mostrarla en terreno.
    final treatmentInfo = {
      for (final t in ref.watch(treatmentsProvider(project.id)).value ?? const <Treatment>[])
        if (t.description.isNotEmpty) t.code: t.description,
    };
    final notSampled = ref.watch(weekNotSampledProvider((seasonId: season.id, week: week))).value ?? false;
    final start = seasonWeekStart(week, season.week1Start);
    final iso = isoWeek(start);
    final text = Theme.of(context).textTheme;

    final scheme = Theme.of(context).colorScheme;
    final onHeader = scheme.onPrimaryContainer;

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
          decoration: BoxDecoration(color: scheme.primaryContainer, borderRadius: BorderRadius.circular(28)),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Semana $week', style: text.headlineSmall?.copyWith(color: onHeader)),
                        const SizedBox(height: 2),
                        Text(
                          'Desde el ${shortDate.format(start)} · semana ${iso.week} del año ${iso.year}',
                          style: text.bodySmall?.copyWith(color: onHeader),
                        ),
                        Text('Temporada ${season.name}', style: text.bodySmall?.copyWith(color: onHeader)),
                      ],
                    ),
                  ),
                  asyncView(
                    rows,
                    (list) => _ProgressRing(
                      progress: WeekProgress(complete: list.where((r) => r.isComplete).length, total: list.length),
                      notSampled: notSampled,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton.filledTonal(
                    tooltip: 'Semana anterior',
                    onPressed: week > 1 ? () => onWeekChanged(week - 1) : null,
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        asyncView(
                          rows,
                          (list) => _ProgressLabel(
                            progress: WeekProgress(
                              complete: list.where((r) => r.isComplete).length,
                              total: list.length,
                            ),
                            notSampled: notSampled,
                          ),
                        ),
                        if (week != currentWeek)
                          TextButton.icon(
                            onPressed: () => onWeekChanged(currentWeek),
                            icon: const Icon(Icons.today),
                            label: const Text('Ir a la semana actual'),
                          ),
                      ],
                    ),
                  ),
                  IconButton.filledTonal(
                    tooltip: 'Semana siguiente',
                    onPressed: () => onWeekChanged(week + 1),
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
              Row(
                children: [
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text('Semana no muestreada', style: text.bodyMedium?.copyWith(color: onHeader)),
                  ),
                  Switch(
                    value: notSampled,
                    onChanged: (v) => ref.read(samplingRepositoryProvider).setWeekNotSampled(season.id, week, v),
                  ),
                ],
              ),
            ],
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
              padding: const EdgeInsets.only(top: 4, bottom: 96),
              itemCount: list.length,
              itemBuilder: (_, i) => _UnitTile(
                row: list[i],
                info: treatmentInfo[list[i].unit.treatment],
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

/// Anillo con el avance de la semana (registros completos / total).
class _ProgressRing extends StatelessWidget {
  const _ProgressRing({required this.progress, required this.notSampled});
  final WeekProgress progress;
  final bool notSampled;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 68,
      height: 68,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: notSampled ? 0 : progress.fraction,
            strokeWidth: 7,
            strokeCap: StrokeCap.round,
            backgroundColor: scheme.surface.withValues(alpha: 0.6),
            color: progress.isDone ? scheme.secondary : scheme.primary,
          ),
          Center(
            child: notSampled
                ? Icon(Icons.block, color: scheme.onPrimaryContainer)
                : progress.isDone
                ? Icon(Icons.celebration, color: scheme.secondary)
                : Text(
                    '${progress.complete}/${progress.total}',
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(color: scheme.onPrimaryContainer, fontWeight: FontWeight.w700),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ProgressLabel extends StatelessWidget {
  const _ProgressLabel({required this.progress, required this.notSampled});
  final WeekProgress progress;
  final bool notSampled;

  @override
  Widget build(BuildContext context) {
    final label = notSampled
        ? 'Semana marcada como no muestreada'
        : progress.isDone
        ? '¡Semana completa! ${progress.complete} de ${progress.total} registros'
        : '${progress.complete} de ${progress.total} registros completos';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelLarge
            ?.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer),
      ),
    );
  }
}

class _UnitTile extends StatelessWidget {
  const _UnitTile({required this.row, required this.onTap, required this.onLongPress, this.info});
  final UnitWeekRow row;

  /// Descripción del tratamiento, si tiene.
  final String? info;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final stage = row.stageName == null ? 'Sin estado' : '${row.stageCode} · ${row.stageName}';
    final photos = row.photoCount == 1 ? '1 foto' : '${row.photoCount} fotos';
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(12, 6, 16, 6),
        leading: StageBadge(code: row.stageCode, color: row.stageColor, size: 44),
        title: Text(info == null ? row.unit.label : '${row.unit.label} · $info', overflow: TextOverflow.ellipsis),
        subtitle: Text('$stage · $photos'),
        trailing: row.isComplete
            ? Icon(Icons.check_circle, color: scheme.primary, semanticLabel: 'Completo')
            : Icon(Icons.radio_button_unchecked, color: scheme.outline, semanticLabel: 'Pendiente'),
        onTap: onTap,
        onLongPress: onLongPress,
      ),
    );
  }
}
