import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../domain/season_weeks.dart';
import '../../providers.dart';
import '../common.dart';

/// Editar el nombre de la temporada y la fecha de la semana 1.
Future<void> showSeasonDialog(BuildContext context, WidgetRef ref, Season season) async {
  final values = await showDialog<({String name, DateTime week1})>(
    context: context,
    builder: (_) => _SeasonDialog(season: season),
  );
  if (values != null && values.name.trim().isNotEmpty) {
    await ref.read(projectRepositoryProvider).updateSeason(season.id, name: values.name, week1Start: values.week1);
  }
}

class _SeasonDialog extends StatefulWidget {
  const _SeasonDialog({required this.season});
  final Season season;

  @override
  State<_SeasonDialog> createState() => _SeasonDialogState();
}

class _SeasonDialogState extends State<_SeasonDialog> {
  late final _name = TextEditingController(text: widget.season.name);
  late DateTime _week1 = widget.season.week1Start;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Temporada'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _name,
          decoration: const InputDecoration(labelText: 'Nombre'),
        ),
        const SizedBox(height: 12),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Semana 1 desde'),
          subtitle: Text(longDate.format(_week1)),
          trailing: const Icon(Icons.edit_calendar),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _week1,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) setState(() => _week1 = mondayOf(picked));
          },
        ),
      ],
    ),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
      FilledButton(
        onPressed: () => Navigator.pop(context, (name: _name.text, week1: _week1)),
        child: const Text('Guardar'),
      ),
    ],
  );
}
