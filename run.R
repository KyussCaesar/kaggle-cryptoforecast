import(db)
import(metrics)
import(util)

getAllTs = \() {
  if (is.null(.GlobalEnv[["ALL_TS"]])) {
    loginfo('Sourcing ALL_TS')
    .GlobalEnv[["ALL_TS"]] = getQuery('SELECT DISTINCT ts FROM trn WHERE target IS NOT NULL ORDER BY ts ASC;')
  }

  .GlobalEnv[["ALL_TS"]]
}

getAllAssets = \() {
  if (is.null(.GlobalEnv[["ALL_ASSETS"]])) {
    loginfo('Sourcing ALL_ASSETS')
    .GlobalEnv[["ALL_ASSETS"]] = getQuery('SELECT DISTINCT asset_id, asset_name FROM trn ORDER BY asset_id ASC;')
  }

  .GlobalEnv[["ALL_ASSETS"]]
}

doRun = \(name, trnAmt, tstAmt, assets, makeData, trainModel, predictModel) {
  ms = metrics()
  mt.name(ms, name)
  mt.trn_amt(ms, trnAmt)
  mt.tst_amt(ms, tstAmt)

  dts = getAllTs()

  lastTrainIdx = sample(trnAmt:(nrow(dts) - tstAmt - 15 - 1), 1)

  trnMinDate = dts[lastTrainIdx - trnAmt + 1,ts]
  trnMaxDate = dts[lastTrainIdx,ts]
  mt.trn_min_date(ms, trnMinDate)
  mt.trn_max_date(ms, trnMaxDate)

  tstMinDate = dts[lastTrainIdx + 15 + 1,ts]
  tstMaxDate = dts[lastTrainIdx + 15 + tstAmt,ts]
  mt.tst_min_date(ms, tstMinDate)
  mt.tst_max_date(ms, tstMaxDate)

  mt.started_at(ms)

  mt.mk_trn_started_at(ms)
  trn = new.env()
  makeData(
    env = trn,
    minDate = trnMinDate,
    maxDate = trnMaxDate,
    assets = assets,
    ms = ms
  )
  mt.mk_trn_finished_at(ms)

  stopifnot(!is.null(trn$x), !is.null(trn$y))

  mt.model_fit_started_at(ms)
  model = new.env()
  trainModel(
    model = model,
    trn = trn,
    ms = ms
  )
  mt.model_fit_finished_at(ms)

  if (!is.null(model$description)) mt.description(ms, model$description)

  mt.mk_tst_started_at(ms)
  tst = new.env()
  makeData(
    env = tst,
    minDate = tstMinDate,
    maxDate = tstMaxDate,
    assets = assets,
    ms = ms
  )
  mt.mk_tst_finished_at(ms)

  stopifnot(!is.null(tst$x), !is.null(tst$y))

  mt.model_predict_started_at(ms)
  predictModel(
    model = model,
    tst = tst,
    ms = ms
  )
  mt.model_predict_finished_at(ms)

  stopifnot(!is.null(tst$yhat))

  mt.finished_at(ms)

  validTargets = !is.na(tst$y[,target])
  mt.num_evaluation_samples(ms, sum(validTargets))

  y = tst$y[validTargets,target]
  yhat = tst$yhat[validTargets]
  error = y - yhat

  mt.corr(ms, cor(yhat, y))
  mt.mae(ms, median(abs(error)))
  mt.aae(ms, mean(abs(error)))
  mt.rmse(ms, rms(abs(error)))

  list(
    ms = ms,
    trn = trn,
    tst = tst,
    model = model
  )
}
