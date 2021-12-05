sanityCheckingPlot = \(pd, plotType) {
  # sample of data
  numPointsForPlot = 300
  plotStart = sample(pd[1:(nrow(pd) - numPointsForPlot),info_ts], 1)
  plotEnd = plotStart + as.difftime(numPointsForPlot, units = "mins")

  if (plotType == "features") {
    pd[
      info_asset_name == pd[sample(nrow(pd), 1),info_asset_name]
      & info_ts > plotStart
      & info_ts < plotEnd
    ] |>
      melt(id.vars = c("info_ts", "info_asset_name")) |>
      ggplot(aes(info_ts, value, colour = variable)) +
      geom_line() +
      facet_wrap(~ info_asset_name)
  } else if (plotType == "forecast") {
    pd[
      info_asset_name == pd[sample(nrow(pd), 1),info_asset_name]
      & info_ts > plotStart
      & info_ts < plotEnd,
      .(info_ts, info_asset_name, y, yhat)
    ] |>
      melt(id.vars = c("info_ts", "info_asset_name")) |>
      ggplot(aes(info_ts, value, colour = variable)) +
      geom_line() +
      facet_wrap(~ info_asset_name, ncol = 1)
  }
}

plotAroundBiggestY = \(pd) {
  maxy = max(pd[,y], na.rm = TRUE)
  maxts = pd[y == maxy,info_ts]
  maxasset = pd[y == maxy,info_asset_name]

  plotStart = maxts - as.difftime(100, units = "mins")
  plotEnd = maxts + as.difftime(100, units = "mins")
  pd[
    info_asset_name == maxasset
    & info_ts > plotStart
    & info_ts <= plotEnd,
    .(info_ts, y, yhat)
  ] |>
    melt(id.vars = "info_ts") |>
    ggplot(aes(x = info_ts, y = value, colour = variable)) +
    geom_line()
}

plotAroundBiggestE = \(pd) {
  maxe = max(pd$y - pd$yhat, na.rm = TRUE)
  maxrow = pd[(y - yhat) == maxe,]
  maxts = maxrow[,info_ts]
  maxasset = maxrow[,info_asset_name]

  plotStart = maxts - as.difftime(100, units = "mins")
  plotEnd = maxts + as.difftime(100, units = "mins")
  pd[
    info_asset_name == maxasset
  & info_ts > plotStart
  & info_ts <= plotEnd
  , .(info_ts, y, yhat)
  ] |>
    melt(id.vars = "info_ts") |>
    ggplot(aes(x = info_ts, y = value, colour = variable)) +
    geom_line()
}

getEvaluationLog = \(lgbm) {
  iteration = 1:lgbm$current_iter()
  getResult = \(dataset, metric) {
    data.table(
      iteration = iteration,
      dataset = dataset,
      metric = metric,
      value = lgb.get.eval.result(lgbm, dataset, metric)
    )
  }

  eval_log = rbind(
    getResult("trn", "l2"),
    getResult("tst", "l2")
  )

  eval_log
}

plotEvaluationLog = \(el) {
  bestIter = el[dataset == 'tst'][value == min(value),iteration]
  el |>
    ggplot(aes(x = iteration, y = value, colour = dataset)) +
    geom_line() +
    facet_wrap(~metric, scales = "free") +
    geom_vline(xintercept = bestIter, colour = "black", alpha = 0.5)
}
