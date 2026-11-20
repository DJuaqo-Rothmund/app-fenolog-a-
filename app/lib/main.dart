import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'data/crop_importer.dart';
import 'data/database.dart';
import 'data/photo_store.dart';
import 'providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es');

  final db = AppDatabase();
  await CropImporter(db).importBundled();

  final docs = await getApplicationDocumentsDirectory();
  final temp = await getTemporaryDirectory();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        photoStoreProvider.overrideWithValue(PhotoStore(docs.path)),
        tempDirProvider.overrideWithValue(temp.path),
        preferencesProvider.overrideWithValue(prefs),
      ],
      child: const FramBitacoraApp(),
    ),
  );
}
