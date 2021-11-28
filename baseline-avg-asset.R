import(run)

baselineAvgAsset = \() doRun(
  name = "baseline-avg-asset 1wk.trn 2wk.tst",
  trnAmt = 60 * 24 * 7 * 1, # weeks
  tstAmt = 60 * 24 * 7 * 2, # weeks
  assets = getAllAssets()[,asset_id],
  makeData = \(env, minDate, maxDate, assets, ...) {
    # TODO filter by assets
    df = getQuery('SELECT asset_id, target FROM trn WHERE ts BETWEEN $1 AND $2;', params = list(minDate, maxDate))
    env$x = df[,"asset_id"]
    env$y = df[,"target"]
  },
  trainModel = \(model, trn, ...) {
    model$description = 'target(asset, t) = mean(target(asset)) over training period'

    model$getKeyForAsset = \(a) paste("asset-", a)
    for (a in unique(trn$x[,asset_id])) {
      idx = trn$x[,asset_id] == a
      key = model$getKeyForAsset(a)
      prediction = mean(trn$y[idx,target], na.rm = TRUE)
      if (is.na(prediction)) prediction = 0
      model[[key]] = prediction
    }
  },
  predictModel = \(model, tst, ...) {
    tst$yhat = vector(mode = "numeric", length = nrow(tst$x))
    tst$yhat[1:length(tst$yhat)] <- NA

    for (a in unique(tst$x[,asset_id])) {
      idx = tst$x[,asset_id] == a
      key = model$getKeyForAsset(a)
      tst$yhat[idx] <- model[[key]]
    }
  }
)

for (i in 1:100) {
  baselineAvgAsset()
}
