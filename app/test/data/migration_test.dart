import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frambitacora/data/database.dart';

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
}
