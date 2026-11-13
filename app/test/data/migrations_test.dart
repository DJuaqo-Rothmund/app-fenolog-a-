import 'dart:io';

import 'package:drift/drift.dart' show OrderingTerm;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frambitacora/data/database.dart';

void main() {
  late Directory tmp;

  setUp(() async => tmp = await Directory.systemTemp.createTemp('frambitacora_migracion'));
  tearDown(() => tmp.delete(recursive: true));

  /// Estructura de una tabla (columnas, tipos, obligatorias y valores por defecto).
  Future<List<String>> shape(AppDatabase db, String table) async => [
    for (final c in await db.customSelect('PRAGMA table_info($table)').get())
      '${c.read<String>('name')} ${c.read<String>('type')} ${c.read<int>('notnull')} ${c.data['dflt_value']}',
  ];

  test('2 → 3: crea la tabla de tratamientos igual a una base nueva y la llena', () async {
    final fresh = AppDatabase(NativeDatabase.memory());
    final expectedTreatments = await shape(fresh, 'treatments');
    final expectedProjects = await shape(fresh, 'projects');
    await fresh.close();

    // Base «versión 2»: sin tabla de tratamientos ni repeticiones, con un ensayo antiguo.
    final file = File('${tmp.path}/v2.sqlite');
    var db = AppDatabase(NativeDatabase(file));
    await db.customSelect('SELECT 1').get();
    await db.customStatement('PRAGMA foreign_keys = OFF');
    await db.customStatement('DROP TABLE treatments');
    await db.customStatement('ALTER TABLE projects DROP COLUMN replicates');
    const t = "'2026-09-08'";
    await db.customStatement(
      "INSERT INTO projects (id, crop_id, scale_id, kind, name, created_at, updated_at) "
      "VALUES ('p1', 'c', 's', 'treatmentTrial', 'Dosis', $t, $t)",
    );
    var order = 0;
    for (final rep in [1, 2]) {
      for (final tr in ['Testigo', 'T1', 'T2']) {
        await db.customStatement(
          'INSERT INTO units (id, project_id, label, treatment, replicate, sort_order, created_at, updated_at) '
          "VALUES ('u$order', 'p1', '$tr R$rep', '$tr', $rep, ${order++}, $t, $t)",
        );
      }
    }
    await db.customStatement('PRAGMA user_version = 2');
    await db.close();

    db = AppDatabase(NativeDatabase(file));
    expect(await shape(db, 'treatments'), expectedTreatments);
    expect(await shape(db, 'projects'), expectedProjects);
    final treatments = await (db.select(db.treatments)..orderBy([(x) => OrderingTerm(expression: x.sortOrder)])).get();
    expect(treatments.map((x) => x.code), ['Testigo', 'T1', 'T2']);
    expect(treatments.map((x) => x.isControl), [true, false, false]);
    expect((await db.select(db.projects).getSingle()).replicates, 2);
    await db.close();
  });

  test('reconoce el testigo por su código', () {
    expect(isControlCode('T0'), isTrue);
    expect(isControlCode(' testigo absoluto'), isTrue);
    expect(isControlCode('T1'), isFalse);
  });
}
