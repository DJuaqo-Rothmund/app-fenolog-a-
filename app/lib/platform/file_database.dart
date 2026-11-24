/// Abre una base SQLite guardada en un archivo (solo en el teléfono: la web no
/// restaura copias `.zip`).
library;

export 'file_database_web.dart' if (dart.library.ffi) 'file_database_native.dart';
