import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../providers.dart';
import '../common.dart';
import '../export/backup_screen.dart';
import '../projects/projects_screen.dart';
import '../sync/sync_controller.dart';
import '../sync/sync_screen.dart';

/// Portada: elegir el cultivo y cómo trabajar (sincronizando con el correo
/// del equipo o solo en este teléfono).
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String? _cropId;

  @override
  void initState() {
    super.initState();
    ref.read(localPrefsProvider).lastCropId().then((id) {
      if (mounted && _cropId == null && id != null) setState(() => _cropId = id);
    });
  }

  Crop? _selected(List<Crop> crops) => crops.where((c) => c.id == _cropId).firstOrNull ?? crops.firstOrNull;

  Future<void> _enter(Crop crop) async {
    await ref.read(localPrefsProvider).setLastCropId(crop.id);
    if (!mounted) return;
    await Navigator.push(context, MaterialPageRoute<void>(builder: (_) => ProjectsScreen(crop: crop)));
  }

  /// Con sesión: sincroniza (y sigue cada 10 minutos) y entra. Sin sesión:
  /// primero inicia sesión con el correo.
  Future<void> _syncAndEnter(Crop crop) async {
    final engine = ref.read(syncEngineProvider);
    if (await engine.session() == null) {
      if (!mounted) return;
      await Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const SyncScreen(closeOnLogin: true)));
      if (await engine.session() == null) return;
    }
    ref.read(syncControllerProvider.notifier).start();
    await _enter(crop);
  }

  @override
  Widget build(BuildContext context) {
    final crops = ref.watch(cropsProvider);
    final session = ref.watch(syncSessionProvider).value;
    final sync = ref.watch(syncControllerProvider);
    final counts = ref.watch(projectCountsProvider).value ?? const {};
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: asyncView(crops, (list) {
        final crop = _selected(list);
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _Header(onBackup: kIsWeb ? null : () => _push(const BackupScreen()))),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              sliver: SliverToBoxAdapter(child: Text('Elige el cultivo', style: text.titleMedium)),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 260,
                  mainAxisExtent: 132,
                ),
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _CropCard(
                    crop: list[i],
                    projects: counts[list[i].id] ?? 0,
                    selected: list[i].id == crop?.id,
                    onTap: () => setState(() => _cropId = list[i].id),
                  ),
                  childCount: list.length,
                ),
              ),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (session != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Icon(Icons.verified_user_outlined, size: 18, color: scheme.primary),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                sync.running
                                    ? (sync.status ?? 'Sincronizando…')
                                    : 'Conectado como ${session.user.email}',
                                style: text.bodySmall,
                              ),
                            ),
                            TextButton(onPressed: () => _push(const SyncScreen()), child: const Text('Cuenta')),
                          ],
                        ),
                      ),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                      onPressed: crop == null ? null : () => _syncAndEnter(crop),
                      icon: const Icon(Icons.cloud_sync_outlined),
                      label: Text(session == null ? 'Sincronizar con mi correo' : 'Sincronizar y continuar'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                      onPressed: crop == null ? null : () => _enter(crop),
                      icon: const Icon(Icons.phone_android),
                      label: const Text('Continuar de forma local'),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      session == null
                          ? 'De forma local los datos quedan solo en este ${kIsWeb ? 'navegador' : 'teléfono'}. '
                                'Puedes conectar tu correo después y se enviará todo.'
                          : 'De forma local se trabaja sin conexión; los cambios se envían la próxima vez que sincronices.',
                      textAlign: TextAlign.center,
                      style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  void _push(Widget screen) => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => screen));
}

class _Header extends StatelessWidget {
  const _Header({this.onBackup});
  final VoidCallback? onBackup;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primary, Color.lerp(scheme.primary, scheme.secondary, 0.3)!],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 8, 28),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Icon(Icons.eco, size: 44, color: scheme.onPrimary),
                    const SizedBox(height: 12),
                    Text(
                      'FramBitácora',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(color: scheme.onPrimary, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Cuaderno de campo para el seguimiento fenológico',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onPrimary),
                    ),
                  ],
                ),
              ),
              if (onBackup != null)
                IconButton(
                  tooltip: 'Respaldo y Google Drive',
                  color: scheme.onPrimary,
                  icon: const Icon(Icons.settings_backup_restore),
                  onPressed: onBackup,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CropCard extends StatelessWidget {
  const _CropCard({required this.crop, required this.projects, required this.selected, required this.onTap});
  final Crop crop;
  final int projects;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.all(4),
      clipBehavior: Clip.antiAlias,
      color: selected ? scheme.primaryContainer : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: selected ? scheme.primary : scheme.outlineVariant, width: selected ? 2 : 1),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.local_florist, color: scheme.secondary, size: 30),
                  const Spacer(),
                  if (selected) Icon(Icons.check_circle, color: scheme.primary, semanticLabel: 'Elegido'),
                ],
              ),
              const Spacer(),
              Text(crop.name, style: text.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              if (crop.scientificName.isNotEmpty)
                Text(crop.scientificName, style: text.bodySmall?.copyWith(fontStyle: FontStyle.italic)),
              Text(projects == 1 ? '1 proyecto' : '$projects proyectos', style: text.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
