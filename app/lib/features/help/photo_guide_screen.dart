import 'package:flutter/material.dart';

import '../../domain/photo_naming.dart';
import '../app_icons.dart';
import '../common.dart';

/// Un consejo de la guía: título corto y explicación.
typedef GuideTip = ({IconData icon, String title, String text});

/// Qué fotografiar en detalle según el macroestadio de la escala del frambueso.
const detailByStage = <({String code, String stage, String what})>[
  (
    code: '0',
    stage: 'Desarrollo de yemas',
    what: 'Una yema de la parte media de la caña: cerrada, hinchada o con la punta verde abriendo.',
  ),
  (
    code: '1',
    stage: 'Desarrollo de hojas',
    what: 'El brote nuevo con sus primeras hojas; que se vea cuántas hojas están desplegadas.',
  ),
  (
    code: '3',
    stage: 'Crecimiento de brotes y cañas',
    what: 'Un lateral o brote completo, desde su base hasta la punta, para ver su largo.',
  ),
  (
    code: '5',
    stage: 'Aparición de botones florales',
    what: 'El racimo de botones florales en la punta del lateral: agrupados, separados o con sépalos abiertos.',
  ),
  (code: '6', stage: 'Floración', what: 'Flores del lateral: cuántas están abiertas y si ya caen pétalos.'),
  (
    code: '7',
    stage: 'Desarrollo del fruto',
    what: 'Frutos verdes recién cuajados o creciendo; que se vean las drupéolas.',
  ),
  (
    code: '8',
    stage: 'Maduración del fruto',
    what: 'Frutos cambiando de color: rosados, rojos y maduros juntos en el racimo.',
  ),
  (
    code: '9',
    stage: 'Senescencia y reposo',
    what: 'Hojas cambiando de color o cayendo, y la yema de la caña que queda en reposo.',
  ),
];

const generalTips = <GuideTip>[
  (
    icon: Icons.straighten,
    title: 'A 2–3 metros de la planta',
    text: 'Que entre la planta o el tramo de hilera completo: desde el suelo hasta la punta de las cañas.',
  ),
  (
    icon: Icons.swap_horiz,
    title: 'De frente a la hilera',
    text: 'Párate perpendicular a la hilera, con el teléfono a la altura del pecho y en posición vertical.',
  ),
  (
    icon: Icons.push_pin_outlined,
    title: 'Mismo punto cada semana',
    text:
        'Usa una referencia fija (estaca, poste o etiqueta de la unidad) y repite el mismo encuadre. Así se ve '
        'cómo crece la canopia semana a semana.',
  ),
  (
    icon: Icons.wb_sunny_outlined,
    title: 'Con el sol a la espalda',
    text: 'Evita el contraluz. Un día nublado es ideal: los colores se ven parejos y sin sombras duras.',
  ),
  (
    icon: Icons.groups_outlined,
    title: 'Una planta representativa',
    text: 'Ni la mejor ni la peor: la que se parece a la mayoría de la unidad.',
  ),
];

const detailTips = <GuideTip>[
  (
    icon: Icons.center_focus_strong_outlined,
    title: 'A 10–20 cm y enfocado',
    text: 'Acércate en vez de usar zoom. Toca la pantalla sobre el órgano para enfocarlo antes de disparar.',
  ),
  (
    icon: Icons.crop_free,
    title: 'Que ocupe la mitad de la foto',
    text: 'La yema, brote, botón, flor o fruto debe verse grande y nítido, al centro.',
  ),
  (
    icon: Icons.back_hand_outlined,
    title: 'Fondo limpio',
    text: 'Pon la mano o una cartulina detrás para separar el órgano del follaje. Flash apagado.',
  ),
  (
    icon: Icons.how_to_vote_outlined,
    title: 'El estado de la mayoría',
    text:
        'Fotografía el órgano que muestra el estado que elegiste (el de la mayoría de la unidad). Si hay algo '
        'más adelantado que llame la atención, súmalo como foto adicional.',
  ),
  (
    icon: Icons.photo_library_outlined,
    title: 'Si dudas, dos fotos',
    text: 'Mejor dos fotos claras que una dudosa. Estas fotos servirán también para entrenar la sugerencia automática de estado.',
  ),
];

const extraTips = <GuideTip>[
  (
    icon: Icons.bug_report_outlined,
    title: 'Plagas, enfermedades y daños',
    text: 'Hojas manchadas, frutos dañados, heladas, granizo o falta de riego.',
  ),
  (
    icon: Icons.label_outline,
    title: 'Etiquetas y referencias',
    text: 'La estaca o etiqueta de la unidad, si quieres dejar registro de dónde se tomó.',
  ),
  (
    icon: Icons.trending_up,
    title: 'Algo fuera de lo común',
    text:
        'Una planta mucho más adelantada o atrasada que el resto, o cualquier cosa que quieras comentar en las notas.',
  ),
];

/// Guía para tomar fotos general, de detalle y adicionales.
class PhotoGuideScreen extends StatelessWidget {
  const PhotoGuideScreen({super.key, this.initial = PhotoKind.general});
  final PhotoKind initial;

  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 3,
    initialIndex: PhotoKind.values.indexOf(initial),
    child: Scaffold(
      appBar: AppBar(
        title: const Text('Guía de fotos'),
        bottom: const TabBar(
          tabs: [
            Tab(text: 'General'),
            Tab(text: 'Detalle'),
            Tab(text: 'Adicionales'),
          ],
        ),
      ),
      body: const TabBarView(children: [_GeneralTab(), _DetailTab(), _ExtraTab()]),
    ),
  );
}

class _Intro extends StatelessWidget {
  const _Intro({required this.icon, required this.title, required this.text});
  final AppIcons icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: scheme.primaryContainer, borderRadius: BorderRadius.circular(28)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBadge.app(icon, size: 48, background: scheme.surface, foreground: scheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: scheme.onPrimaryContainer)),
                const SizedBox(height: 4),
                Text(text, style: TextStyle(color: scheme.onPrimaryContainer)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Tips extends StatelessWidget {
  const _Tips(this.tips);
  final List<GuideTip> tips;

  @override
  Widget build(BuildContext context) => SettingsGroup(
    children: [
      for (final t in tips)
        ListTile(
          leading: Icon(t.icon, color: Theme.of(context).colorScheme.primary),
          title: Text(t.title),
          subtitle: Text(t.text),
        ),
    ],
  );
}

class _GeneralTab extends StatelessWidget {
  const _GeneralTab();

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.only(bottom: 32),
    children: const [
      _Intro(
        icon: AppIcons.camera,
        title: 'Foto general: la canopia',
        text:
            'Muestra la planta o el tramo de hilera completo: vigor, cantidad de follaje y avance general. '
            'Sirve para ver cómo crece la canopia a lo largo de la temporada.',
      ),
      SectionHeader('Cómo tomarla'),
      _Tips(generalTips),
    ],
  );
}

class _DetailTab extends StatelessWidget {
  const _DetailTab();

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.only(bottom: 32),
    children: [
      const _Intro(
        icon: AppIcons.variety,
        title: 'Foto de detalle: el estado fenológico',
        text:
            'Una foto de cerca del órgano que define el estado: yemas, brotes, laterales, botones florales, '
            'flores o frutos. Es la prueba del estado que registraste.',
      ),
      const SectionHeader('Cómo tomarla'),
      const _Tips(detailTips),
      const SectionHeader('Qué fotografiar en cada etapa'),
      SettingsGroup(
        children: [
          for (final s in detailByStage)
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                child: Text(s.code),
              ),
              title: Text(s.stage),
              subtitle: Text(s.what),
            ),
        ],
      ),
    ],
  );
}

class _ExtraTab extends StatelessWidget {
  const _ExtraTab();

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.only(bottom: 32),
    children: const [
      _Intro(
        icon: AppIcons.gallery,
        title: 'Fotos adicionales',
        text: 'Opcionales. Para todo lo que vale la pena registrar y no es la canopia ni el estado.',
      ),
      SectionHeader('Ejemplos'),
      _Tips(extraTips),
    ],
  );
}
