import 'package:postgres/postgres.dart';

/// Tablas que la app puede sincronizar. Cualquier otra se rechaza.
const syncTables = {
  'crops',
  'pheno_scales',
  'pheno_macros',
  'pheno_stages',
  'varieties',
  'projects',
  'seasons',
  'units',
  'week_statuses',
  'observations',
  'photos',
  'measurement_defs',
  'measurement_values',
};

/// Crea las tablas del servidor si no existen.
///
/// El servidor no conoce las columnas de cada tabla de la app: guarda cada
/// fila como JSON, con su fecha de modificación y un número correlativo
/// ([seq]) que permite a cada teléfono pedir «lo nuevo desde la última vez».
Future<void> migrate(Session db) async {
  for (final sql in [
    '''CREATE TABLE IF NOT EXISTS users (
      id TEXT PRIMARY KEY,
      email TEXT NOT NULL UNIQUE,
      name TEXT NOT NULL DEFAULT '',
      role TEXT NOT NULL CHECK (role IN ('owner', 'editor', 'viewer')),
      password_hash TEXT NOT NULL,
      disabled BOOLEAN NOT NULL DEFAULT FALSE,
      created_at TIMESTAMPTZ NOT NULL DEFAULT now()
    )''',
    '''CREATE TABLE IF NOT EXISTS tokens (
      token_hash TEXT PRIMARY KEY,
      user_id TEXT NOT NULL REFERENCES users(id),
      device TEXT NOT NULL DEFAULT '',
      created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
      last_used_at TIMESTAMPTZ NOT NULL DEFAULT now()
    )''',
    'CREATE SEQUENCE IF NOT EXISTS sync_seq',
    '''CREATE TABLE IF NOT EXISTS sync_rows (
      tbl TEXT NOT NULL,
      id TEXT NOT NULL,
      data JSONB NOT NULL,
      updated_at BIGINT NOT NULL,
      seq BIGINT NOT NULL,
      updated_by TEXT NOT NULL,
      received_at TIMESTAMPTZ NOT NULL DEFAULT now(),
      PRIMARY KEY (tbl, id)
    )''',
    'CREATE INDEX IF NOT EXISTS sync_rows_seq ON sync_rows (seq)',
    '''CREATE TABLE IF NOT EXISTS photo_files (
      id TEXT PRIMARY KEY,
      size BIGINT NOT NULL,
      uploaded_by TEXT NOT NULL,
      uploaded_at TIMESTAMPTZ NOT NULL DEFAULT now()
    )''',
  ]) {
    await db.execute(sql);
  }
}
