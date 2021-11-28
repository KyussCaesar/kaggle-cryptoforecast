import(run)

baselineTargetZero = \() {
  doRun(
    name = "baseline-target-zero test assets",
    trnAmt = 1,
    tstAmt = 60 * 24 * 7 * 2, # weeks
    assets = getAllAssets()[,asset_id],
    makeData = \(env, minDate, maxDate, assets, ...) {
      selectStmt = glue('
        SELECT asset_id, target
        FROM trn
        WHERE (ts BETWEEN $1 AND $2)
          AND asset_id IN ({paste(assets, collapse = ", ")})
      ')

      print(selectStmt)

      df = getQuery(selectStmt, params = list(minDate, maxDate))
      env$x = df[,"asset_id"]
      env$y = df[,"target"]
    },
    trainModel = \(model, trn, ...) {
      model$description = 'target(asset, t) = 0'
    },
    predictModel = \(model, tst, ...) {
      tst$yhat = vector(mode = "numeric", length = nrow(tst$x))
      tst$yhat[1:length(tst$yhat)] <- 0
    }
  )
}

baselineTargetZero()

for (i in 1:100) {
  baselineTargetZero()
}
