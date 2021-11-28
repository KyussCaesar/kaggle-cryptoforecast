import(db)

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
  ),
  migration(
    name = 'metrics add name',
    up = 'ALTER TABLE metrics ADD COLUMN IF NOT EXISTS name TEXT;'
  ),
  migration(
    name = 'metrics add mae',
    up = 'ALTER TABLE metrics ADD COLUMN IF NOT EXISTS mae REAL;'
  ),
  migration(
    name = 'metrics add aae',
    up = 'ALTER TABLE metrics ADD COLUMN IF NOT EXISTS aae REAL;'
  ),
  migration(
    name = 'metrics add rmse',
    up = 'ALTER TABLE metrics ADD COLUMN IF NOT EXISTS rmse REAL;'
  ),
  migration(
    name = 'metrics add trn_amt',
    up = 'ALTER TABLE metrics ADD COLUMN IF NOT EXISTS trn_amt INTEGER;'
  ),
  migration(
    name = 'metrics add tst_amt',
    up = 'ALTER TABLE metrics ADD COLUMN IF NOT EXISTS tst_amt INTEGER;'
  ),
  migration(
    name = 'metrics add trn_min_date',
    up = 'ALTER TABLE metrics ADD COLUMN IF NOT EXISTS trn_min_date TIMESTAMP WITH TIME ZONE;'
  ),
  migration(
    name = 'metrics add trn_max_date',
    up = 'ALTER TABLE metrics ADD COLUMN IF NOT EXISTS trn_max_date TIMESTAMP WITH TIME ZONE;'
  ),
  migration(
    name = 'metrics add tst_min_date',
    up = 'ALTER TABLE metrics ADD COLUMN IF NOT EXISTS tst_min_date TIMESTAMP WITH TIME ZONE;'
  ),
  migration(
    name = 'metrics add tst_max_date',
    up = 'ALTER TABLE metrics ADD COLUMN IF NOT EXISTS tst_max_date TIMESTAMP WITH TIME ZONE;'
  ),
  migration(
    name = 'metrics add mk_trn_started_at',
    up = 'ALTER TABLE metrics ADD COLUMN IF NOT EXISTS mk_trn_started_at TIMESTAMP WITH TIME ZONE;'
  ),
  migration(
    name = 'metrics add mk_trn_finished_at',
    up = 'ALTER TABLE metrics ADD COLUMN IF NOT EXISTS mk_trn_finished_at TIMESTAMP WITH TIME ZONE;'
  ),
  migration(
    name = 'metrics add mk_trn_duration',
    up = 'ALTER TABLE metrics ADD COLUMN IF NOT EXISTS mk_trn_duration INTERVAL GENERATED ALWAYS AS (mk_trn_finished_at - mk_trn_started_at) STORED;'
  ),
  migration(
    name = 'metrics add mk_tst_started_at',
    up = 'ALTER TABLE metrics ADD COLUMN IF NOT EXISTS mk_tst_started_at TIMESTAMP WITH TIME ZONE;'
  ),
  migration(
    name = 'metrics add mk_tst_finished_at',
    up = 'ALTER TABLE metrics ADD COLUMN IF NOT EXISTS mk_tst_finished_at TIMESTAMP WITH TIME ZONE;'
  ),
  migration(
    name = 'metrics add mk_tst_duration',
    up = 'ALTER TABLE metrics ADD COLUMN IF NOT EXISTS mk_tst_duration INTERVAL GENERATED ALWAYS AS (mk_tst_finished_at - mk_tst_started_at) STORED;'
  ),
  migration(
    name = 'metrics add model_fit_started_at',
    up = 'ALTER TABLE metrics ADD COLUMN IF NOT EXISTS model_fit_started_at TIMESTAMP WITH TIME ZONE;'
  ),
  migration(
    name = 'metrics add model_fit_finished_at',
    up = 'ALTER TABLE metrics ADD COLUMN IF NOT EXISTS model_fit_finished_at TIMESTAMP WITH TIME ZONE;'
  ),
  migration(
    name = 'metrics add model_fit_duration',
    up = 'ALTER TABLE metrics ADD COLUMN IF NOT EXISTS model_fit_duration INTERVAL GENERATED ALWAYS AS (model_fit_finished_at - model_fit_started_at) STORED;'
  ),
  migration(
    name = 'metrics add model_predict_started_at',
    up = 'ALTER TABLE metrics ADD COLUMN IF NOT EXISTS model_predict_started_at TIMESTAMP WITH TIME ZONE;'
  ),
  migration(
    name = 'metrics add model_predict_finished_at',
    up = 'ALTER TABLE metrics ADD COLUMN IF NOT EXISTS model_predict_finished_at TIMESTAMP WITH TIME ZONE;'
  ),
  migration(
    name = 'metrics add model_predict_duration',
    up = 'ALTER TABLE metrics ADD COLUMN IF NOT EXISTS model_predict_duration INTERVAL GENERATED ALWAYS AS (model_predict_finished_at - model_predict_started_at) STORED;'
  ),
  migration(
    name = 'metrics add num_evaluation_samples',
    up = 'ALTER TABLE metrics ADD COLUMN IF NOT EXISTS num_evaluation_samples INTEGER'
  ),
  migration(
    name = 'metrics add corr',
    up = 'ALTER TABLE metrics ADD COLUMN IF NOT EXISTS corr REAL;'
  ),
  migration(
    name = 'metrics add description',
    up = 'ALTER TABLE metrics ADD COLUMN IF NOT EXISTS description TEXT;'
  )
)

runMigrations(MIGRATIONS)
