import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/database.dart';
import '../../domain/season_review.dart';
import '../../domain/season_weeks.dart';
import '../../providers.dart';
import '../app_icons.dart';
import '../common.dart';
import '../sampling/observation_screen.dart';

final _dayMonth = DateFormat('d/M', 'es');

const _cell = 40.0;
const _gap = 3.0;
const _labelWidth = 116.0;
const _rowHeight = _cell + _gap * 2;

/// Avance fenológico de toda la temporada: unidades × semanas con el color de cada
/// estado y alertas de posibles errores. Tocar una celda abre ese registro para
/// corregirlo, así el informe sale bien a la primera.
class SeasonReviewScreen extends ConsumerStatefulWidget {
  const SeasonReviewScreen({super.key, required this.project, required this.season});
  final Project project;
  final Season season;

  @override
  ConsumerState<SeasonReviewScreen> createState() => _SeasonReviewScreenState();
}

class _SeasonReviewScreenState extends ConsumerState<SeasonReviewScreen> {
  bool _onlyAlerts = false;
  ScrollController? _horizontal;

  int get _currentWeek => seasonWeekFor(ref.read(todayProvider), widget.season.week1Start).clamp(1, 1 << 30);

  @override
  void dispose() {
    _horizontal?.dispose();
    super.dispose();
  }

  void _open(Unit unit, int week) => Navigator.push(
    context,
    MaterialPageRoute<void>(
      builder: (_) => ObservationScreen(project: widget.project, season: widget.season, unit: unit, week: week),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final grid = ref.watch(seasonGridProvider((projectId: widget.project.id, seasonId: widget.season.id)));
    return Scaffold(
      appBar: AppBar(title: const Text('Avance de la temporada')),
      body: asyncView(grid, (g) {
        final current = _currentWeek;
        final last = g.lastWeekWithData > current ? g.lastWeekWithData : current;
        final weeks = [for (var w = 1; w <= last; w++) w];
        // Al abrir, la grilla se muestra con la semana actual a la vista.
        _horizontal ??= ScrollController(initialScrollOffset: ((current - 5) * (_cell + _gap * 2)).clamp(0, 1e9));
        final alerts = g.alerts;
        final alertCells = {for (final a in alerts) (a.unitId, a.week)};
        final units = _onlyAlerts ? g.units.where((u) => alerts.any((a) => a.unitId == u.id)).toList() : g.units;

        return ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            _Summary(
              project: widget.project,
              season: widget.season,
              alerts: alerts.length,
              onlyAlerts: _onlyAlerts,
              onToggle: alerts.isEmpty ? null : (v) => setState(() => _onlyAlerts = v),
            ),
            if (g.units.isEmpty)
              const Padding(padding: EdgeInsets.all(24), child: Text('Este proyecto aún no tiene unidades.'))
            else
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Columna fija con el nombre de cada unidad.
                      SizedBox(
                        width: _labelWidth,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: _rowHeight),
                            for (final u in units)
                              SizedBox(
                                height: _rowHeight,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 16, right: 6),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      u.label,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context).textTheme.labelLarge,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: _horizontal,
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(right: 12),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  for (final w in weeks)
                                    _WeekHeader(week: w, season: widget.season, current: w == current),
                                ],
                              ),
                              for (final u in units)
                                Row(
                                  children: [
                                    for (final w in weeks)
                                      _Cell(
                                        cell: g.cells[u.id]?[w],
                                        notSampled: g.notSampled.contains(w),
                                        current: w == current,
                                        alert: alertCells.contains((u.id, w)),
                                        semantic: '${u.label}, semana $w',
                                        onTap: () => _open(u, w),
                                      ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (alerts.isNotEmpty) ...[
              const SectionHeader('Posibles errores'),
              SettingsGroup(
                children: [
                  for (final a in alerts)
                    ListTile(
                      leading: Icon(switch (a.kind) {
                        AlertKind.regression => Icons.trending_down,
                        AlertKind.noPhoto => Icons.no_photography_outlined,
                        AlertKind.noStage => Icons.help_outline,
                      }, color: Theme.of(context).colorScheme.error),
                      title: Text(a.message),
                      subtitle: Text(a.kind.label),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _open(g.units.firstWhere((u) => u.id == a.unitId), a.week),
                    ),
                ],
              ),
            ],
            const SectionHeader('Cómo leerla'),
            const Padding(
              padding: EdgeInsets.fromLTRB(28, 0, 24, 0),
              child: Text(
                'Cada celda es una semana con el color y código del estado. Toca una celda para abrir ese '
                'registro y corregirlo. El punto rojo marca un posible error; «NM» es una semana no '
                'muestreada. Los cambios se ven al tiro aquí y en los informes.',
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({
    required this.project,
    required this.season,
    required this.alerts,
    required this.onlyAlerts,
    required this.onToggle,
  });
  final Project project;
  final Season season;
  final int alerts;
  final bool onlyAlerts;
  final ValueChanged<bool>? onToggle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final ok = alerts == 0;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
      decoration: BoxDecoration(
        color: ok ? scheme.primaryContainer : scheme.errorContainer,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            project.name,
            style: text.titleLarge?.copyWith(color: ok ? scheme.onPrimaryContainer : scheme.onErrorContainer),
          ),
          Text('Temporada ${season.name}', style: text.bodyMedium),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(ok ? Icons.check_circle : Icons.error_outline, color: ok ? scheme.primary : scheme.error),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  ok
                      ? 'Sin posibles errores: lista para el informe'
                      : alerts == 1
                      ? '1 posible error para revisar'
                      : '$alerts posibles errores para revisar',
                  style: text.titleSmall,
                ),
              ),
            ],
          ),
          if (onToggle != null)
            Row(
              children: [
                const Expanded(child: Text('Mostrar solo unidades con alertas')),
                Switch(value: onlyAlerts, onChanged: onToggle),
              ],
            )
          else
            const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _WeekHeader extends StatelessWidget {
  const _WeekHeader({required this.week, required this.season, required this.current});
  final int week;
  final Season season;
  final bool current;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final style = Theme.of(context).textTheme.labelSmall;
    return Container(
      width: _cell,
      height: _rowHeight - _gap,
      margin: const EdgeInsets.symmetric(horizontal: _gap),
      decoration: BoxDecoration(color: current ? scheme.primary : null, borderRadius: BorderRadius.circular(10)),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'S$week',
            style: style?.copyWith(fontWeight: FontWeight.w700, color: current ? scheme.onPrimary : null),
          ),
          Text(
            _dayMonth.format(seasonWeekStart(week, season.week1Start)),
            style: style?.copyWith(fontSize: 9, color: current ? scheme.onPrimary : scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({
    required this.cell,
    required this.notSampled,
    required this.current,
    required this.alert,
    required this.semantic,
    required this.onTap,
  });
  final GridCell? cell;
  final bool notSampled;
  final bool current;
  final bool alert;
  final String semantic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final c = cell;
    final color = c?.stageColor == null ? null : Color(c!.stageColor!);
    final onColor = color == null
        ? scheme.onSurfaceVariant
        : (color.computeLuminance() > 0.45 ? Colors.black87 : Colors.white);
    final label = c?.stageCode ?? (notSampled ? 'NM' : (c != null ? '?' : ''));
    return Padding(
      padding: const EdgeInsets.all(_gap),
      child: Semantics(
        button: true,
        label: c?.stageName == null ? semantic : '$semantic, ${c!.stageName}',
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: _cell,
                height: _cell,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color ?? (notSampled ? scheme.surfaceContainerHighest : null),
                  borderRadius: BorderRadius.circular(10),
                  border: color == null
                      ? Border.all(color: current ? scheme.primary : scheme.outlineVariant, width: current ? 2 : 1)
                      : (current ? Border.all(color: scheme.primary, width: 2) : null),
                ),
                child: Text(
                  label,
                  style: TextStyle(color: onColor, fontWeight: FontWeight.w700, fontSize: label.length > 2 ? 10 : 12),
                ),
              ),
              if (alert)
                Positioned(
                  right: -3,
                  top: -3,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: scheme.error,
                      shape: BoxShape.circle,
                      border: Border.all(color: scheme.surface, width: 2),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Botón para abrir la revisión de la temporada desde otras pantallas.
class SeasonReviewButton extends StatelessWidget {
  const SeasonReviewButton({super.key, required this.project, required this.season});
  final Project project;
  final Season season;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: 'Avance de la temporada',
    icon: const AppIcon(AppIcons.season),
    onPressed: () => Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => SeasonReviewScreen(project: project, season: season),
      ),
    ),
  );
}
