import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:frambitacora/data/crop_importer.dart';
import 'package:frambitacora/data/database.dart';
import 'package:frambitacora/domain/crop_definition.dart';

/// Base de datos en memoria con el frambueso ya cargado.
Future<AppDatabase> testDatabase() async {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  final db = AppDatabase(NativeDatabase.memory());
  await CropImporter(db).importDefinition(raspberryDefinition());
  return db;
}

CropDefinition raspberryDefinition() => CropDefinition.fromJson(
  jsonDecode(File('assets/crops/rubus-idaeus.json').readAsStringSync()) as Map<String, dynamic>,
);
