import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../domain/project_kind.dart';
import '../../domain/season_weeks.dart';
import '../../providers.dart';
import '../common.dart';

/// Crear un proyecto con su primera temporada.
class ProjectFormScreen extends ConsumerStatefulWidget {
  const ProjectFormScreen({super.key, this.crop});

  /// Cultivo elegido en la portada; si es nulo se puede elegir aquí.
  final Crop? crop;

  @override
  ConsumerState<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends ConsumerState<ProjectFormScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _season = TextEditingController();
  ProjectKind _kind = ProjectKind.varietyTrial;
  Crop? _crop;
  DateTime? _week1;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _season.dispose();
    super.dispose();
  }

  void _selectCrop(Crop crop) {
    final week1 = defaultWeek1Start(ref.read(todayProvider), crop.seasonStartMonth, crop.seasonStartDay);
    setState(() {
      _crop = crop;
      _week1 = week1;
      _season.text = defaultSeasonName(week1);
    });
  }

  Future<void> _pickWeek1() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _week1!,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Fecha de la semana 1',
    );
    if (picked != null) setState(() => _week1 = mondayOf(picked));
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate() || _crop == null) return;
    setState(() => _saving = true);
    final scale = await ref.read(catalogRepositoryProvider).defaultScale(_crop!.id);
    await ref
        .read(projectRepositoryProvider)
        .createProject(
          cropId: _crop!.id,
          scaleId: scale.id,
          kind: _kind,
          name: _name.text,
          seasonName: _season.text,
          week1Start: _week1!,
        );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final crops = ref.watch(cropsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo proyecto')),
      body: asyncView(crops, (list) {
        if (_crop == null && list.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _crop == null) _selectCrop(widget.crop ?? list.first);
          });
        }
        return Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Nombre', hintText: 'p. ej. Ensayo variedades 2026'),
                textCapitalization: TextCapitalization.sentences,
                validator: (v) => (v ?? '').trim().isEmpty ? 'Escribe un nombre' : null,
              ),
              const SizedBox(height: 16),
              Text('Tipo', style: Theme.of(context).textTheme.titleSmall),
              RadioGroup<ProjectKind>(
                groupValue: _kind,
                onChanged: (v) => setState(() => _kind = v!),
                child: Column(
                  children: [
                    for (final k in ProjectKind.values)
                      RadioListTile<ProjectKind>(value: k, title: Text(k.label), subtitle: Text(k.help)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              if (widget.crop == null)
                DropdownButtonFormField<Crop>(
                  initialValue: _crop,
                  decoration: const InputDecoration(labelText: 'Cultivo'),
                  items: [for (final c in list) DropdownMenuItem(value: c, child: Text(c.name))],
                  onChanged: (c) => c == null ? null : _selectCrop(c),
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _season,
                decoration: const InputDecoration(labelText: 'Temporada'),
                validator: (v) => (v ?? '').trim().isEmpty ? 'Escribe la temporada' : null,
              ),
              const SizedBox(height: 8),
              if (_week1 != null)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.event),
                  title: const Text('La semana 1 empieza el'),
                  subtitle: Text(longDate.format(_week1!)),
                  trailing: TextButton(onPressed: _pickWeek1, child: const Text('Cambiar')),
                ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: const Icon(Icons.check),
                label: const Text('Crear proyecto'),
              ),
            ],
          ),
        );
      }),
    );
  }
}
