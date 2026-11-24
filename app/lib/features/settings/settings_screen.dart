import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../domain/project_kind.dart';
import '../../providers.dart';
import '../backup/backup_screen.dart';
import '../app_icons.dart';
import '../common.dart';
import '../drive/drive_screen.dart';
import '../help/photo_guide_screen.dart';
import '../projects/project_form_screen.dart';
import '../projects/projects_screen.dart' show kindStyle;
import '../scale/scale_screen.dart';
import '../varieties/varieties_screen.dart';
import 'project_settings_screen.dart';

/// Configuración general: catálogo (variedades y escala), proyectos y datos.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _openCatalog(BuildContext context, WidgetRef ref, Widget Function(Crop crop) screen) async {
    final crop = await pickCrop(context, ref);
    if (crop == null || !context.mounted) return;
    await Navigator.push(context, MaterialPageRoute<void>(builder: (_) => screen(crop)));
  }

  void _push(BuildContext context, Widget screen) =>
      Navigator.push(context, MaterialPageRoute<void>(builder: (_) => screen));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(projectsProvider).value ?? const <Project>[];
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          const SectionHeader('Catálogo'),
          SettingsGroup(
            children: [
              ListTile(
                leading: const IconBadge.app(AppIcons.variety, size: 40),
                title: const Text('Variedades'),
                subtitle: const Text('Crear, editar y archivar variedades'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _openCatalog(context, ref, (c) => VarietiesScreen(cropId: c.id, cropName: c.name)),
              ),
              ListTile(
                leading: const IconBadge.app(AppIcons.scale, size: 40),
                title: const Text('Escala fenológica'),
                subtitle: const Text('Estadios y colores del cultivo'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _openCatalog(context, ref, (c) => ScaleScreen(cropId: c.id, cropName: c.name)),
              ),
            ],
          ),
          const SectionHeader('Proyectos (ensayos y predios)'),
          SettingsGroup(
            children: [
              ListTile(
                leading: IconBadge(
                  Icons.add,
                  size: 40,
                  background: Theme.of(context).colorScheme.primary,
                  foreground: Theme.of(context).colorScheme.onPrimary,
                ),
                title: const Text('Nuevo proyecto'),
                subtitle: const Text('Ensayo de variedades, de tratamientos o predio'),
                onTap: () => _push(context, const ProjectFormScreen()),
              ),
              for (final p in projects)
                Builder(
                  builder: (context) {
                    final kind = ProjectKind.fromName(p.kind);
                    final style = kindStyle(context, kind);
                    return ListTile(
                      leading: IconBadge.app(
                        style.icon,
                        size: 40,
                        background: style.background,
                        foreground: style.foreground,
                      ),
                      title: Text(p.name),
                      subtitle: Text(p.archived ? '${kind.label} · archivado' : kind.label),
                      trailing: const AppIcon(AppIcons.settings),
                      onTap: () => _push(context, ProjectSettingsScreen(projectId: p.id)),
                    );
                  },
                ),
            ],
          ),
          const SectionHeader('Ayuda'),
          SettingsGroup(
            children: [
              ListTile(
                leading: const IconBadge.app(AppIcons.camera, size: 40),
                title: const Text('Guía de fotos'),
                subtitle: const Text('Cómo tomar la foto general (canopia) y la de detalle'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _push(context, const PhotoGuideScreen()),
              ),
            ],
          ),
          const SectionHeader('Datos'),
          SettingsGroup(
            children: [
              ListTile(
                leading: const IconBadge(Icons.cloud_outlined, size: 40),
                title: const Text('Google Drive'),
                subtitle: Text(
                  ref.watch(driveAccountProvider)?.email ?? 'Conectar para respaldar fotos y datos en tu Drive',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _push(context, const DriveScreen()),
              ),
              // En la web los datos viven en Drive: la copia .zip es solo del teléfono.
              if (!kIsWeb)
                ListTile(
                  leading: const IconBadge.app(AppIcons.backup, size: 40),
                  title: const Text('Copia de seguridad'),
                  subtitle: const Text('Guardar o restaurar todos los datos y fotos'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _push(context, const BackupScreen()),
                ),
            ],
          ),
          const SectionHeader('Apariencia'),
          SettingsGroup(
            children: [
              ListTile(
                leading: const IconBadge(Icons.contrast, size: 40),
                title: const Text('Tema'),
                subtitle: const Text('El oscuro ahorra batería y cansa menos la vista de noche'),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode_outlined), label: Text('Claro')),
                    ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode_outlined), label: Text('Oscuro')),
                    ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.phone_android), label: Text('Teléfono')),
                  ],
                  selected: {ref.watch(themeModeProvider)},
                  onSelectionChanged: (v) => ref.read(themeModeProvider.notifier).set(v.first),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
