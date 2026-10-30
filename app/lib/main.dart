import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'data/crop_importer.dart';
import 'data/database.dart';
import 'providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es');

  final db = AppDatabase();
  await CropImporter(db).importBundled();

  runApp(ProviderScope(overrides: [databaseProvider.overrideWithValue(db)], child: const FramBitacoraApp()));
}
