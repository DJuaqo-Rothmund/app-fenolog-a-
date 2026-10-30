import 'package:flutter/material.dart';

import '../../data/database.dart';
import '../../domain/measurement.dart';

/// Campo para escribir el valor de una medición. Guarda al terminar de
/// escribir (al salir del campo o al presionar «listo») si el valor es válido.
class MeasurementField extends StatefulWidget {
  const MeasurementField({super.key, required this.def, required this.value, required this.onSave});
  final MeasurementDef def;
  final MeasurementValue? value;
  final Future<void> Function(MeasurementInput? value) onSave;

  @override
  State<MeasurementField> createState() => _MeasurementFieldState();
}

class _MeasurementFieldState extends State<MeasurementField> {
  late final _controller = TextEditingController(text: _stored);
  final _focus = FocusNode();
  String? _error;

  MeasurementKind get _kind => MeasurementKind.fromName(widget.def.kind);
  String get _stored => formatMeasurement(number: widget.value?.valueNum, text: widget.value?.valueText);

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      if (!_focus.hasFocus) _save(_controller.text);
    });
  }

  @override
  void didUpdateWidget(MeasurementField old) {
    super.didUpdateWidget(old);
    if (!_focus.hasFocus && _controller.text != _stored && _error == null) _controller.text = _stored;
  }

  @override
  void dispose() {
    if (_controller.text != _stored) _save(_controller.text);
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _save(String raw) {
    final def = widget.def;
    final r = parseMeasurement(
      raw,
      kind: _kind,
      min: def.minValue,
      max: def.maxValue,
      choices: parseChoices(def.choices),
    );
    if (mounted) setState(() => _error = r.error);
    if (r.error != null || raw.trim() == _stored) return;
    widget.onSave(r.value);
  }

  String get _label {
    final unit = widget.def.unit.isEmpty ? '' : ' (${widget.def.unit})';
    return '${widget.def.name}$unit';
  }

  String? get _hint {
    final min = widget.def.minValue, max = widget.def.maxValue;
    if (min != null && max != null) return 'Entre ${formatNumber(min)} y ${formatNumber(max)}';
    if (min != null) return 'Mínimo ${formatNumber(min)}';
    if (max != null) return 'Máximo ${formatNumber(max)}';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_kind == MeasurementKind.choice) {
      final choices = parseChoices(widget.def.choices);
      final current = widget.value?.valueText;
      return DropdownButtonFormField<String>(
        initialValue: choices.contains(current) ? current : null,
        decoration: InputDecoration(labelText: _label, border: const OutlineInputBorder()),
        items: [
          const DropdownMenuItem(value: '', child: Text('—')),
          for (final c in choices) DropdownMenuItem(value: c, child: Text(c)),
        ],
        onChanged: (v) => widget.onSave(v == null || v.isEmpty ? null : (number: null, text: v)),
      );
    }
    return TextField(
      controller: _controller,
      focusNode: _focus,
      keyboardType: _kind.isNumeric
          ? TextInputType.numberWithOptions(decimal: _kind == MeasurementKind.number, signed: true)
          : TextInputType.text,
      textInputAction: TextInputAction.done,
      onSubmitted: _save,
      decoration: InputDecoration(
        labelText: _label,
        helperText: _hint,
        errorText: _error,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
