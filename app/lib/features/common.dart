import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/database.dart';
import '../providers.dart';

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
  const EmptyState({super.key, required this.icon, required this.message});
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: Theme.of(context).colorScheme.outline),
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
