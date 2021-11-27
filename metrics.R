import(db)

mt.started_at = \(run_id, ts = NULL) {
  started_at = ts
  if (is.null(started_at)) started_at = Sys.time()

  stopifnot("POSIXct" %in% class(started_at))
  dbExecute(
    db$getPool(),
    'INSERT INTO metrics (run_id, started_at) VALUES ($1, $2) ON CONFLICT (run_id) DO UPDATE SET started_at = $2;',
    params = list(run_id, started_at)
  )
}

mt.finished_at = \(run_id, ts = NULL) {
  finished_at = ts
  if (is.null(finished_at)) finished_at = Sys.time()

  stopifnot("POSIXct" %in% class(finished_at))
  dbExecute(
    db$getPool(),
    'INSERT INTO metrics (run_id, finished_at) VALUES ($1, $2) ON CONFLICT (run_id) DO UPDATE SET finished_at = $2;',
    params = list(run_id, finished_at)
  )
}
