import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../providers.dart';
import '../common.dart';

final _defaultScaleProvider = FutureProvider.family<PhenoScale, String>(
  (ref, cropId) => ref.watch(catalogRepositoryProvider).defaultScale(cropId),
);

/// Consulta de la escala fenológica del cultivo, agrupada por macroestadio.
class ScaleScreen extends ConsumerWidget {
  const ScaleScreen({super.key, required this.cropId, required this.cropName});
  final String cropId;
  final String cropName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scale = ref.watch(_defaultScaleProvider(cropId));
    return Scaffold(
      appBar: AppBar(title: Text('Escala · $cropName')),
      body: asyncView(scale, (s) => StageList(scaleId: s.id)),
    );
  }
}

/// Lista de estadios en desplegables por macroestadio. Si se indica
/// [onSelected], cada estadio se puede elegir (selector del registro).
class StageList extends ConsumerWidget {
  const StageList({super.key, required this.scaleId, this.selectedStageId, this.onSelected, this.controller});
  final String scaleId;
  final String? selectedStageId;
  final ValueChanged<PhenoStage>? onSelected;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final macros = ref.watch(macrosProvider(scaleId));
    final stages = ref.watch(stagesProvider(scaleId));
    return asyncView(
      macros,
      (ms) => asyncView(stages, (ss) {
        final selectedMacro = ss.where((s) => s.id == selectedStageId).firstOrNull?.macroCode;
        return ListView(
          controller: controller,
          children: [
            for (final m in ms)
              _MacroTile(
                macro: m,
                stages: ss.where((s) => s.macroCode == m.code).toList(),
                initiallyExpanded: m.code == selectedMacro,
                selectedStageId: selectedStageId,
                onSelected: onSelected,
              ),
          ],
        );
      }),
    );
  }
}

class _MacroTile extends StatelessWidget {
  const _MacroTile({
    required this.macro,
    required this.stages,
    required this.initiallyExpanded,
    required this.selectedStageId,
    required this.onSelected,
  });
  final PhenoMacro macro;
  final List<PhenoStage> stages;
  final bool initiallyExpanded;
  final String? selectedStageId;
  final ValueChanged<PhenoStage>? onSelected;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      initiallyExpanded: initiallyExpanded,
      leading: stages.isEmpty ? null : StageBadge(code: macro.code, color: stages.last.color, size: 32),
      title: Text(macro.name),
      subtitle: Text(stages.length == 1 ? '1 estadio' : '${stages.length} estadios'),
      children: [
        for (final s in stages)
          ListTile(
            selected: s.id == selectedStageId,
            leading: StageBadge(code: s.code, color: s.color),
            title: Text(s.name),
            subtitle: s.description.isEmpty ? null : Text(s.description),
            trailing: s.id == selectedStageId ? const Icon(Icons.check) : null,
            onTap: onSelected == null ? null : () => onSelected!(s),
          ),
      ],
    );
  }
}
