import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'data/backup.dart';
import 'data/crop_importer.dart';
import 'data/database.dart';
import 'providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es');

  // Un respaldo elegido en «Restaurar» se instala antes de abrir la base.
  final backup = BackupService(getApplicationDocumentsDirectory);
  final restored = !kIsWeb && await backup.applyPendingRestore();

  final db = AppDatabase();
  if (restored) await backup.relocatePhotos(db);
  await CropImporter(db).importBundled();

  runApp(ProviderScope(overrides: [databaseProvider.overrideWithValue(db)], child: const FramBitacoraApp()));
}
