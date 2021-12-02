performancePlot = \(x) {
  # https://stackoverflow.com/a/36344354

  count = sum(!is.na(x))
  mean = mean(x, na.rm = TRUE)
  sd = sd(x, na.rm = TRUE)
  sem = sd / sqrt(count)
  range = (max(x, na.rm = TRUE) - min(x, na.rm = TRUE))
  breaks = 30
  binwidth = range / breaks

  labelY = max(hist(x, breaks = breaks, plot = FALSE)$counts)

  makePlot = \(plotRange) {
    if (plotRange == "relative") {
      curveX = linspace(mean - 3*sd, mean + 3*sd, 100)
      labelX = mean + 3*sd
    } else if (plotRange == "absolute") {
      curveX = linspace(-0.05, 1.0, 1000)
      labelX = 1.0
    }

    annFmt = \(n) format(round(n, 5), nsmall=5)
    mcorrAnn = annotate(
      "text",
      label = glue('mean: {annFmt(mean)}\ns.err: {annFmt(sem)}\ns.dev: {annFmt(sd)}\nn: {count}'),
      family = "monospace",
      hjust = "right",
      vjust = "top",
      x = labelX, y = labelY
    )

    curveY = dnorm(curveX, mean = mean, sd = sd) * binwidth * count
    curveD = data.table(
      corr = curveX,
      count = curveY
    )

    ggplot(data.frame(x = x), aes(x)) +
      xlab("corr") +
      ylab("count") +
      geom_histogram(binwidth = binwidth) +
      geom_line(data = curveD, aes(x = corr, y = count)) +
      geom_vline(xintercept = mean, color = "green") +
      geom_vline(xintercept = mean - 2.5*sem, color = "green", alpha = 0.5) +
      geom_vline(xintercept = mean + 2.5*sem, color = "green", alpha = 0.5) +
      geom_vline(xintercept = mean - 2.5*sd, color = "blue", alpha = 0.5) +
      geom_vline(xintercept = mean + 2.5*sd, color = "blue", alpha = 0.5) +
      mcorrAnn +
      labs(
        title = glue('Distribution of corr ({plotRange})')
      )
  }

  results = new.env(parent = .GlobalEnv)
  results$relativePlot = makePlot("relative")
  results$absolutePlot = makePlot("absolute")

  results$count = count
  results$mean = mean
  results$sd = sd
  results$sem = sem
  results$range = range
  results$binwidth = binwidth
  results$shapiro.test = shapiro.test(x)
  results$t.test = t.test(x)

  class(results) <- append(class(results), "performancePlot")
  results
}

format.performancePlot = \(p) {
  sw = paste(capture.output(print(p$shapiro.test)), collapse = "\n")
  tt = paste(capture.output(print(p$t.test)), collapse = "\n")
  glue('performancePlot:
       count = {p$count}
        mean = {p$mean}
          sd = {p$sd}
         sem = {p$sem}
       range = {p$range}
    binwidth = {p$binwidth}
relativePlot = <ggplot plot object>
absolutePlot = <ggplot plot object>
      t.test = {tt}')
}

print.performancePlot = \(p, ...) cat(format(p), ...)
