import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frambitacora/data/database.dart';
import 'package:frambitacora/data/ids.dart';
import 'package:frambitacora/data/sync_schema.dart';

void main() {
  test('una base de la versión 1 se actualiza sin perder datos', () async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final dir = await Directory.systemTemp.createTemp('frambitacora_migracion');
    final file = File('${dir.path}/db.sqlite');

    // Simula la base de la etapa 1: sin las tablas de mediciones.
    var db = AppDatabase(NativeDatabase(file));
    await db
        .into(db.crops)
        .insert(
          CropsCompanion.insert(code: 'x', shortCode: 'X', name: 'Cultivo', seasonStartMonth: 9, seasonStartDay: 7),
        );
    await db.customStatement('DROP TABLE measurement_values');
    await db.customStatement('DROP TABLE measurement_defs');
    await db.customStatement('PRAGMA user_version = 1');
    await db.close();

    db = AppDatabase(NativeDatabase(file));
    expect(await db.select(db.crops).get(), hasLength(1));
    expect(await db.select(db.measurementDefs).get(), isEmpty);
    await db.close();
    await dir.delete(recursive: true);
  });

  test('versión 2 → 3: ids deterministas, referencias intactas y todo queda por enviar', () async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final dir = await Directory.systemTemp.createTemp('frambitacora_migracion3');
    final file = File('${dir.path}/db.sqlite');

    // Datos con ids al azar, como los creaba la versión 2.
    var db = AppDatabase(NativeDatabase(file));
    await db
        .into(db.crops)
        .insert(
          CropsCompanion.insert(
            id: const Value('c-old'),
            code: 'rubus-idaeus',
            shortCode: 'FRB',
            name: 'Frambueso',
            seasonStartMonth: 9,
            seasonStartDay: 7,
          ),
        );
    await db
        .into(db.phenoScales)
        .insert(PhenoScalesCompanion.insert(id: const Value('s-old'), cropId: 'c-old', name: 'BBCH', version: 1));
    await db
        .into(db.phenoStages)
        .insert(
          PhenoStagesCompanion.insert(
            id: const Value('st-old'),
            scaleId: 's-old',
            code: '61',
            macroCode: '6',
            sortOrder: 0,
            name: 'Flor',
            color: 0,
          ),
        );
    await db
        .into(db.projects)
        .insert(
          ProjectsCompanion.insert(
            id: const Value('p'),
            cropId: 'c-old',
            scaleId: 's-old',
            kind: 'farm',
            name: 'Predio',
          ),
        );
    await db
        .into(db.seasons)
        .insert(SeasonsCompanion.insert(id: const Value('se'), projectId: 'p', name: '26', week1Start: DateTime(2026)));
    await db.into(db.units).insert(UnitsCompanion.insert(id: const Value('u'), projectId: 'p', label: 'A'));
    await db
        .into(db.observations)
        .insert(
          ObservationsCompanion.insert(
            id: const Value('o-old'),
            seasonId: 'se',
            unitId: 'u',
            weekNumber: 3,
            stageId: const Value('st-old'),
          ),
        );
    await db
        .into(db.photos)
        .insert(
          PhotosCompanion.insert(
            observationId: 'o-old',
            kind: 'general',
            seq: 1,
            fileName: 'f.jpg',
            localPath: '/x',
            takenAt: DateTime(2026),
          ),
        );
    await db
        .into(db.measurementDefs)
        .insert(
          MeasurementDefsCompanion.insert(
            id: const Value('d'),
            projectId: 'p',
            name: 'Flores',
            kind: 'integer',
            scope: 'observation',
          ),
        );
    await db
        .into(db.measurementValues)
        .insert(
          MeasurementValuesCompanion.insert(
            id: const Value('v-old'),
            defId: 'd',
            observationId: const Value('o-old'),
            valueNum: const Value(4),
          ),
        );
    for (final t in syncedTables) {
      await db.customStatement('DROP TRIGGER sync_${t}_insert');
      await db.customStatement('DROP TRIGGER sync_${t}_update');
    }
    await db.customStatement('DROP TABLE sync_outbox');
    await db.customStatement('DROP TABLE sync_meta');
    await db.customStatement('PRAGMA user_version = 2');
    await db.close();

    db = AppDatabase(NativeDatabase(file));
    final crop = await db.select(db.crops).getSingle();
    expect(crop.id, Ids.crop('rubus-idaeus'));
    final scaleId = Ids.scale('rubus-idaeus', 'BBCH');
    final project = await db.select(db.projects).getSingle();
    expect((project.cropId, project.scaleId), (crop.id, scaleId));
    final obs = await db.select(db.observations).getSingle();
    expect(obs.id, Ids.observation('se', 'u', 3));
    expect(obs.stageId, Ids.stage(scaleId, '61'));
    expect((await db.select(db.photos).getSingle()).observationId, obs.id);
    expect((await db.select(db.measurementValues).getSingle()).id, Ids.observationValue('d', obs.id));
    expect(await db.customSelect('PRAGMA foreign_key_check').get(), isEmpty);

    final outbox = await db.select(db.syncOutbox).get();
    expect(outbox, hasLength(10));

    // Desde ahora cada cambio queda anotado.
    await (db.update(db.units)..where((u) => u.id.equals('u'))).write(const UnitsCompanion(label: Value('B')));
    expect((await db.select(db.syncOutbox).get()).last.rowId, 'u');
    // Cambiar solo la ruta local de una foto no se sincroniza.
    await db.customStatement("UPDATE photos SET local_path = '/y'");
    expect(await db.select(db.syncOutbox).get(), hasLength(11));

    await db.close();
    await dir.delete(recursive: true);
  });
}
