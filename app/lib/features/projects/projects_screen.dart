import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/database.dart';
import '../../domain/completeness.dart';
import '../../domain/project_kind.dart';
import '../../domain/season_weeks.dart';
import '../../providers.dart';
import '../app_icons.dart';
import '../common.dart';
import '../drive/auto_sync.dart';
import '../drive/drive_screen.dart';
import '../settings/settings_screen.dart';
import 'project_form_screen.dart';
import 'project_screen.dart';

final _today = DateFormat("EEEE d 'de' MMMM", 'es');

/// Ícono y colores de cada tipo de proyecto.
({AppIcons icon, Color background, Color foreground}) kindStyle(BuildContext context, ProjectKind kind) {
  final s = Theme.of(context).colorScheme;
  return switch (kind) {
    ProjectKind.varietyTrial => (
      icon: AppIcons.variety,
      background: s.primaryContainer,
      foreground: s.onPrimaryContainer,
    ),
    ProjectKind.treatmentTrial => (
      icon: AppIcons.treatment,
      background: s.tertiaryContainer,
      foreground: s.onTertiaryContainer,
    ),
    ProjectKind.farm => (icon: AppIcons.farm, background: s.secondaryContainer, foreground: s.onSecondaryContainer),
  };
}

/// Pantalla de inicio: lista de proyectos (ensayos y predios).
class ProjectsScreen extends ConsumerStatefulWidget {
  const ProjectsScreen({super.key});

  @override
  ConsumerState<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends ConsumerState<ProjectsScreen> {
  bool _grid = false;

  void _openProject(Project p) =>
      Navigator.push(context, MaterialPageRoute<void>(builder: (_) => ProjectScreen(projectId: p.id)));

  @override
  Widget build(BuildContext context) {
    final projects = ref.watch(projectsProvider);
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final today = _today.format(ref.watch(todayProvider));

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: _grid ? 'Ver como lista' : 'Ver como cuadrícula',
            icon: Icon(_grid ? Icons.view_agenda_outlined : Icons.grid_view_outlined),
            onPressed: () => setState(() => _grid = !_grid),
          ),
          IconButton(
            tooltip: 'Configuración',
            icon: const AppIcon(AppIcons.settings),
            onPressed: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const SettingsScreen())),
          ),
          const SizedBox(width: 4),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const ProjectFormScreen())),
        icon: const Icon(Icons.add),
        label: const Text('Proyecto'),
      ),
      body: asyncView(projects, (list) {
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const AppLogo(size: 52),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('FramBitácora', style: text.headlineMedium),
                              Text(
                                '${today[0].toUpperCase()}${today.substring(1)}',
                                style: text.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (list.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: kIsWeb
                    // En la web, los datos llegan desde el teléfono a través de Drive.
                    ? const _WebEmptyState()
                    : const EmptyState(
                        icon: Icons.eco_outlined,
                        illustration: EmptyIllustration(),
                        message: 'Aún no hay proyectos.\nCrea un ensayo o un predio con el botón «Proyecto».',
                      ),
              )
            else if (_grid)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 96),
                sliver: SliverGrid.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 220,
                    childAspectRatio: 0.95,
                  ),
                  itemCount: list.length,
                  itemBuilder: (_, i) =>
                      _ProjectCard(project: list[i], onTap: () => _openProject(list[i]), compact: true),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.only(bottom: 96),
                sliver: SliverList.builder(
                  itemCount: list.length,
                  itemBuilder: (_, i) => _ProjectCard(project: list[i], onTap: () => _openProject(list[i])),
                ),
              ),
          ],
        );
      }),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.project, required this.onTap, this.compact = false});
  final Project project;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final kind = ProjectKind.fromName(project.kind);
    final style = kindStyle(context, kind);
    final text = Theme.of(context).textTheme;
    final subtitle = project.archived ? '${kind.label} · archivado' : kind.label;
    final badge = IconBadge.app(style.icon, background: style.background, foreground: style.foreground);
    final name = Text(project.name, style: text.titleMedium, maxLines: 2, overflow: TextOverflow.ellipsis);
    final kindText = Text(
      subtitle,
      style: text.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
    );

    final content = compact
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              badge,
              const Spacer(),
              name,
              kindText,
              const SizedBox(height: 10),
              _CurrentWeek(project: project),
            ],
          )
        : Row(
            children: [
              badge,
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    name,
                    kindText,
                    const SizedBox(height: 10),
                    _CurrentWeek(project: project),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right),
            ],
          );

    return Opacity(
      opacity: project.archived ? 0.6 : 1,
      child: Card(
        margin: compact ? const EdgeInsets.all(4) : null,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: const EdgeInsets.all(16), child: content),
        ),
      ),
    );
  }
}

/// Avance de la semana actual del proyecto («Semana 10 · 2 de 4»).
class _CurrentWeek extends ConsumerWidget {
  const _CurrentWeek({required this.project});
  final Project project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final season = ref.watch(currentSeasonProvider(project.id)).value;
    if (season == null) return const SizedBox.shrink();
    final week = seasonWeekFor(ref.watch(todayProvider), season.week1Start).clamp(1, 1 << 30);
    final rows = ref.watch(weekRowsProvider((projectId: project.id, seasonId: season.id, week: week))).value;
    final progress = WeekProgress(complete: rows?.where((r) => r.isComplete).length ?? 0, total: rows?.length ?? 0);
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Semana $week · ${progress.complete} de ${progress.total}',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress.fraction,
            minHeight: 6,
            backgroundColor: scheme.surfaceContainerHighest,
            color: progress.isDone ? scheme.secondary : scheme.primary,
          ),
        ),
      ],
    );
  }
}

/// Inicio vacío en la web: invita a conectar Drive o, si ya está conectado, a
/// traer los datos del teléfono.
class _WebEmptyState extends ConsumerStatefulWidget {
  const _WebEmptyState();

  @override
  ConsumerState<_WebEmptyState> createState() => _WebEmptyStateState();
}

class _WebEmptyStateState extends ConsumerState<_WebEmptyState> {
  bool _busy = false;

  Future<void> _sync() async {
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final r = await ref.read(syncCoordinatorProvider.notifier).run();
      if (r == null) return; // ya había una sincronización en curso
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            r.otherDevices == 0
                ? 'Todavía no hay datos del teléfono en tu Drive. Sincroniza primero en el teléfono.'
                : 'Listo: ${r.received} cambios recibidos.',
          ),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('No se pudo sincronizar: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final account = ref.watch(driveAccountProvider);
    if (account == null) {
      return EmptyState(
        icon: Icons.cloud_sync_outlined,
        illustration: const EmptyIllustration(),
        message: 'Conecta tu Google Drive para traer los proyectos que registraste en el teléfono.',
        action: FilledButton.icon(
          onPressed: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const DriveScreen())),
          icon: const Icon(Icons.cloud_outlined),
          label: const Text('Conectar Google Drive'),
        ),
      );
    }
    return EmptyState(
      icon: Icons.cloud_sync_outlined,
      illustration: const EmptyIllustration(),
      message:
          'Drive conectado (${account.email}), pero aún no llegan proyectos del teléfono.\n\n'
          '1. En el teléfono, con la versión más nueva de la app: Configuración → Google Drive → '
          'Sincronizar ahora.\n'
          '2. Luego toca «Traer datos del teléfono».',
      action: FilledButton.icon(
        onPressed: _busy || ref.watch(syncCoordinatorProvider).running ? null : _sync,
        icon: _busy
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.sync),
        label: const Text('Traer datos del teléfono'),
      ),
    );
  }
}
