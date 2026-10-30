import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../domain/project_kind.dart';
import '../../providers.dart';
import '../varieties/varieties_screen.dart';

/// Crear o editar una unidad. Los campos dependen del tipo de proyecto.
Future<void> showUnitForm(BuildContext context, {required Project project, Unit? unit}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  builder: (sheetContext) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(sheetContext).bottom),
    child: _UnitForm(project: project, unit: unit),
  ),
);

class _UnitForm extends ConsumerStatefulWidget {
  const _UnitForm({required this.project, this.unit});
  final Project project;
  final Unit? unit;

  @override
  ConsumerState<_UnitForm> createState() => _UnitFormState();
}

class _UnitFormState extends ConsumerState<_UnitForm> {
  final _form = GlobalKey<FormState>();
  late final _treatment = TextEditingController(text: widget.unit?.treatment ?? '');
  late final _replicate = TextEditingController(text: widget.unit?.replicate?.toString() ?? '');
  late final _group = TextEditingController(text: widget.unit?.irrigationGroup ?? '');
  late final _sector = TextEditingController(text: widget.unit?.sector ?? '');
  late String? _varietyId = widget.unit?.varietyId;

  ProjectKind get _kind => ProjectKind.fromName(widget.project.kind);

  @override
  void dispose() {
    for (final c in [_treatment, _replicate, _group, _sector]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _newVariety() async {
    final id = await showVarietyDialog(context, ref, cropId: widget.project.cropId);
    if (id != null) setState(() => _varietyId = id);
  }

  Future<void> _save(List<Variety> varieties) async {
    if (!_form.currentState!.validate()) return;
    String? clean(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();
    final varietyName = varieties.where((v) => v.id == _varietyId).firstOrNull?.name;
    final label = unitLabel(
      kind: _kind,
      varietyName: varietyName,
      treatment: clean(_treatment),
      replicate: int.tryParse(_replicate.text.trim()),
      irrigationGroup: clean(_group),
      sector: clean(_sector),
    );
    final repo = ref.read(projectRepositoryProvider);
    if (widget.unit == null) {
      await repo.createUnit(
        projectId: widget.project.id,
        label: label,
        varietyId: _varietyId,
        treatment: clean(_treatment),
        replicate: int.tryParse(_replicate.text.trim()),
        irrigationGroup: clean(_group),
        sector: clean(_sector),
      );
    } else {
      await repo.updateUnit(
        widget.unit!.id,
        label: label,
        varietyId: _varietyId,
        treatment: clean(_treatment),
        replicate: int.tryParse(_replicate.text.trim()),
        irrigationGroup: clean(_group),
        sector: clean(_sector),
      );
    }
    if (mounted) Navigator.pop(context);
  }

  String? _required(String? v) => (v ?? '').trim().isEmpty ? 'Obligatorio' : null;

  @override
  Widget build(BuildContext context) {
    final varieties =
        ref.watch(varietiesProvider((cropId: widget.project.cropId, includeArchived: false))).value ??
        const <Variety>[];
    final varietyRequired = _kind == ProjectKind.varietyTrial;
    final selected = varieties.any((v) => v.id == _varietyId) ? _varietyId : null;

    return SafeArea(
      child: Form(
        key: _form,
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(16),
          children: [
            Text(widget.unit == null ? 'Nueva unidad' : 'Editar unidad', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            if (_kind == ProjectKind.treatmentTrial) ...[
              TextFormField(
                controller: _treatment,
                decoration: const InputDecoration(labelText: 'Tratamiento', hintText: 'p. ej. T1 o Testigo'),
                validator: _required,
              ),
              TextFormField(
                controller: _replicate,
                decoration: const InputDecoration(labelText: 'Repetición (número)'),
                keyboardType: TextInputType.number,
                validator: (v) => int.tryParse((v ?? '').trim()) == null ? 'Escribe un número' : null,
              ),
            ],
            if (_kind == ProjectKind.farm) ...[
              TextFormField(
                controller: _group,
                decoration: const InputDecoration(labelText: 'Equipo de riego'),
                validator: _required,
              ),
              TextFormField(
                controller: _sector,
                decoration: const InputDecoration(labelText: 'Sector'),
                validator: _required,
              ),
            ],
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    key: ValueKey(selected),
                    initialValue: selected,
                    decoration: InputDecoration(labelText: varietyRequired ? 'Variedad' : 'Variedad (opcional)'),
                    items: [
                      if (!varietyRequired) const DropdownMenuItem<String>(child: Text('Sin variedad')),
                      for (final v in varieties) DropdownMenuItem(value: v.id, child: Text(v.name)),
                    ],
                    onChanged: (v) => setState(() => _varietyId = v),
                    validator: (v) => varietyRequired && v == null ? 'Elige una variedad' : null,
                  ),
                ),
                IconButton(
                  tooltip: 'Nueva variedad',
                  onPressed: _newVariety,
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            const SizedBox(height: 20),
            FilledButton(onPressed: () => _save(varieties), child: const Text('Guardar')),
          ],
        ),
      ),
    );
  }
}
