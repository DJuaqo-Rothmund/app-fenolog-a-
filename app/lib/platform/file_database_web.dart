import 'dart:io';

import 'package:drift/drift.dart';

QueryExecutor openFileDatabase(File file) =>
    throw UnsupportedError('En la web no se abren copias de seguridad .zip; se usa la sincronización con Drive.');
