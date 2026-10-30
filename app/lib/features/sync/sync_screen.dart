import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/sync/sync_api.dart';
import '../../data/sync/sync_engine.dart';
import '../../providers.dart';
import '../common.dart';
import 'sync_controller.dart';
import 'team_screen.dart';

const roleLabels = {'owner': 'Dueño', 'editor': 'Editor', 'viewer': 'Solo lectura'};

/// Conexión con el servidor del equipo y estado de la sincronización.
class SyncScreen extends ConsumerWidget {
  const SyncScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(syncSessionProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Equipo y sincronización')),
      body: asyncView(session, (s) => s == null ? const _LoginForm() : _Connected(session: s)),
    );
  }
}

class _LoginForm extends ConsumerStatefulWidget {
  const _LoginForm();

  @override
  ConsumerState<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<_LoginForm> {
  final _form = GlobalKey<FormState>();
  final _server = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_server, _email, _password]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _connect() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(syncEngineProvider)
          .login(serverUrl: _server.text, email: _email.text, password: _password.text, device: 'Android');
      ref.read(syncControllerProvider.notifier).start();
    } on SyncException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = 'No se pudo conectar: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _form,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Conecta este teléfono al servidor del equipo para compartir proyectos, registros y fotos '
            'con otros teléfonos. Todo sigue funcionando sin internet: los cambios se envían al volver la señal.',
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _server,
            keyboardType: TextInputType.url,
            autocorrect: false,
            decoration: const InputDecoration(
              labelText: 'Dirección del servidor',
              hintText: 'https://frambitacora.midominio.cl',
              border: OutlineInputBorder(),
            ),
            validator: (v) => (v ?? '').trim().isEmpty ? 'Escribe la dirección' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            decoration: const InputDecoration(labelText: 'Correo', border: OutlineInputBorder()),
            validator: (v) => (v ?? '').contains('@') ? null : 'Correo no válido',
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _password,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Contraseña', border: OutlineInputBorder()),
            validator: (v) => (v ?? '').isEmpty ? 'Escribe la contraseña' : null,
            onFieldSubmitted: (_) => _connect(),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _busy ? null : _connect,
            icon: _busy
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.login),
            label: const Text('Conectar'),
          ),
        ],
      ),
    );
  }
}

class _Connected extends ConsumerWidget {
  const _Connected({required this.session});
  final SyncSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(syncControllerProvider);
    final pending = ref.watch(syncPendingProvider).value ?? 0;
    final report = state.report;
    final text = Theme.of(context).textTheme;
    final role = session.user.role;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        ListTile(
          leading: const Icon(Icons.account_circle_outlined),
          title: Text(session.user.email),
          subtitle: Text('${roleLabels[role] ?? role} · ${session.serverUrl}'),
        ),
        if (role == 'viewer')
          const ListTile(
            leading: Icon(Icons.visibility_outlined),
            title: Text('Usuario de solo lectura'),
            subtitle: Text('Recibes los datos del equipo; lo que cambies en este teléfono no se envía.'),
          ),
        ListTile(
          leading: Icon(pending == 0 ? Icons.cloud_done_outlined : Icons.cloud_upload_outlined),
          title: Text(pending == 0 ? 'Todo enviado' : '$pending cambios por enviar'),
          subtitle: Text(
            state.at == null
                ? 'Aún no se sincroniza en esta sesión'
                : 'Última sincronización: ${shortDate.format(state.at!)} ${TimeOfDay.fromDateTime(state.at!).format(context)}',
          ),
        ),
        if (state.running) ...[
          const LinearProgressIndicator(),
          Padding(padding: const EdgeInsets.all(12), child: Text(state.status ?? 'Sincronizando…')),
        ],
        if (state.error != null && !state.running)
          ListTile(
            leading: Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
            title: Text(state.error!),
            subtitle: const Text('Tus datos siguen guardados en el teléfono.'),
          ),
        if (report != null && !state.running && state.error == null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              'Enviados: ${report.pushed} · Recibidos: ${report.pulled} · '
              'Fotos subidas: ${report.photosUp} · Fotos descargadas: ${report.photosDown}',
              style: text.bodySmall,
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: state.running ? null : () => ref.read(syncControllerProvider.notifier).run(),
            icon: const Icon(Icons.sync),
            label: const Text('Sincronizar ahora'),
          ),
        ),
        if (role == 'owner')
          ListTile(
            leading: const Icon(Icons.group_outlined),
            title: const Text('Equipo'),
            subtitle: const Text('Agregar personas, cambiar su rol o desactivarlas'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const TeamScreen())),
          ),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Cerrar sesión'),
          subtitle: const Text('Los datos quedan en el teléfono.'),
          onTap: () async {
            if (pending > 0 &&
                !await confirm(
                  context,
                  title: 'Cerrar sesión',
                  message: 'Hay $pending cambios sin enviar. Se enviarán cuando vuelvas a conectar.',
                  action: 'Cerrar sesión',
                )) {
              return;
            }
            await ref.read(syncEngineProvider).logout();
          },
        ),
      ],
    );
  }
}
