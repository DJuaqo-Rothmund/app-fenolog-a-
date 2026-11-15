import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Íconos propios de FramBitácora (dibujos originales en `assets/icons/`).
enum AppIcons { variety, treatment, farm, camera, gallery, scale, backup, notes, gps, settings, week }

/// Ícono propio. Toma el tamaño y color del entorno (como [Icon]), así se puede
/// usar en botones, listas y menús sin configuración extra.
class AppIcon extends StatelessWidget {
  const AppIcon(this.icon, {super.key, this.size, this.color, this.semanticLabel});
  final AppIcons icon;
  final double? size;
  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = IconTheme.of(context);
    final s = size ?? theme.size ?? 24;
    return SvgPicture.asset(
      'assets/icons/${icon.name}.svg',
      width: s,
      height: s,
      colorFilter: ColorFilter.mode(color ?? theme.color ?? Colors.black, BlendMode.srcIn),
      semanticsLabel: semanticLabel,
      excludeFromSemantics: semanticLabel == null,
    );
  }
}

/// Logo de la app: frambuesa cuyas drupéolas se convierten en circuitos.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 48});
  final double size;

  @override
  Widget build(BuildContext context) =>
      SvgPicture.asset('assets/brand/symbol.svg', width: size, height: size, semanticsLabel: 'FramBitácora');
}

/// Ilustración para pantallas vacías: libreta de campo con una frambuesa.
class EmptyIllustration extends StatelessWidget {
  const EmptyIllustration({super.key, this.size = 160});
  final double size;

  @override
  Widget build(BuildContext context) =>
      SvgPicture.asset('assets/brand/empty_projects.svg', width: size, height: size, excludeFromSemantics: true);
}
