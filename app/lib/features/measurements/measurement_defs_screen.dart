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

/// Crea o edita la definición de una medición.
Future<void> showMeasurementDefDialog(
  BuildContext context,
  WidgetRef ref, {
  required String projectId,
  MeasurementDef? def,
}) async {
  final name = TextEditingController(text: def?.name ?? '');
  final unit = TextEditingController(text: def?.unit ?? '');
  final min = TextEditingController(text: def?.minValue == null ? '' : formatNumber(def!.minValue!));
  final max = TextEditingController(text: def?.maxValue == null ? '' : formatNumber(def!.maxValue!));
  final choices = TextEditingController(text: def?.choices ?? '');
  var kind = MeasurementKind.fromName(def?.kind ?? MeasurementKind.number.name);
  var scope = MeasurementScope.fromName(def?.scope ?? MeasurementScope.observation.name);
  final form = GlobalKey<FormState>();

  String? numberValidator(String? v) =>
      (v ?? '').trim().isNotEmpty && _parseOptional(v!) == null ? 'Debe ser un número' : null;

  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialog) => AlertDialog(
        title: Text(def == null ? 'Nueva medición' : 'Editar medición'),
        content: Form(
          key: form,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: name,
                  autofocus: def == null,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  textCapitalization: TextCapitalization.sentences,
                  validator: (v) => (v ?? '').trim().isEmpty ? 'Escribe un nombre' : null,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<MeasurementKind>(
                  initialValue: kind,
                  decoration: const InputDecoration(labelText: 'Tipo de dato'),
                  items: [for (final k in MeasurementKind.values) DropdownMenuItem(value: k, child: Text(k.label))],
                  onChanged: (k) => setDialog(() => kind = k!),
                ),
                if (def == null)
                  DropdownButtonFormField<MeasurementScope>(
                    initialValue: scope,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Cuándo se mide'),
                    items: [for (final s in MeasurementScope.values) DropdownMenuItem(value: s, child: Text(s.label))],
                    onChanged: (s) => setDialog(() => scope = s!),
                  ),
                if (kind.isNumeric) ...[
                  TextFormField(
                    controller: unit,
                    decoration: const InputDecoration(labelText: 'Unidad (cm, n.º, kg/ha…)'),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: min,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                          decoration: const InputDecoration(labelText: 'Mínimo'),
                          validator: numberValidator,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: max,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                          decoration: const InputDecoration(labelText: 'Máximo'),
                          validator: numberValidator,
                        ),
                      ),
                    ],
                  ),
                ],
                if (kind == MeasurementKind.choice)
                  TextFormField(
                    controller: choices,
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
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              if (form.currentState!.validate()) Navigator.pop(context, true);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    ),
  );
  if (ok == true) {
    final repo = ref.read(measurementRepositoryProvider);
    final numeric = kind.isNumeric;
    final minV = numeric ? _parseOptional(min.text) : null;
    final maxV = numeric ? _parseOptional(max.text) : null;
    final unitV = numeric ? unit.text : '';
    final choicesV = kind == MeasurementKind.choice ? choices.text : '';
    if (def == null) {
      await repo.createDef(
        projectId: projectId,
        name: name.text,
        kind: kind,
        scope: scope,
        unit: unitV,
        minValue: minV,
        maxValue: maxV,
        choices: choicesV,
      );
    } else {
      await repo.updateDef(
        def.id,
        name: name.text,
        kind: kind,
        unit: unitV,
        minValue: minV,
        maxValue: maxV,
        choices: choicesV,
      );
    }
  }
  for (final c in [name, unit, min, max, choices]) {
    c.dispose();
  }
}
