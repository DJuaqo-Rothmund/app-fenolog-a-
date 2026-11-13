import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../providers.dart';
import '../common.dart';

/// Catálogo de variedades de un cultivo.
class VarietiesScreen extends ConsumerStatefulWidget {
  const VarietiesScreen({super.key, required this.cropId, required this.cropName});
  final String cropId;
  final String cropName;

  @override
  ConsumerState<VarietiesScreen> createState() => _VarietiesScreenState();
}

class _VarietiesScreenState extends ConsumerState<VarietiesScreen> {
  bool _showArchived = false;

  @override
  Widget build(BuildContext context) {
    final varieties = ref.watch(varietiesProvider((cropId: widget.cropId, includeArchived: _showArchived)));
    return Scaffold(
      appBar: AppBar(
        title: Text('Variedades · ${widget.cropName}'),
        actions: [
          IconButton(
            tooltip: _showArchived ? 'Ocultar archivadas' : 'Mostrar archivadas',
            icon: Icon(_showArchived ? Icons.inventory_2 : Icons.inventory_2_outlined),
            onPressed: () => setState(() => _showArchived = !_showArchived),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showVarietyDialog(context, ref, cropId: widget.cropId),
        icon: const Icon(Icons.add),
        label: const Text('Variedad'),
      ),
      body: asyncView(varieties, (list) {
        if (list.isEmpty) {
          return const EmptyState(icon: Icons.local_florist_outlined, message: 'Aún no hay variedades.');
        }
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 88),
          itemCount: list.length,
          itemBuilder: (_, i) {
            final v = list[i];
            final details = [
              if (v.code.isNotEmpty) 'Código ${v.code}',
              if (v.notes.isNotEmpty) v.notes,
              if (v.archived) 'Archivada',
            ];
            return ListTile(
              title: Text(v.name),
              subtitle: details.isEmpty ? null : Text(details.join(' · ')),
              onTap: () => showVarietyDialog(context, ref, cropId: widget.cropId, variety: v),
              trailing: IconButton(
                tooltip: v.archived ? 'Desarchivar' : 'Archivar',
                icon: Icon(v.archived ? Icons.unarchive_outlined : Icons.archive_outlined),
                onPressed: () => ref.read(catalogRepositoryProvider).setVarietyArchived(v.id, !v.archived),
              ),
            );
          },
        );
      }),
    );
  }
}

/// Crea o edita una variedad. Devuelve el id de la variedad creada o editada.
Future<String?> showVarietyDialog(
  BuildContext context,
  WidgetRef ref, {
  required String cropId,
  Variety? variety,
}) async {
  final values = await showDialog<({String name, String code, String notes})>(
    context: context,
    builder: (_) => _VarietyDialog(variety: variety),
  );
  if (values == null) return null;
  final repo = ref.read(catalogRepositoryProvider);
  if (variety == null) {
    return repo.createVariety(cropId: cropId, name: values.name, code: values.code, notes: values.notes);
  }
  await repo.updateVariety(variety.id, name: values.name, code: values.code, notes: values.notes);
  return variety.id;
}

/// El diálogo es dueño de sus campos de texto: así se liberan recién cuando
/// termina de cerrarse (liberarlos antes rompe la animación de cierre).
class _VarietyDialog extends StatefulWidget {
  const _VarietyDialog({this.variety});
  final Variety? variety;

  @override
  State<_VarietyDialog> createState() => _VarietyDialogState();
}

class _VarietyDialogState extends State<_VarietyDialog> {
  late final _name = TextEditingController(text: widget.variety?.name ?? '');
  late final _code = TextEditingController(text: widget.variety?.code ?? '');
  late final _notes = TextEditingController(text: widget.variety?.notes ?? '');
  final _form = GlobalKey<FormState>();

  @override
  void dispose() {
    _name.dispose();
    _code.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.variety == null ? 'Nueva variedad' : 'Editar variedad'),
    content: Form(
      key: _form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _name,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Nombre'),
            textCapitalization: TextCapitalization.words,
            validator: (v) => (v ?? '').trim().isEmpty ? 'Escribe un nombre' : null,
          ),
          TextFormField(
            controller: _code,
            decoration: const InputDecoration(labelText: 'Código o abreviatura'),
          ),
          TextFormField(
            controller: _notes,
            decoration: const InputDecoration(labelText: 'Notas'),
            maxLines: 3,
            minLines: 1,
          ),
        ],
      ),
    ),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
      FilledButton(
        onPressed: () {
          if (_form.currentState!.validate()) {
            Navigator.pop(context, (name: _name.text, code: _code.text, notes: _notes.text));
          }
        },
        child: const Text('Guardar'),
      ),
    ],
  );
}
