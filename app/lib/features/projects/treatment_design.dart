import 'package:flutter/material.dart';

import '../../domain/project_kind.dart';

/// Diseño de un ensayo de tratamientos: cuántos tratamientos (sin contar el
/// testigo), si hay testigo T0 y cuántas repeticiones.
class TreatmentDesign {
  const TreatmentDesign({this.treatments = 4, this.replicates = 4, this.hasControl = true});

  final int treatments;
  final int replicates;
  final bool hasControl;

  int get units => treatmentCodes(treatments, hasControl: hasControl).length * replicates;

  /// «T0 (testigo) + T1…T4 × 4 repeticiones = 20 unidades».
  String get summary {
    final list = [if (hasControl) 'T0 (testigo)', treatments == 1 ? 'T1' : 'T1…T$treatments'].join(' + ');
    return '$list × $replicates ${replicates == 1 ? 'repetición' : 'repeticiones'} = $units unidades';
  }

  TreatmentDesign copyWith({int? treatments, int? replicates, bool? hasControl}) => TreatmentDesign(
    treatments: treatments ?? this.treatments,
    replicates: replicates ?? this.replicates,
    hasControl: hasControl ?? this.hasControl,
  );
}

/// Campos para elegir el diseño, con botones − / + (sin teclado).
class TreatmentDesignFields extends StatelessWidget {
  const TreatmentDesignFields({super.key, required this.value, required this.onChanged});
  final TreatmentDesign value;
  final ValueChanged<TreatmentDesign> onChanged;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _Counter(
        label: 'Tratamientos',
        help: 'Sin contar el testigo',
        value: value.treatments,
        max: 30,
        onChanged: (n) => onChanged(value.copyWith(treatments: n)),
      ),
      _Counter(
        label: 'Repeticiones',
        value: value.replicates,
        max: 20,
        onChanged: (n) => onChanged(value.copyWith(replicates: n)),
      ),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('¿Tiene testigo (T0)?'),
        subtitle: const Text('Tratamiento sin aplicación, para comparar'),
        value: value.hasControl,
        onChanged: (v) => onChanged(value.copyWith(hasControl: v)),
      ),
      const SizedBox(height: 4),
      Text(value.summary, style: Theme.of(context).textTheme.bodySmall),
    ],
  );
}

class _Counter extends StatelessWidget {
  const _Counter({required this.label, required this.value, required this.max, required this.onChanged, this.help});
  final String label;
  final String? help;
  final int value;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(label),
    subtitle: help == null ? null : Text(help!),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Menos $label'.toLowerCase(),
          onPressed: value > 1 ? () => onChanged(value - 1) : null,
          icon: const Icon(Icons.remove_circle_outline),
        ),
        SizedBox(
          width: 32,
          child: Text('$value', textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
        ),
        IconButton(
          tooltip: 'Más $label'.toLowerCase(),
          onPressed: value < max ? () => onChanged(value + 1) : null,
          icon: const Icon(Icons.add_circle_outline),
        ),
      ],
    ),
  );
}

/// Diálogo para modificar el diseño desde Configuración.
Future<TreatmentDesign?> showTreatmentDesignDialog(BuildContext context, TreatmentDesign initial) =>
    showDialog<TreatmentDesign>(
      context: context,
      builder: (context) {
        var design = initial;
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Diseño del ensayo'),
            content: SingleChildScrollView(
              child: TreatmentDesignFields(value: design, onChanged: (d) => setState(() => design = d)),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
              FilledButton(onPressed: () => Navigator.pop(context, design), child: const Text('Aplicar')),
            ],
          ),
        );
      },
    );
