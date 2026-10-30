import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../domain/crop_definition.dart';
import 'database.dart';
import 'ids.dart';

/// Cultivos incluidos en la app. Agregar un cultivo = agregar su JSON aquí.
const bundledCropAssets = ['assets/crops/rubus-idaeus.json'];

/// Carga definiciones de cultivo (JSON) en la base local.
///
/// Es idempotente: se puede ejecutar en cada inicio. Una escala solo se
/// actualiza si la definición trae una versión mayor; los estadios nunca se
/// borran (podría haber observaciones que los usan).
class CropImporter {
  CropImporter(this.db);
  final AppDatabase db;

  Future<void> importBundled() async {
    for (final asset in bundledCropAssets) {
      final json = jsonDecode(await rootBundle.loadString(asset)) as Map<String, dynamic>;
      await importDefinition(CropDefinition.fromJson(json));
    }
  }

  Future<String> importDefinition(CropDefinition def) {
    return db.transaction(() async {
      final now = DateTime.now();
      var crop = await (db.select(db.crops)..where((c) => c.code.equals(def.code))).getSingleOrNull();
      final cropFields = CropsCompanion(
        code: Value(def.code),
        shortCode: Value(def.shortCode),
        name: Value(def.name),
        scientificName: Value(def.scientificName),
        seasonStartMonth: Value(def.seasonStartMonth),
        seasonStartDay: Value(def.seasonStartDay),
        updatedAt: Value(now),
      );
      if (crop == null) {
        crop = await db.into(db.crops).insertReturning(cropFields.copyWith(id: Value(Ids.crop(def.code))));
      } else if (crop.shortCode != def.shortCode ||
          crop.name != def.name ||
          crop.scientificName != def.scientificName ||
          crop.seasonStartMonth != def.seasonStartMonth ||
          crop.seasonStartDay != def.seasonStartDay) {
        // Solo se escribe si algo cambió, para no sincronizar en cada inicio.
        await (db.update(db.crops)..where((c) => c.id.equals(crop!.id))).write(cropFields);
      }

      for (final scaleDef in def.scales) {
        await _importScale(crop.id, def.code, scaleDef, now);
      }
      return crop.id;
    });
  }

  Future<void> _importScale(String cropId, String cropCode, ScaleDef def, DateTime now) async {
    final existing = await (db.select(
      db.phenoScales,
    )..where((s) => s.cropId.equals(cropId) & s.name.equals(def.name))).getSingleOrNull();
    if (existing != null && existing.version >= def.version) return;

    final String scaleId;
    if (existing == null) {
      scaleId =
          (await db
                  .into(db.phenoScales)
                  .insertReturning(
                    PhenoScalesCompanion.insert(
                      id: Value(Ids.scale(cropCode, def.name)),
                      cropId: cropId,
                      name: def.name,
                      version: def.version,
                      isDefault: Value(def.isDefault),
                    ),
                  ))
              .id;
    } else {
      scaleId = existing.id;
      await (db.update(db.phenoScales)..where((s) => s.id.equals(scaleId))).write(
        PhenoScalesCompanion(version: Value(def.version), isDefault: Value(def.isDefault), updatedAt: Value(now)),
      );
    }

    final macros = {
      for (final m in await (db.select(db.phenoMacros)..where((m) => m.scaleId.equals(scaleId))).get()) m.code: m,
    };
    for (final (i, m) in def.macros.indexed) {
      final old = macros[m.code];
      if (old == null) {
        await db
            .into(db.phenoMacros)
            .insert(
              PhenoMacrosCompanion.insert(
                id: Value(Ids.macro(scaleId, m.code)),
                scaleId: scaleId,
                code: m.code,
                name: m.name,
                sortOrder: i,
              ),
            );
      } else {
        await (db.update(db.phenoMacros)..where((x) => x.id.equals(old.id))).write(
          PhenoMacrosCompanion(name: Value(m.name), sortOrder: Value(i), updatedAt: Value(now)),
        );
      }
    }

    final stages = {
      for (final s in await (db.select(db.phenoStages)..where((s) => s.scaleId.equals(scaleId))).get()) s.code: s,
    };
    for (final (i, s) in def.stages.indexed) {
      final old = stages[s.code];
      final fields = PhenoStagesCompanion(
        scaleId: Value(scaleId),
        code: Value(s.code),
        macroCode: Value(s.macro),
        sortOrder: Value(i),
        name: Value(s.name),
        description: Value(s.description),
        color: Value(s.color),
        updatedAt: Value(now),
      );
      if (old == null) {
        await db.into(db.phenoStages).insert(fields.copyWith(id: Value(Ids.stage(scaleId, s.code))));
      } else {
        await (db.update(db.phenoStages)..where((x) => x.id.equals(old.id))).write(fields);
      }
    }
  }
}
