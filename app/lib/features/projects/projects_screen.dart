import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../domain/project_kind.dart';
import '../../providers.dart';
import '../common.dart';
import '../export/backup_screen.dart';
import '../sync/sync_controller.dart';
import '../sync/sync_screen.dart';
import '../scale/scale_screen.dart';
import '../varieties/varieties_screen.dart';
import 'project_form_screen.dart';
import 'project_screen.dart';

/// Pantalla de inicio: lista de proyectos (ensayos y predios).
class ProjectsScreen extends ConsumerStatefulWidget {
  const ProjectsScreen({super.key});

  @override
  ConsumerState<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends ConsumerState<ProjectsScreen> {
  bool _grid = false;

  @override
  void initState() {
    super.initState();
    // Sincroniza al abrir y luego cada 10 minutos (si hay sesión).
    Future.microtask(() => ref.read(syncControllerProvider.notifier).start());
  }

  Future<void> _openCatalog(Widget Function(Crop crop) screen) async {
    final crop = await pickCrop(context, ref);
    if (crop == null || !mounted) return;
    await Navigator.push(context, MaterialPageRoute<void>(builder: (_) => screen(crop)));
  }

  void _openProject(Project p) =>
      Navigator.push(context, MaterialPageRoute<void>(builder: (_) => ProjectScreen(projectId: p.id)));

  @override
  Widget build(BuildContext context) {
    final projects = ref.watch(projectsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('FramBitácora'),
        actions: [
          const _SyncButton(),
          IconButton(
            tooltip: _grid ? 'Ver como lista' : 'Ver como cuadrícula',
            icon: Icon(_grid ? Icons.view_list : Icons.grid_view),
            onPressed: () => setState(() => _grid = !_grid),
          ),
          PopupMenuButton<String>(
            onSelected: (v) => switch (v) {
              'varieties' => _openCatalog((c) => VarietiesScreen(cropId: c.id, cropName: c.name)),
              'backup' => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const BackupScreen())),
              _ => _openCatalog((c) => ScaleScreen(cropId: c.id, cropName: c.name)),
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'varieties', child: Text('Variedades')),
              PopupMenuItem(value: 'scale', child: Text('Escala fenológica')),
              if (!kIsWeb) PopupMenuItem(value: 'backup', child: Text('Respaldo y Google Drive')),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const ProjectFormScreen())),
        icon: const Icon(Icons.add),
        label: const Text('Proyecto'),
      ),
      body: asyncView(projects, (list) {
        if (list.isEmpty) {
          return const EmptyState(
            icon: Icons.eco_outlined,
            message: 'Aún no hay proyectos.\nCrea un ensayo o un predio con el botón «Proyecto».',
          );
        }
        if (_grid) {
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 88),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 220,
              childAspectRatio: 1.2,
            ),
            itemCount: list.length,
            itemBuilder: (_, i) => _ProjectCard(project: list[i], onTap: () => _openProject(list[i]), compact: true),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 88),
          itemCount: list.length,
          itemBuilder: (_, i) => _ProjectCard(project: list[i], onTap: () => _openProject(list[i])),
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

  IconData get _icon => switch (ProjectKind.fromName(project.kind)) {
    ProjectKind.varietyTrial => Icons.science_outlined,
    ProjectKind.treatmentTrial => Icons.grid_on,
    ProjectKind.farm => Icons.agriculture_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final kind = ProjectKind.fromName(project.kind);
    final subtitle = project.archived ? '${kind.label} · archivado' : kind.label;
    if (compact) {
      return Card(
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(_icon, size: 32, color: Theme.of(context).colorScheme.primary),
                const Spacer(),
                Text(
                  project.name,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ),
      );
    }
    return Card(
      child: ListTile(
        leading: Icon(_icon, color: Theme.of(context).colorScheme.primary),
        title: Text(project.name),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

/// Nube en la barra: muestra si hay cambios por enviar o sincronización en curso.
class _SyncButton extends ConsumerWidget {
  const _SyncButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(syncSessionProvider).value;
    final pending = ref.watch(syncPendingProvider).value ?? 0;
    final state = ref.watch(syncControllerProvider);
    final icon = session == null
        ? Icons.cloud_off_outlined
        : state.running
        ? Icons.cloud_sync_outlined
        : state.error != null
        ? Icons.cloud_off
        : pending > 0
        ? Icons.cloud_upload_outlined
        : Icons.cloud_done_outlined;
    final tooltip = session == null
        ? 'Equipo y sincronización (sin conectar)'
        : state.running
        ? 'Sincronizando…'
        : pending > 0
        ? '$pending cambios por enviar'
        : 'Sincronizado';
    return IconButton(
      tooltip: tooltip,
      icon: Badge(isLabelVisible: session != null && pending > 0, label: Text('$pending'), child: Icon(icon)),
      onPressed: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const SyncScreen())),
    );
  }
}
