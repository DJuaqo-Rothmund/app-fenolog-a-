import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'features/projects/projects_screen.dart';

const _leafGreen = Color(0xFF2F6B3A);
const _berryRed = Color(0xFFB0204E);

class FramBitacoraApp extends StatelessWidget {
  const FramBitacoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData theme(Brightness b) => ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: _leafGreen, secondary: _berryRed, brightness: b),
      cardTheme: const CardThemeData(margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6)),
    );

    return MaterialApp(
      title: 'FramBitácora',
      debugShowCheckedModeBanner: false,
      theme: theme(Brightness.light),
      darkTheme: theme(Brightness.dark),
      locale: const Locale('es'),
      supportedLocales: const [Locale('es')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: const ProjectsScreen(),
    );
  }
}
