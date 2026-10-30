import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frambitacora/data/catalog_repository.dart';
import 'package:frambitacora/data/database.dart';
import 'package:frambitacora/data/photo_store.dart';
import 'package:frambitacora/data/project_repository.dart';
import 'package:frambitacora/data/sampling_repository.dart';
import 'package:frambitacora/domain/project_kind.dart';
import 'package:frambitacora/features/reports/reports_screen.dart';
import 'package:frambitacora/providers.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../helpers.dart';

void main() {
  setUpAll(() => initializeDateFormatting('es'));

  testWidgets('informes: curva, matriz y comparación', (tester) async {
    final db = await tester.runAsync(testDatabase);
    late Project project;
    late Season season;
    await tester.runAsync(() async {
      final catalog = CatalogRepository(db!);
      final projects = ProjectRepository(db);
      final sampling = SamplingRepository(db, PhotoStore(baseDir: () async => Directory.systemTemp));
      final crop = (await catalog.watchCrops().first).single;
      final scale = await catalog.defaultScale(crop.id);
      final stages = await catalog.watchStages(scale.id).first;
      final id = await projects.createProject(
        cropId: crop.id,
        scaleId: scale.id,
        kind: ProjectKind.treatmentTrial,
        name: 'Ensayo',
        seasonName: '2026-27',
        week1Start: DateTime.utc(2026, 9, 7),
      );
      season = (await projects.watchCurrentSeason(id).first)!;
      project = (await projects.watchProjects().first).single;
      for (final t in ['T1', 'T2']) {
        for (final rep in [1, 2]) {
          final unit = await projects.createUnit(projectId: id, label: '$t R$rep', treatment: t, replicate: rep);
          for (final week in [1, 2, 3]) {
            final obs = await sampling.ensureObservation(season.id, unit, week);
            final index = week * 2 + (t == 'T2' ? 2 : 0) + rep % 2;
            await sampling.setStage(obs, stages[index].id);
          }
        }
      }
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db!)],
        child: MaterialApp(
          home: ReportsScreen(project: project, season: season, week: 3),
        ),
      ),
    );
    Future<void> settle() async {
      for (var i = 0; i < 5; i++) {
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
        await tester.pumpAndSettle();
      }
    }

    await settle();
    expect(find.text('Agrupar por'), findsOneWidget);
    expect(find.text('T1'), findsOneWidget, reason: 'leyenda de la curva');

    await tester.tap(find.text('Matriz'));
    await settle();
    expect(find.text('S3'), findsOneWidget);
    expect(find.text('T2 R2'), findsOneWidget);

    await tester.tap(find.text('Comparar'));
    await settle();
    // Por defecto: semana de inicio de floración, que nadie alcanzó aún.
    expect(find.text('Se necesitan al menos dos grupos con datos.'), findsOneWidget);

    await tester.tap(find.text('Semana en que se alcanzó un estadio'));
    await settle();
    await tester.tap(find.text('El estadio en una semana').last);
    await settle();
    expect(find.textContaining('diferencias significativas'), findsOneWidget);
    expect(find.text('Compartir en PDF'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    await tester.runAsync(db.close);
  });
}
