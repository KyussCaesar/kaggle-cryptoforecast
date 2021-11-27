library(DBI)

import(db)

metrics = \() {
  m = list(
    runId = getNewRunId()
  )

  class(m) = "metrics"
  m
}

upsertMetric = \(m, ...) UseMethod("upsertMetric", m)
upsertMetric.metrics = \(m, metric) {
  metricName = deparse(substitute(metric))
  stopifnot(metricName %in% dbListFields(getPool(), 'metrics'))

  insertStmt = glue('
    INSERT INTO metrics (run_id, {metricName})
    VALUES ($1, $2)
    ON CONFLICT (run_id)
    DO UPDATE SET {metricName} = $2
  ;')

  dbExecute(getPool(), insertStmt, params = list(m$runId, metric))
}

mt.started_at = \(m, ...) UseMethod("mt.started_at", m)
mt.started_at.metrics = \(m, ts = NULL) {
  started_at = ts
  if (is.null(started_at)) started_at = Sys.time()

  stopifnot("POSIXct" %in% class(started_at))
  upsertMetric(m, started_at)
}

mt.finished_at = \(m, ...) UseMethod("mt.finished_at", m)
mt.finished_at.metrics = \(m, ts = NULL) {
  finished_at = ts
  if (is.null(finished_at)) finished_at = Sys.time()

  stopifnot("POSIXct" %in% class(finished_at))
  upsertMetric(m, finished_at)
}

mt.name = \(m, ...) UseMethod("mt.name", m)
mt.name.metrics = \(m, name) {
  stopifnot(is.character(name), length(name) == 1)
  upsertMetric(m, name)
}

mt.mae = \(m, ...) UseMethod("mt.mae", m)
mt.mae.metrics = \(m, mae) {
  stopifnot(is.numeric(mae), length(mae) == 1)
  upsertMetric(m, mae)
}
