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

/// Crea o edita una variedad. Devuelve el id de la variedad creada.
Future<String?> showVarietyDialog(
  BuildContext context,
  WidgetRef ref, {
  required String cropId,
  Variety? variety,
}) async {
  final name = TextEditingController(text: variety?.name ?? '');
  final code = TextEditingController(text: variety?.code ?? '');
  final notes = TextEditingController(text: variety?.notes ?? '');
  final form = GlobalKey<FormState>();
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(variety == null ? 'Nueva variedad' : 'Editar variedad'),
      content: Form(
        key: form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: name,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Nombre'),
              textCapitalization: TextCapitalization.words,
              validator: (v) => (v ?? '').trim().isEmpty ? 'Escribe un nombre' : null,
            ),
            TextFormField(
              controller: code,
              decoration: const InputDecoration(labelText: 'Código o abreviatura'),
            ),
            TextFormField(
              controller: notes,
              decoration: const InputDecoration(labelText: 'Notas'),
              maxLines: 3,
              minLines: 1,
            ),
          ],
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
  );
  String? id;
  if (ok == true) {
    final repo = ref.read(catalogRepositoryProvider);
    if (variety == null) {
      id = await repo.createVariety(cropId: cropId, name: name.text, code: code.text, notes: notes.text);
    } else {
      await repo.updateVariety(variety.id, name: name.text, code: code.text, notes: notes.text);
      id = variety.id;
    }
  }
  disposeAfterClose([name, code, notes]);
  return id;
}
