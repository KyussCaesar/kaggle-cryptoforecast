import(db)

migration <- db$migration

MIGRATIONS = list(
  migration(
    name = 'trn create',
    up = '
    CREATE TABLE IF NOT EXISTS trn (
      ts TIMESTAMP WITH TIME ZONE
    , asset_id INTEGER
    , asset_name TEXT
    , target REAL
    , asset_weight REAL
    , open REAL
    , hi REAL
    , lo REAL
    , close REAL
    , num_trades INTEGER
    , num_units REAL
    , vwap REAL
    );',
  ),
  migration(
    name = 'trn distribute',
    up = 'SELECT CASE
      WHEN (SELECT count(*) FROM public.citus_tables WHERE table_name::TEXT = \'trn\') = 0
      THEN create_distributed_table(\'trn\', \'asset_id\')
      END;'
  ),
  migration(
    name = 'trn index asset_name',
    up = 'CREATE INDEX IF NOT EXISTS idx_trn_asset_name ON trn (asset_name);'
  ),
  migration(
    name = 'trn index asset_id',
    up = 'CREATE INDEX IF NOT EXISTS idx_trn_asset_id ON trn (asset_id);'
  ),
  migration(
    name = 'trn index ts',
    up = 'CREATE INDEX IF NOT EXISTS idx_trn_ts ON trn (ts);'
  ),
  migration(
    name = 'metrics create',
    up = 'CREATE TABLE IF NOT EXISTS metrics (
      run_id UUID PRIMARY KEY
    , started_at TIMESTAMP WITH TIME ZONE
    , finished_at TIMESTAMP WITH TIME ZONE
    , duration INTERVAL GENERATED ALWAYS AS (finished_at - started_at) STORED
    );'
  ),
  migration(
    name = 'metrics idx run_id',
    up = 'CREATE INDEX IF NOT EXISTS idx_metrics_run_id ON metrics(run_id);'
  )
)

db$runMigrations(MIGRATIONS)
