import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../domain/measurement.dart';
import '../../providers.dart';
import '../common.dart';

/// Planilla de mediciones de un proyecto: qué se mide cada semana y qué
/// parámetros se registran una vez por variedad y temporada.
class MeasurementDefsScreen extends ConsumerWidget {
  const MeasurementDefsScreen({super.key, required this.projectId});
  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final defs = ref.watch(measurementDefsProvider((projectId: projectId, scope: null)));
    return Scaffold(
      appBar: AppBar(title: const Text('Mediciones')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showMeasurementDefDialog(context, ref, projectId: projectId),
        icon: const Icon(Icons.add),
        label: const Text('Medición'),
      ),
      body: asyncView(defs, (list) {
        if (list.isEmpty) {
          return const EmptyState(
            icon: Icons.straighten,
            message:
                'Aún no hay mediciones.\n'
                'Agrega lo que quieras medir cada semana (p. ej. largo de brote, n.º de flores) '
                'o una vez por variedad (p. ej. rendimiento).',
          );
        }
        return ListView(
          padding: const EdgeInsets.only(bottom: 88),
          children: [
            for (final scope in MeasurementScope.values) ...[
              ListTile(title: Text(scope.label, style: Theme.of(context).textTheme.titleMedium)),
              for (final d in list.where((d) => d.scope == scope.name))
                ListTile(
                  leading: const Icon(Icons.straighten),
                  title: Text(d.unit.isEmpty ? d.name : '${d.name} (${d.unit})'),
                  subtitle: Text(_describe(d)),
                  onTap: () => showMeasurementDefDialog(context, ref, projectId: projectId, def: d),
                  trailing: IconButton(
                    tooltip: 'Eliminar',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      if (await confirm(
                        context,
                        title: 'Eliminar medición',
                        message: '«${d.name}» dejará de pedirse. Los valores ya tomados se conservan.',
                      )) {
                        await ref.read(measurementRepositoryProvider).deleteDef(d.id);
                      }
                    },
                  ),
                ),
              if (!list.any((d) => d.scope == scope.name)) const ListTile(dense: true, title: Text('Ninguna')),
            ],
          ],
        );
      }),
    );
  }

  static String _describe(MeasurementDef d) {
    final kind = MeasurementKind.fromName(d.kind);
    final parts = [kind.label];
    if (d.minValue != null) parts.add('mín. ${formatNumber(d.minValue!)}');
    if (d.maxValue != null) parts.add('máx. ${formatNumber(d.maxValue!)}');
    if (kind == MeasurementKind.choice) parts.add(parseChoices(d.choices).join(', '));
    return parts.join(' · ');
  }
}

double? _parseOptional(String s) => s.trim().isEmpty ? null : double.tryParse(s.trim().replaceAll(',', '.'));

typedef _DefForm = ({
  String name,
  MeasurementKind kind,
  MeasurementScope scope,
  String unit,
  double? min,
  double? max,
  String choices,
});

/// Crea o edita la definición de una medición.
Future<void> showMeasurementDefDialog(
  BuildContext context,
  WidgetRef ref, {
  required String projectId,
  MeasurementDef? def,
}) async {
  final f = await showDialog<_DefForm>(
    context: context,
    builder: (_) => _MeasurementDefDialog(def: def),
  );
  if (f == null) return;
  final repo = ref.read(measurementRepositoryProvider);
  if (def == null) {
    await repo.createDef(
      projectId: projectId,
      name: f.name,
      kind: f.kind,
      scope: f.scope,
      unit: f.unit,
      minValue: f.min,
      maxValue: f.max,
      choices: f.choices,
    );
  } else {
    await repo.updateDef(
      def.id,
      name: f.name,
      kind: f.kind,
      unit: f.unit,
      minValue: f.min,
      maxValue: f.max,
      choices: f.choices,
    );
  }
}

class _MeasurementDefDialog extends StatefulWidget {
  const _MeasurementDefDialog({this.def});
  final MeasurementDef? def;

  @override
  State<_MeasurementDefDialog> createState() => _MeasurementDefDialogState();
}

class _MeasurementDefDialogState extends State<_MeasurementDefDialog> {
  late final MeasurementDef? def = widget.def;
  late final _name = TextEditingController(text: def?.name ?? '');
  late final _unit = TextEditingController(text: def?.unit ?? '');
  late final _min = TextEditingController(text: def?.minValue == null ? '' : formatNumber(def!.minValue!));
  late final _max = TextEditingController(text: def?.maxValue == null ? '' : formatNumber(def!.maxValue!));
  late final _choices = TextEditingController(text: def?.choices ?? '');
  late var _kind = MeasurementKind.fromName(def?.kind ?? MeasurementKind.number.name);
  late var _scope = MeasurementScope.fromName(def?.scope ?? MeasurementScope.observation.name);
  final _form = GlobalKey<FormState>();

  @override
  void dispose() {
    for (final c in [_name, _unit, _min, _max, _choices]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _numberValidator(String? v) =>
      (v ?? '').trim().isNotEmpty && _parseOptional(v!) == null ? 'Debe ser un número' : null;

  void _submit() {
    if (!_form.currentState!.validate()) return;
    final numeric = _kind.isNumeric;
    Navigator.pop<_DefForm>(context, (
      name: _name.text,
      kind: _kind,
      scope: _scope,
      unit: numeric ? _unit.text : '',
      min: numeric ? _parseOptional(_min.text) : null,
      max: numeric ? _parseOptional(_max.text) : null,
      choices: _kind == MeasurementKind.choice ? _choices.text : '',
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(def == null ? 'Nueva medición' : 'Editar medición'),
      content: Form(
        key: _form,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _name,
                autofocus: def == null,
                decoration: const InputDecoration(labelText: 'Nombre'),
                textCapitalization: TextCapitalization.sentences,
                validator: (v) => (v ?? '').trim().isEmpty ? 'Escribe un nombre' : null,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<MeasurementKind>(
                initialValue: _kind,
                decoration: const InputDecoration(labelText: 'Tipo de dato'),
                items: [for (final k in MeasurementKind.values) DropdownMenuItem(value: k, child: Text(k.label))],
                onChanged: (k) => setState(() => _kind = k!),
              ),
              if (def == null)
                DropdownButtonFormField<MeasurementScope>(
                  initialValue: _scope,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Cuándo se mide'),
                  items: [for (final s in MeasurementScope.values) DropdownMenuItem(value: s, child: Text(s.label))],
                  onChanged: (s) => setState(() => _scope = s!),
                ),
              if (_kind.isNumeric) ...[
                TextFormField(
                  controller: _unit,
                  decoration: const InputDecoration(labelText: 'Unidad (cm, n.º, kg/ha…)'),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _min,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                        decoration: const InputDecoration(labelText: 'Mínimo'),
                        validator: _numberValidator,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _max,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                        decoration: const InputDecoration(labelText: 'Máximo'),
                        validator: _numberValidator,
                      ),
                    ),
                  ],
                ),
              ],
              if (_kind == MeasurementKind.choice)
                TextFormField(
                  controller: _choices,
                  minLines: 3,
                  maxLines: 8,
                  decoration: const InputDecoration(labelText: 'Opciones (una por línea)'),
                  validator: (v) => parseChoices(v ?? '').isEmpty ? 'Escribe al menos una opción' : null,
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        FilledButton(onPressed: _submit, child: const Text('Guardar')),
      ],
    );
  }
}
