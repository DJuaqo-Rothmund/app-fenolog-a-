import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../domain/measurement.dart';
import '../../providers.dart';
import '../common.dart';
import 'measurement_defs_screen.dart';
import 'measurement_field.dart';

/// Parámetros que se registran una vez por variedad en la temporada
/// (rendimiento, número de cañas, fecha de poda…).
class VarietyParamsScreen extends ConsumerWidget {
  const VarietyParamsScreen({super.key, required this.project, required this.season});
  final Project project;
  final Season season;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final defs = ref.watch(measurementDefsProvider((projectId: project.id, scope: MeasurementScope.varietySeason)));
    final units = ref.watch(unitsProvider(project.id)).value ?? const <Unit>[];
    final varieties = ref.watch(varietiesProvider((cropId: project.cropId, includeArchived: true))).value ?? const [];
    final values = ref.watch(varietyValuesProvider(season.id)).value ?? const <MeasurementValue>[];
    final usedIds = {for (final u in units) ?u.varietyId};
    final used = varieties.where((v) => usedIds.contains(v.id)).toList();
    final repo = ref.read(measurementRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Parámetros por variedad · ${season.name}')),
      body: asyncView(defs, (defList) {
        if (defList.isEmpty) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const EmptyState(
                icon: Icons.tune,
                message:
                    'No hay parámetros por variedad.\nCréalos en «Mediciones», eligiendo '
                    '«Una vez por variedad y temporada».',
              ),
              FilledButton.icon(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute<void>(builder: (_) => MeasurementDefsScreen(projectId: project.id)),
                ),
                icon: const Icon(Icons.straighten),
                label: const Text('Ir a mediciones'),
              ),
            ],
          );
        }
        if (used.isEmpty) {
          return const EmptyState(
            icon: Icons.local_florist_outlined,
            message: 'Ninguna unidad del proyecto tiene variedad asignada.',
          );
        }
        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            for (final v in used)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(v.name, style: Theme.of(context).textTheme.titleMedium),
                      for (final d in defList)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: MeasurementField(
                            key: ValueKey('${v.id}/${d.id}'),
                            def: d,
                            value: values.where((x) => x.varietyId == v.id && x.defId == d.id).firstOrNull,
                            onSave: (value) =>
                                repo.setVarietyValue(seasonId: season.id, varietyId: v.id, defId: d.id, value: value),
                          ),
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
}
