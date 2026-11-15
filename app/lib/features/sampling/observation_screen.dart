import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/sampling_repository.dart';
import '../../domain/completeness.dart';
import '../../domain/photo_naming.dart';
import '../../domain/season_weeks.dart';
import '../../providers.dart';
import '../app_icons.dart';
import '../common.dart';
import '../scale/scale_screen.dart';
import 'device_services.dart';

/// Registro de una unidad en una semana: estado fenológico, fotos, notas y
/// ubicación. Cada cambio se guarda al instante en el teléfono.
class ObservationScreen extends ConsumerStatefulWidget {
  const ObservationScreen({
    super.key,
    required this.project,
    required this.season,
    required this.unit,
    required this.week,
  });
  final Project project;
  final Season season;
  final Unit unit;
  final int week;

  @override
  ConsumerState<ObservationScreen> createState() => _ObservationScreenState();
}

class _ObservationScreenState extends ConsumerState<ObservationScreen> {
  final _notes = TextEditingController();
  bool _notesLoaded = false;
  Timer? _notesTimer;
  bool _busy = false;

  // Se guarda al iniciar porque las notas pendientes se escriben en dispose(),
  // cuando `ref` ya no se puede usar.
  late final SamplingRepository _repo;

  @override
  void initState() {
    super.initState();
    _repo = ref.read(samplingRepositoryProvider);
  }

  ({String seasonId, String unitId, int week}) get _key =>
      (seasonId: widget.season.id, unitId: widget.unit.id, week: widget.week);

  /// El registro se crea recién cuando se guarda el primer dato.
  Future<String> _observationId() => _repo.ensureObservation(widget.season.id, widget.unit.id, widget.week);

  @override
  void dispose() {
    _flushNotes();
    _notes.dispose();
    super.dispose();
  }

  void _onNotesChanged(String _) {
    _notesTimer?.cancel();
    _notesTimer = Timer(const Duration(milliseconds: 700), _flushNotes);
  }

  void _flushNotes() {
    if (_notesTimer == null) return;
    _notesTimer!.cancel();
    _notesTimer = null;
    final text = _notes.text;
    _repo.ensureObservation(widget.season.id, widget.unit.id, widget.week).then((id) => _repo.setNotes(id, text));
  }

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  Future<void> _pickStage(String? currentStageId) async {
    final stage = await showModalBottomSheet<PhenoStage>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        builder: (context, scroll) => StageList(
          scaleId: widget.project.scaleId,
          selectedStageId: currentStageId,
          controller: scroll,
          onSelected: (s) => Navigator.pop(context, s),
        ),
      ),
    );
    if (stage == null) return;
    final id = await _observationId();
    await ref.read(samplingRepositoryProvider).setStage(id, stage.id);
  }

  Future<void> _addPhotos(PhotoKind kind, {required bool camera}) async {
    final picker = ref.read(photoPickerProvider);
    setState(() => _busy = true);
    try {
      final paths = camera ? await picker.fromCamera() : await picker.fromGallery();
      if (paths.isEmpty) return;
      final id = await _observationId();
      final repo = ref.read(samplingRepositoryProvider);
      for (final path in paths) {
        await repo.addPhoto(observationId: id, kind: kind, sourcePath: path);
      }
    } catch (e) {
      if (mounted) _snack('No se pudo agregar la foto: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _deletePhoto(Photo photo) async {
    if (await confirm(context, title: 'Eliminar foto', message: photo.fileName)) {
      await ref.read(samplingRepositoryProvider).deletePhoto(photo);
    }
  }

  Future<void> _locate() async {
    setState(() => _busy = true);
    try {
      final fix = await ref.read(locationServiceProvider).current();
      final id = await _observationId();
      await ref.read(samplingRepositoryProvider).setLocation(id, lat: fix.lat, lon: fix.lon, accuracyM: fix.accuracyM);
    } catch (e) {
      if (mounted) _snack(e is LocationException ? e.message : 'No se pudo obtener la ubicación: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _clearLocation(String observationId) => ref.read(samplingRepositoryProvider).setLocation(observationId);

  @override
  Widget build(BuildContext context) {
    final observation = ref.watch(observationProvider(_key));
    final stages = ref.watch(stagesProvider(widget.project.scaleId)).value ?? const <PhenoStage>[];
    final weekStart = seasonWeekStart(widget.week, widget.season.week1Start);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.unit.label),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(24),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text('Semana ${widget.week} · desde el ${shortDate.format(weekStart)}'),
          ),
        ),
      ),
      body: asyncView(observation, (obs) {
        if (!_notesLoaded) {
          _notes.text = obs?.notes ?? '';
          _notesLoaded = true;
        }
        final stage = stages.where((s) => s.id == obs?.stageId).firstOrNull;
        final photos = obs == null ? const AsyncValue<List<Photo>>.data([]) : ref.watch(photosProvider(obs.id));
        final photoList = photos.value ?? const <Photo>[];
        final complete = isObservationComplete(hasStage: stage != null, photoCount: photoList.length);

        return Stack(
          children: [
            ListView(
              padding: const EdgeInsets.only(bottom: 32),
              children: [
                _StatusBanner(complete: complete),
                _Section(
                  title: 'Estado fenológico',
                  icon: AppIcons.scale,
                  child: ListTile(
                    leading: StageBadge(code: stage?.code, color: stage?.color, size: 48),
                    title: Text(stage?.name ?? 'Sin estado'),
                    subtitle: Text(stage?.description ?? 'Toca para elegir el estado desde la escala'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (stage != null && obs != null)
                          IconButton(
                            tooltip: 'Quitar estado',
                            icon: const Icon(Icons.backspace_outlined),
                            onPressed: () => ref.read(samplingRepositoryProvider).setStage(obs.id, null),
                          ),
                        const Icon(Icons.edit),
                      ],
                    ),
                    onTap: () => _pickStage(stage?.id),
                  ),
                ),
                for (final kind in PhotoKind.values)
                  _PhotoSection(
                    kind: kind,
                    photos: photoList.where((p) => p.kind == kind.name).toList(),
                    onCamera: () => _addPhotos(kind, camera: true),
                    onGallery: () => _addPhotos(kind, camera: false),
                    onDelete: _deletePhoto,
                  ),
                _Section(
                  title: 'Notas',
                  icon: AppIcons.notes,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _notes,
                      onChanged: _onNotesChanged,
                      minLines: 2,
                      maxLines: 8,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(hintText: 'Observaciones técnicas'),
                    ),
                  ),
                ),
                _Section(
                  title: 'Ubicación (opcional)',
                  icon: AppIcons.gps,
                  child: obs?.lat == null
                      ? ListTile(
                          leading: const Icon(Icons.add_location_alt_outlined),
                          title: const Text('Agregar ubicación GPS'),
                          subtitle: const Text('Funciona sin internet'),
                          onTap: _busy ? null : _locate,
                        )
                      : ListTile(
                          leading: const Icon(Icons.location_on),
                          title: Text('${obs!.lat!.toStringAsFixed(6)}, ${obs.lon!.toStringAsFixed(6)}'),
                          subtitle: Text(obs.accuracyM == null ? 'GPS' : 'Precisión ± ${obs.accuracyM!.round()} m'),
                          trailing: IconButton(
                            tooltip: 'Quitar ubicación',
                            icon: const Icon(Icons.close),
                            onPressed: () => _clearLocation(obs.id),
                          ),
                        ),
                ),
              ],
            ),
            if (_busy) const Positioned(top: 0, left: 0, right: 0, child: LinearProgressIndicator()),
          ],
        );
      }),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.complete});
  final bool complete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: complete ? scheme.primaryContainer : scheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(
            complete ? Icons.check_circle : Icons.info_outline,
            color: complete ? scheme.onPrimaryContainer : scheme.onTertiaryContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              complete
                  ? 'Registro completo'
                  : 'Para completar el registro: elige el estado y agrega al menos una foto.',
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child, this.icon});
  final String title;
  final Widget child;
  final AppIcons? icon;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                if (icon != null) ...[
                  AppIcon(icon!, size: 20, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                ],
                Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium)),
              ],
            ),
          ),
          child,
        ],
      ),
    ),
  );
}

class _PhotoSection extends ConsumerWidget {
  const _PhotoSection({
    required this.kind,
    required this.photos,
    required this.onCamera,
    required this.onGallery,
    required this.onDelete,
  });
  final PhotoKind kind;
  final List<Photo> photos;
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final ValueChanged<Photo> onDelete;

  String get _title => switch (kind) {
    PhotoKind.general => 'Fotos generales (planta o canopia)',
    PhotoKind.detail => 'Fotos de detalle (macro)',
    PhotoKind.extra => 'Fotos adicionales',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photoStore = ref.watch(photoStoreProvider);
    final scheme = Theme.of(context).colorScheme;
    return _Section(
      icon: switch (kind) {
        PhotoKind.general => AppIcons.camera,
        PhotoKind.detail => AppIcons.variety,
        PhotoKind.extra => AppIcons.gallery,
      },
      title: photos.isEmpty ? _title : '$_title · ${photos.length}',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            // Cajita con las miniaturas de este tipo de foto.
            Expanded(
              child: Container(
                height: 88,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: photos.isEmpty
                    ? Center(
                        child: Text('Sin fotos', style: TextStyle(color: scheme.outline)),
                      )
                    : ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.all(4),
                        children: [
                          for (final p in photos)
                            Padding(
                              padding: const EdgeInsets.all(4),
                              child: GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(builder: (_) => _PhotoViewer(photo: p)),
                                ),
                                onLongPress: () => onDelete(p),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    photoStore.file(p.localPath),
                                    width: 72,
                                    height: 72,
                                    fit: BoxFit.cover,
                                    cacheWidth: 216,
                                    errorBuilder: (_, _, _) =>
                                        const SizedBox(width: 72, height: 72, child: Icon(Icons.broken_image)),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
              ),
            ),
            const SizedBox(width: 8),
            // Botones pequeños a la derecha de la cajita.
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton.filledTonal(
                  tooltip: 'Tomar foto',
                  visualDensity: VisualDensity.compact,
                  onPressed: onCamera,
                  icon: const AppIcon(AppIcons.camera, size: 22),
                ),
                IconButton.filledTonal(
                  tooltip: 'Elegir de la galería',
                  visualDensity: VisualDensity.compact,
                  onPressed: onGallery,
                  icon: const AppIcon(AppIcons.gallery, size: 22),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoViewer extends ConsumerWidget {
  const _PhotoViewer({required this.photo});
  final Photo photo;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    backgroundColor: Colors.black,
    appBar: AppBar(title: Text(photo.fileName, style: const TextStyle(fontSize: 14))),
    body: InteractiveViewer(
      maxScale: 6,
      child: Center(child: Image.file(ref.watch(photoStoreProvider).file(photo.localPath))),
    ),
  );
}
