import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../domain/project_kind.dart';
import '../../providers.dart';
import '../common.dart';
import '../projects/project_screen.dart';
import '../projects/season_dialog.dart';
import '../projects/treatment_design.dart';
import '../projects/unit_form.dart';
import '../varieties/varieties_screen.dart';

/// Configuración de un proyecto: nombre, temporada, unidades y archivo.
class ProjectSettingsScreen extends ConsumerWidget {
  const ProjectSettingsScreen({super.key, required this.projectId, this.justCreated = false});
  final String projectId;

  /// Recién creado desde el formulario: se ofrece ir al proyecto al terminar.
  final bool justCreated;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(projectProvider(projectId));
    return asyncView(project, (p) {
      final kind = ProjectKind.fromName(p.kind);
      final season = ref.watch(currentSeasonProvider(p.id)).value;
      final units = ref.watch(unitsProvider(p.id)).value ?? const <Unit>[];
      final varieties = ref.watch(varietiesProvider((cropId: p.cropId, includeArchived: true))).value ?? const [];
      final varietyName = {for (final v in varieties) v.id: v.name};
      final crop = ref.watch(cropProvider(p.cropId)).value;
      final treatments = ref.watch(treatmentsProvider(p.id)).value ?? const <Treatment>[];
      final description = {for (final t in treatments) t.code: t.description};
      final design = TreatmentDesign(
        treatments: treatments.where((t) => !t.isControl).length,
        hasControl: treatments.any((t) => t.isControl),
        replicates: p.replicates ?? 1,
      );

      return Scaffold(
        appBar: AppBar(title: Text(p.name)),
        body: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            const SectionHeader('Proyecto'),
            ListTile(
              leading: const Icon(Icons.badge_outlined),
              title: const Text('Nombre'),
              subtitle: Text(p.name),
              trailing: const Icon(Icons.edit),
              onTap: () => _rename(context, ref, p),
            ),
            ListTile(
              leading: const Icon(Icons.category_outlined),
              title: Text(kind.label),
              subtitle: Text([kind.help, if (crop != null) 'Cultivo: ${crop.name}'].join('\n')),
            ),
            if (season != null) ...[
              const SectionHeader('Temporada'),
              ListTile(
                leading: const Icon(Icons.event),
                title: Text(season.name),
                subtitle: Text('Semana 1 desde el ${longDate.format(season.week1Start)}'),
                trailing: const Icon(Icons.edit),
                onTap: () => showSeasonDialog(context, ref, season),
              ),
            ],
            if (kind == ProjectKind.treatmentTrial) ...[
              const SectionHeader('Diseño del ensayo'),
              ListTile(
                leading: const Icon(Icons.grid_on),
                title: Text(design.summary),
                subtitle: const Text('Toca para cambiar tratamientos, repeticiones o testigo'),
                trailing: const Icon(Icons.edit),
                onTap: () => _editDesign(context, ref, p, design),
              ),
              const SectionHeader('Tratamientos'),
              for (final t in treatments)
                ListTile(
                  leading: CircleAvatar(child: Text(t.code)),
                  title: t.description.isEmpty
                      ? Text('Sin descripción', style: TextStyle(color: Theme.of(context).colorScheme.outline))
                      : Text(t.description),
                  subtitle: Text(t.isControl ? 'Testigo' : 'Toca para describir (producto, dosis…)'),
                  trailing: const Icon(Icons.edit_note),
                  onTap: () => _describe(context, ref, t),
                ),
            ],
            SectionHeader('Unidades (${units.length})'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (kind == ProjectKind.varietyTrial)
                    FilledButton.tonalIcon(
                      onPressed: () => _addVarieties(context, ref, p),
                      icon: const Icon(Icons.playlist_add),
                      label: const Text('Agregar variedades'),
                    ),
                  if (kind == ProjectKind.farm)
                    OutlinedButton.icon(
                      onPressed: () => showUnitForm(context, project: p),
                      icon: const Icon(Icons.add),
                      label: const Text('Una unidad'),
                    ),
                ],
              ),
            ),
            if (units.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Aún no hay unidades. Agrégalas con los botones de arriba.'),
              ),
            for (final u in units)
              ListTile(
                dense: true,
                title: Text(u.label),
                subtitle: _unitDetails(kind, u, varietyName, description),
                trailing: PopupMenuButton<String>(
                  tooltip: 'Opciones de ${u.label}',
                  onSelected: (v) async {
                    if (v == 'edit') await showUnitForm(context, project: p, unit: u);
                    if (v == 'delete' && context.mounted) {
                      final ok = await confirm(
                        context,
                        title: 'Eliminar unidad',
                        message: '«${u.label}» dejará de aparecer. Sus registros anteriores se conservan.',
                      );
                      if (ok) await ref.read(projectRepositoryProvider).deleteUnit(u.id);
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Editar')),
                    PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                  ],
                ),
              ),
            const SectionHeader('Estado'),
            SwitchListTile(
              secondary: const Icon(Icons.archive_outlined),
              title: const Text('Proyecto archivado'),
              subtitle: const Text('Los archivados quedan al final de la lista y conservan todos sus datos.'),
              value: p.archived,
              onChanged: (v) => ref.read(projectRepositoryProvider).setProjectArchived(p.id, v),
            ),
            if (justCreated)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: FilledButton.icon(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute<void>(builder: (_) => ProjectScreen(projectId: p.id)),
                  ),
                  icon: const Icon(Icons.check),
                  label: const Text('Listo, ir al proyecto'),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget? _unitDetails(ProjectKind kind, Unit u, Map<String, String> varietyName, Map<String, String> description) {
    final variety = varietyName[u.varietyId];
    final what = description[u.treatment] ?? '';
    final parts = [if (what.isNotEmpty) what, if (kind != ProjectKind.varietyTrial && variety != null) variety];
    return parts.isEmpty ? null : Text(parts.join(' · '));
  }

  Future<void> _rename(BuildContext context, WidgetRef ref, Project p) async {
    final name = await promptText(context, title: 'Nombre del proyecto', initial: p.name);
    if (name != null) await ref.read(projectRepositoryProvider).renameProject(p.id, name);
  }

  Future<void> _addVarieties(BuildContext context, WidgetRef ref, Project p) async {
    final picked = await showModalBottomSheet<List<Variety>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _VarietyPicker(project: p),
    );
    if (picked == null || picked.isEmpty) return;
    final added = await ref.read(projectRepositoryProvider).addVarietyUnits(p.id, picked);
    if (context.mounted) _snack(context, added == 1 ? 'Se agregó 1 variedad.' : 'Se agregaron $added variedades.');
  }

  Future<void> _editDesign(BuildContext context, WidgetRef ref, Project p, TreatmentDesign current) async {
    final design = await showTreatmentDesignDialog(context, current);
    if (design == null || !context.mounted) return;
    final removing = current.units - design.units;
    final fewer =
        design.treatments < current.treatments ||
        design.replicates < current.replicates ||
        (current.hasControl && !design.hasControl);
    if (fewer &&
        !await confirm(
          context,
          title: 'Quitar unidades',
          message:
              'Con este diseño se quitan tratamientos o repeticiones${removing > 0 ? ' ($removing unidades menos)' : ''}. '
              'Sus registros anteriores se conservan.',
          action: 'Aplicar',
        )) {
      return;
    }
    final r = await ref
        .read(projectRepositoryProvider)
        .configureTreatmentTrial(
          p.id,
          treatments: design.treatments,
          replicates: design.replicates,
          hasControl: design.hasControl,
        );
    if (context.mounted) _snack(context, 'Unidades agregadas: ${r.added} · quitadas: ${r.removed}.');
  }

  Future<void> _describe(BuildContext context, WidgetRef ref, Treatment t) async {
    final text = await promptText(
      context,
      title: 'Descripción de ${t.code}',
      initial: t.description,
      hint: t.isControl ? 'p. ej. Sin aplicación' : 'p. ej. Producto X, 2 L/ha',
      allowEmpty: true,
    );
    if (text != null) await ref.read(projectRepositoryProvider).setTreatmentDescription(t.id, text);
  }

  void _snack(BuildContext context, String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
}

/// Lista de variedades del cultivo para marcar las que entran al ensayo.
class _VarietyPicker extends ConsumerStatefulWidget {
  const _VarietyPicker({required this.project});
  final Project project;

  @override
  ConsumerState<_VarietyPicker> createState() => _VarietyPickerState();
}

class _VarietyPickerState extends ConsumerState<_VarietyPicker> {
  final _selected = <String>{};

  Future<void> _newVariety() async {
    final id = await showVarietyDialog(context, ref, cropId: widget.project.cropId);
    if (id != null) setState(() => _selected.add(id));
  }

  @override
  Widget build(BuildContext context) {
    final varieties =
        ref.watch(varietiesProvider((cropId: widget.project.cropId, includeArchived: false))).value ?? const [];
    final inProject = {
      for (final u in ref.watch(unitsProvider(widget.project.id)).value ?? const <Unit>[]) ?u.varietyId,
    };
    final available = varieties.where((v) => !inProject.contains(v.id)).toList();

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 8, 0),
              child: Row(
                children: [
                  Expanded(child: Text('Agregar variedades', style: Theme.of(context).textTheme.titleLarge)),
                  TextButton.icon(onPressed: _newVariety, icon: const Icon(Icons.add), label: const Text('Nueva')),
                ],
              ),
            ),
            if (available.length > 1)
              CheckboxListTile(
                title: const Text('Marcar todas'),
                value: _selected.length == available.length,
                onChanged: (all) => setState(() {
                  _selected.clear();
                  if (all == true) _selected.addAll(available.map((v) => v.id));
                }),
              ),
            Flexible(
              child: varieties.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Aún no hay variedades. Crea la primera con «Nueva».'),
                    )
                  : ListView(
                      shrinkWrap: true,
                      children: [
                        for (final v in varieties)
                          CheckboxListTile(
                            title: Text(v.name),
                            subtitle: inProject.contains(v.id)
                                ? const Text('Ya está en el proyecto')
                                : (v.code.isEmpty ? null : Text(v.code)),
                            value: inProject.contains(v.id) || _selected.contains(v.id),
                            onChanged: inProject.contains(v.id)
                                ? null
                                : (on) => setState(() => on == true ? _selected.add(v.id) : _selected.remove(v.id)),
                          ),
                      ],
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton(
                onPressed: _selected.isEmpty
                    ? null
                    : () => Navigator.pop(context, [
                        for (final v in varieties)
                          if (_selected.contains(v.id)) v,
                      ]),
                child: Text(_selected.isEmpty ? 'Marca las variedades' : 'Agregar ${_selected.length}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
