import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/drive/auto_sync.dart';
import 'features/projects/projects_screen.dart';
import 'providers.dart';

const _leafGreen = Color(0xFF2F6B3A);
const _berryRed = Color(0xFFB0204E);

/// Radios de esquina usados en toda la app.
const radiusLarge = 24.0;
const radiusMedium = 16.0;

/// Tema visual: verde hoja con acento rojo fruto, superficies suaves sin bordes
/// duros, esquinas redondeadas y controles grandes (cómodos en terreno).
ThemeData buildTheme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(seedColor: _leafGreen, secondary: _berryRed, brightness: brightness);
  final base = ThemeData(useMaterial3: true, colorScheme: scheme);
  final text = base.textTheme;
  final rounded = RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMedium));

  return base.copyWith(
    scaffoldBackgroundColor: scheme.surface,
    textTheme: text.copyWith(
      headlineMedium: text.headlineMedium?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.5),
      headlineSmall: text.headlineSmall?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.3),
      titleLarge: text.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      titleMedium: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      titleTextStyle: text.titleLarge?.copyWith(fontWeight: FontWeight.w600, color: scheme.onSurface),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: scheme.surfaceContainerLow,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusLarge)),
    ),
    listTileTheme: ListTileThemeData(shape: rounded, contentPadding: const EdgeInsets.symmetric(horizontal: 16)),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusMedium), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusMedium), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(minimumSize: const Size(64, 52), shape: rounded),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(minimumSize: const Size(64, 52), shape: rounded),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      elevation: 2,
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    snackBarTheme: SnackBarThemeData(behavior: SnackBarBehavior.floating, shape: rounded),
    dialogTheme: DialogThemeData(backgroundColor: scheme.surfaceContainerHigh),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    ),
    dividerTheme: DividerThemeData(color: scheme.outlineVariant.withValues(alpha: 0.5), space: 1),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {TargetPlatform.android: FadeForwardsPageTransitionsBuilder()},
    ),
  );
}

class FramBitacoraApp extends ConsumerWidget {
  const FramBitacoraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      themeMode: ref.watch(themeModeProvider),
      title: 'FramBitácora',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      locale: const Locale('es'),
      supportedLocales: const [Locale('es')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      // Sincroniza con Drive sola (al abrir, al volver, cada 10 min y tras cambios).
      builder: (context, child) => AutoSyncWatcher(child: child ?? const SizedBox()),
      home: const ProjectsScreen(),
    );
  }
}
