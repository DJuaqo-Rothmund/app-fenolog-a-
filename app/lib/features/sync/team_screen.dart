import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/sync/sync_api.dart';
import '../../providers.dart';
import '../common.dart';
import 'sync_screen.dart';

final _teamProvider = FutureProvider.autoDispose((ref) async {
  final engine = ref.watch(syncEngineProvider);
  final session = await engine.session();
  if (session == null) throw SyncException('Sin sesión.');
  return engine.api(session).users();
});

/// Personas del equipo (solo para el dueño).
class TeamScreen extends ConsumerWidget {
  const TeamScreen({super.key});

  Future<SyncApi> _api(WidgetRef ref) async {
    final engine = ref.read(syncEngineProvider);
    return engine.api((await engine.session())!);
  }

  Future<void> _run(BuildContext context, WidgetRef ref, Future<void> Function(SyncApi api) action) async {
    try {
      await action(await _api(ref));
      ref.invalidate(_teamProvider);
    } on SyncException catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final r = await showDialog<_NewUser>(context: context, builder: (_) => const _NewUserDialog());
    if (r == null || !context.mounted) return;
    await _run(context, ref, (api) => api.addUser(email: r.email, name: r.name, role: r.role, password: r.password));
    if (context.mounted) {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Persona agregada'),
          content: SelectableText(
            'Envíale estos datos para que conecte su teléfono en «Equipo y sincronización»:\n\n'
            'Correo: ${r.email}\nContraseña: ${r.password}',
          ),
          actions: [FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Listo'))],
        ),
      );
    }
  }

  Future<void> _actions(BuildContext context, WidgetRef ref, ({SyncUser user, bool disabled}) u) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: Text(u.user.email, style: Theme.of(context).textTheme.titleMedium)),
            for (final MapEntry(key: role, value: label) in roleLabels.entries)
              if (role != u.user.role)
                ListTile(
                  leading: const Icon(Icons.badge_outlined),
                  title: Text('Cambiar a «$label»'),
                  onTap: () => Navigator.pop(context, 'role:$role'),
                ),
            ListTile(
              leading: const Icon(Icons.password),
              title: const Text('Nueva contraseña'),
              onTap: () => Navigator.pop(context, 'password'),
            ),
            ListTile(
              leading: Icon(u.disabled ? Icons.check_circle_outline : Icons.block),
              title: Text(u.disabled ? 'Reactivar' : 'Desactivar (cierra sus sesiones)'),
              onTap: () => Navigator.pop(context, 'toggle'),
            ),
          ],
        ),
      ),
    );
    if (action == null || !context.mounted) return;
    if (action.startsWith('role:')) {
      await _run(context, ref, (api) => api.updateUser(u.user.id, role: action.substring(5)));
    } else if (action == 'toggle') {
      await _run(context, ref, (api) => api.updateUser(u.user.id, disabled: !u.disabled));
    } else if (action == 'password') {
      final password = generatePassword();
      await _run(context, ref, (api) => api.updateUser(u.user.id, password: password));
      if (context.mounted) {
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Nueva contraseña'),
            content: SelectableText('${u.user.email}\n$password'),
            actions: [FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Listo'))],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final team = ref.watch(_teamProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Equipo')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _add(context, ref),
        icon: const Icon(Icons.person_add_alt),
        label: const Text('Persona'),
      ),
      body: asyncView(
        team,
        (list) => ListView(
          padding: const EdgeInsets.only(bottom: 88),
          children: [
            for (final u in list)
              ListTile(
                leading: Icon(u.disabled ? Icons.person_off_outlined : Icons.person_outline),
                title: Text(u.user.name.isEmpty ? u.user.email : u.user.name),
                subtitle: Text(
                  '${u.user.email} · ${roleLabels[u.user.role] ?? u.user.role}${u.disabled ? ' · desactivada' : ''}',
                ),
                onTap: () => _actions(context, ref, u),
              ),
          ],
        ),
      ),
    );
  }
}

/// Contraseña inicial fácil de dictar: tres grupos de letras y números.
String generatePassword() {
  const chars = 'abcdefghjkmnpqrstuvwxyz23456789';
  final random = Random.secure();
  final rnd = List.generate(12, (_) => chars[random.nextInt(chars.length)]);
  return '${rnd.sublist(0, 4).join()}-${rnd.sublist(4, 8).join()}-${rnd.sublist(8).join()}';
}

typedef _NewUser = ({String email, String name, String role, String password});

class _NewUserDialog extends StatefulWidget {
  const _NewUserDialog();

  @override
  State<_NewUserDialog> createState() => _NewUserDialogState();
}

class _NewUserDialogState extends State<_NewUserDialog> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _name = TextEditingController();
  late final _password = TextEditingController(text: generatePassword());
  var _role = 'editor';

  @override
  void dispose() {
    for (final c in [_email, _name, _password]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Agregar persona'),
    content: Form(
      key: _form,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Nombre'),
              textCapitalization: TextCapitalization.words,
            ),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Correo'),
              validator: (v) => (v ?? '').contains('@') ? null : 'Correo no válido',
            ),
            DropdownButtonFormField<String>(
              initialValue: _role,
              decoration: const InputDecoration(labelText: 'Rol'),
              items: [
                const DropdownMenuItem(value: 'editor', child: Text('Editor (registra y edita)')),
                const DropdownMenuItem(value: 'viewer', child: Text('Solo lectura')),
                const DropdownMenuItem(value: 'owner', child: Text('Dueño (también administra el equipo)')),
              ],
              onChanged: (v) => setState(() => _role = v!),
            ),
            TextFormField(
              controller: _password,
              decoration: const InputDecoration(labelText: 'Contraseña inicial'),
              validator: (v) => (v ?? '').length < 8 ? 'Mínimo 8 caracteres' : null,
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
      FilledButton(
        onPressed: () {
          if (!_form.currentState!.validate()) return;
          Navigator.pop<_NewUser>(context, (
            email: _email.text.trim(),
            name: _name.text.trim(),
            role: _role,
            password: _password.text,
          ));
        },
        child: const Text('Agregar'),
      ),
    ],
  );
}
