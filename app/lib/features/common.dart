import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/database.dart';
import '../providers.dart';
import 'app_icons.dart';

final shortDate = DateFormat("EEE d 'de' MMM", 'es');
final longDate = DateFormat("EEEE d 'de' MMMM 'de' y", 'es');

/// Círculo con el color del estadio y su código.
class StageBadge extends StatelessWidget {
  const StageBadge({super.key, required this.code, required this.color, this.size = 40});
  final String? code;
  final int? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (code == null || color == null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: scheme.outline, width: 1.5),
        ),
        alignment: Alignment.center,
        child: Text('—', style: TextStyle(color: scheme.outline)),
      );
    }
    final bg = Color(color!);
    final fg = bg.computeLuminance() > 0.45 ? Colors.black87 : Colors.white;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: bg),
      alignment: Alignment.center,
      child: Text(
        code!,
        style: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: size * 0.34),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.message, this.illustration});
  final IconData icon;
  final String message;

  /// Dibujo que reemplaza al ícono (p. ej. [EmptyIllustration]).
  final Widget? illustration;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          illustration ?? Icon(icon, size: 56, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    ),
  );
}

/// Muestra datos asíncronos con indicador de carga y mensaje de error.
Widget asyncView<T>(AsyncValue<T> value, Widget Function(T data) builder) => value.when(
  data: builder,
  loading: () => const Center(child: CircularProgressIndicator()),
  error: (e, _) => Center(
    child: Padding(padding: const EdgeInsets.all(24), child: Text('Error: $e')),
  ),
);

/// Elige el cultivo: si hay uno solo lo devuelve directamente.
Future<Crop?> pickCrop(BuildContext context, WidgetRef ref) async {
  final crops = await ref.read(cropsProvider.future);
  if (crops.length <= 1 || !context.mounted) return crops.firstOrNull;
  return showDialog<Crop>(
    context: context,
    builder: (context) => SimpleDialog(
      title: const Text('Cultivo'),
      children: [
        for (final c in crops) SimpleDialogOption(onPressed: () => Navigator.pop(context, c), child: Text(c.name)),
      ],
    ),
  );
}

Future<bool> confirm(
  BuildContext context, {
  required String title,
  required String message,
  String action = 'Eliminar',
}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(action)),
      ],
    ),
  );
  return ok ?? false;
}

/// Título de sección en pantallas de configuración.
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(28, 20, 24, 8),
    child: Text(
      text,
      style: Theme.of(context).textTheme.labelLarge
          ?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w700),
    ),
  );
}

/// Pide un texto (no vacío). Devuelve `null` si se cancela.
Future<String?> promptText(
  BuildContext context, {
  required String title,
  String initial = '',
  String? hint,
  bool allowEmpty = false,
}) async {
  final text = await showDialog<String>(
    context: context,
    builder: (_) => _PromptDialog(title: title, initial: initial, hint: hint),
  );
  if (text == null) return null;
  return text.trim().isEmpty && !allowEmpty ? null : text.trim();
}

class _PromptDialog extends StatefulWidget {
  const _PromptDialog({required this.title, required this.initial, this.hint});
  final String title;
  final String initial;
  final String? hint;

  @override
  State<_PromptDialog> createState() => _PromptDialogState();
}

class _PromptDialogState extends State<_PromptDialog> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: TextField(
      controller: _controller,
      autofocus: true,
      minLines: 1,
      maxLines: 4,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(hintText: widget.hint),
    ),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
      FilledButton(onPressed: () => Navigator.pop(context, _controller.text), child: const Text('Guardar')),
    ],
  );
}

/// Ícono dentro de un recuadro redondeado de color suave.
class IconBadge extends StatelessWidget {
  const IconBadge(IconData this.icon, {super.key, this.size = 44, this.background, this.foreground}) : appIcon = null;
  const IconBadge.app(AppIcons this.appIcon, {super.key, this.size = 44, this.background, this.foreground})
    : icon = null;
  final IconData? icon;
  final AppIcons? appIcon;
  final double size;
  final Color? background;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background ?? scheme.primaryContainer,
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      alignment: Alignment.center,
      child: appIcon != null
          ? AppIcon(appIcon!, size: size * 0.56, color: foreground ?? scheme.onPrimaryContainer)
          : Icon(icon, size: size * 0.52, color: foreground ?? scheme.onPrimaryContainer),
    );
  }
}

/// Grupo de opciones dentro de una tarjeta, separadas por líneas finas.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    child: Column(
      children: [
        for (final (i, c) in children.indexed) ...[if (i > 0) const Divider(indent: 72, endIndent: 16), c],
      ],
    ),
  );
}
