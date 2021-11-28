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

  loginfo('%s metric %s = %s', m$runId, metricName, format(metric))
  dbExecute(getPool(), insertStmt, params = list(m$runId, metric))
}

getMetric = \(m, ...) UseMethod("getMetric", m)
getMetric.metrics = \(m, metric) {
  metricName = deparse(substitute(metric))
  stopifnot(metricName %in% dbListFields(getPool(), 'metrics'))

  selectStmt = glue('SELECT {metricName} FROM metrics WHERE run_id = $1')

  getQuery(selectStmt, params = list(m$runId))
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

mt.aae = \(m, ...) UseMethod("mt.aae", m)
mt.aae.metrics = \(m, aae) {
  stopifnot(is.numeric(aae), length(aae) == 1)
  upsertMetric(m, aae)
}

mt.rmse = \(m, ...) UseMethod("mt.rmse", m)
mt.rmse.metrics = \(m, rmse) {
  stopifnot(is.numeric(rmse), length(rmse) == 1)
  upsertMetric(m, rmse)
}

mt.trn_amt = \(m, ...) UseMethod("mt.trn_amt", m)
mt.trn_amt.metrics = \(m, trn_amt) {
  stopifnot(is.numeric(trn_amt), length(trn_amt) == 1)
  upsertMetric(m, trn_amt)
}

mt.tst_amt = \(m, ...) UseMethod("mt.tst_amt", m)
mt.tst_amt.metrics = \(m, tst_amt) {
  stopifnot(is.numeric(tst_amt), length(tst_amt) == 1)
  upsertMetric(m, tst_amt)
}

mt.trn_min_date = \(m, ...) UseMethod("mt.trn_min_date", m)
mt.trn_min_date.metrics = \(m, trn_min_date) {
  stopifnot("POSIXct" %in% class(trn_min_date), length(trn_min_date) == 1)
  upsertMetric(m, trn_min_date)
}

mt.trn_max_date = \(m, ...) UseMethod("mt.trn_max_date", m)
mt.trn_max_date.metrics = \(m, trn_max_date) {
  stopifnot("POSIXct" %in% class(trn_max_date), length(trn_max_date) == 1)
  upsertMetric(m, trn_max_date)
}

mt.tst_min_date = \(m, ...) UseMethod("mt.tst_min_date", m)
mt.tst_min_date.metrics = \(m, tst_min_date) {
  stopifnot("POSIXct" %in% class(tst_min_date), length(tst_min_date) == 1)
  upsertMetric(m, tst_min_date)
}

mt.tst_max_date = \(m, ...) UseMethod("mt.tst_max_date", m)
mt.tst_max_date.metrics = \(m, tst_max_date) {
  stopifnot("POSIXct" %in% class(tst_max_date), length(tst_max_date) == 1)
  upsertMetric(m, tst_max_date)
}

mt.mk_trn_started_at = \(m, ...) UseMethod("mt.mk_trn_started_at", m)
mt.mk_trn_started_at.metrics = \(m, ts = NULL) {
  mk_trn_started_at = ts
  if (is.null(mk_trn_started_at)) mk_trn_started_at = Sys.time()

  stopifnot("POSIXct" %in% class(mk_trn_started_at))
  upsertMetric(m, mk_trn_started_at)
}

mt.mk_trn_finished_at = \(m, ...) UseMethod("mt.mk_trn_finished_at", m)
mt.mk_trn_finished_at.metrics = \(m, ts = NULL) {
  mk_trn_finished_at = ts
  if (is.null(mk_trn_finished_at)) mk_trn_finished_at = Sys.time()

  stopifnot("POSIXct" %in% class(mk_trn_finished_at))
  upsertMetric(m, mk_trn_finished_at)
}

mt.mk_tst_started_at = \(m, ...) UseMethod("mt.mk_tst_started_at", m)
mt.mk_tst_started_at.metrics = \(m, ts = NULL) {
  mk_tst_started_at = ts
  if (is.null(mk_tst_started_at)) mk_tst_started_at = Sys.time()

  stopifnot("POSIXct" %in% class(mk_tst_started_at))
  upsertMetric(m, mk_tst_started_at)
}

mt.mk_tst_finished_at = \(m, ...) UseMethod("mt.mk_tst_finished_at", m)
mt.mk_tst_finished_at.metrics = \(m, ts = NULL) {
  mk_tst_finished_at = ts
  if (is.null(mk_tst_finished_at)) mk_tst_finished_at = Sys.time()

  stopifnot("POSIXct" %in% class(mk_tst_finished_at))
  upsertMetric(m, mk_tst_finished_at)
}

mt.model_fit_started_at = \(m, ...) UseMethod("mt.model_fit_started_at", m)
mt.model_fit_started_at.metrics = \(m, ts = NULL) {
  model_fit_started_at = ts
  if (is.null(model_fit_started_at)) model_fit_started_at = Sys.time()

  stopifnot("POSIXct" %in% class(model_fit_started_at))
  upsertMetric(m, model_fit_started_at)
}

mt.model_fit_finished_at = \(m, ...) UseMethod("mt.model_fit_finished_at", m)
mt.model_fit_finished_at.metrics = \(m, ts = NULL) {
  model_fit_finished_at = ts
  if (is.null(model_fit_finished_at)) model_fit_finished_at = Sys.time()

  stopifnot("POSIXct" %in% class(model_fit_finished_at))
  upsertMetric(m, model_fit_finished_at)
}

mt.model_predict_started_at = \(m, ...) UseMethod("mt.model_predict_started_at", m)
mt.model_predict_started_at.metrics = \(m, ts = NULL) {
  model_predict_started_at = ts
  if (is.null(model_predict_started_at)) model_predict_started_at = Sys.time()

  stopifnot("POSIXct" %in% class(model_predict_started_at))
  upsertMetric(m, model_predict_started_at)
}

mt.model_predict_finished_at = \(m, ...) UseMethod("mt.model_predict_finished_at", m)
mt.model_predict_finished_at.metrics = \(m, ts = NULL) {
  model_predict_finished_at = ts
  if (is.null(model_predict_finished_at)) model_predict_finished_at = Sys.time()

  stopifnot("POSIXct" %in% class(model_predict_finished_at))
  upsertMetric(m, model_predict_finished_at)
}

mt.num_evaluation_samples = \(m, ...) UseMethod("mt.num_evaluation_samples", m)
mt.num_evaluation_samples.metrics = \(m, num_evaluation_samples) {
  stopifnot(is.numeric(num_evaluation_samples), length(num_evaluation_samples) == 1)
  upsertMetric(m, num_evaluation_samples)
}

mt.corr = \(m, ...) UseMethod("mt.corr", m)
mt.corr.metrics = \(m, corr) {
  stopifnot(is.numeric(corr), length(corr) == 1)
  upsertMetric(m, corr)
}

mt.description = \(m, ...) UseMethod("mt.description", m)
mt.description.metrics = \(m, description) {
  stopifnot(is.character(description), length(description) == 1)
  upsertMetric(m, description)
}
