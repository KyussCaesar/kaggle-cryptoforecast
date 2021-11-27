#' Create a new progress bar.
pbar = \(msg, total) {
  pb <-
    progress_bar$new(
      total = total,
      clear = FALSE,
      format = sprintf("%s [:bar] :current/:total (:percent) :elapsed elapsed (:eta remain, :tick_rate/s)", msg),
      width = 110,
      show_after = 0
    )
  pb
}

#' Print an expression and it's value
#' Returns the value, invisibly
debugit = function(x) {
  var = deparse(substitute(x))
  val = eval(x)
  loginfo(paste(var, "=", val))
  invisible(val)
}

#' Return the cardinality (number of unique elements in) x.
cardinality = function(x) length(unique(x))

#' Root-mean-square
rms = \(x) sqrt(mean(x*x))

#' Subtract mean and divide by (uncorrected) standard deviation
standardiser = \(x) {
  s = list(
    mean = mean(x),
    sd = sd(x)
  )

  class(s) <- c("standardiser")
  s
}

predict.standardiser = \(s, x) (x - s$mean) / s$sd

#' Create a plot from formula
plotf = function(df, f, geom=geom_point, verbose=FALSE) {

  msg =
    if (verbose) {
      function(...) {
        message("plotf: ", ...)
      }
    } else {
      function(...) {}
    }

  # instantiate geom
  if (is.function(geom)) {
    msg("instantiate geom")
    geom = geom()
  }

  # resolve column name
  resolve_colname = function(nn, env = environment(), depth = 0) {
    nn = as.character(nn)

    msg("resolve colname: ", nn, " depth: ", depth)

    if (is.null(nn)) {
      stop("could not resolve ", nn)
    }

    if (depth > 32) {
      stop("recursion error while trying to resolve ", nn)
    }

    if (nn %in% names(df)) {
      msg("resolve colname: found: ", nn)
      return(nn)
    }

    next_try =
      if (nn %in% names(env)) {
        env[[nn]]
      } else {
        nn
      }

    msg("resolve colname: next_try: ", next_try)
    return(resolve_colname(next_try, env = parent.env(env), depth = depth + 1))
  }

  # processing for colour col
  # if low cardinality, coerce to character
  # otherwise leave it
  colour_col = function(nn) {
    msg("check colour col: ", nn)

    n_colours = cardinality(df[[nn]])

    if (n_colours < 30) {
      msg("converting colour col: ", nn)
      df[[nn]] <<- as.character(df[[nn]])
    }
  }

  # processing for faceting cols
  # if not character replace col with `colname=col`
  # nice for ggplot, if you have faceting variables that are just numbers and you
  # forget which axis is which in the facet plot
  facet_col = function(nn) {
    msg("check facet col: ", nn)

    if (!is.character(df[[nn]])) {
      msg("convert facet col: ", nn)
      df[[nn]] <<- paste0(nn, "=", df[[nn]])
    }
  }

  # for boxplot, you want the x to be factor
  boxplot_col = function(nn) {
    msg("check boxplot col: ", nn)

    if (
      "GeomBoxplot" %in% class(geom$geom) ||
        "GeomViolin" %in% class(geom$geom)
    ) {
      msg("convert boxplot col: ", nn)
      df[[nn]] <<- sprintf("%02i", df[[nn]])
    }
  }

  p <- NULL
  if (length(f) == 2) {
    x = resolve_colname(f[[2]])

    msg("histogram: ", x)

    p <- function() {
      ggplot(df, aes_(x=as.name(x))) +
        geom_histogram()
    }

  } else if (length(f) == 3) {
    # scatter plot
    y = f[[2]]
    x = f[[3]]

    if (length(y) != 1) stop("bad formula")

    if (length(x) == 1) {
      y = resolve_colname(y)
      x = resolve_colname(x)

      msg("scatter: x: ", x, " y: ", y)
      boxplot_col(x)

      p <- function() {
        ggplot(df, aes_(x=as.name(x), y=as.name(y))) + geom
      }
    }

    if (length(x) == 3) {
      # scatter with colour
      colour = x[[3]]
      x = x[[2]]

      if (length(x) == 1) {
        y = resolve_colname(y)
        x = resolve_colname(x)
        colour = resolve_colname(colour)

        msg("scatter with colour: x: ", x, " y: ", y, " colour: ", colour)
        boxplot_col(x)
        colour_col(colour)

        p <- function() {
          ggplot(df, aes_(y=as.name(y), x=as.name(x), colour=as.name(colour))) + geom
        }
      }

      if (length(x) == 3) {
        # scatter with colour and wrap
        wrap = colour
        colour = x[[3]]
        x = x[[2]]

        if (length(x) == 1) {
          y = resolve_colname(y)
          x = resolve_colname(x)
          colour = resolve_colname(colour)
          wrap = resolve_colname(wrap)

          boxplot_col(x)
          colour_col(colour)
          facet_col(wrap)

          p <- function() {
            ggplot(df, aes_(y=as.name(y), x=as.name(x), colour=as.name(colour))) +
              geom +
              facet_wrap(as.name(wrap))
          }
        }

        if (length(x) == 3) {
          # scatter with colour and grid
          grid = wrap
          wrap = colour
          colour = x[[3]]
          x = x[[2]]

          if (length(x) == 1) {
            y = resolve_colname(y)
            x = resolve_colname(x)
            colour = resolve_colname(colour)
            wrap = resolve_colname(wrap)
            grid = resolve_colname(grid)

            boxplot_col(x)
            colour_col(colour)
            facet_col(wrap)
            facet_col(grid)

            p <- function() {
              ggplot(df, aes_(y=as.name(y), x=as.name(x), colour=as.name(colour))) +
                geom +
                facet_grid(
                  rows = as.name(grid),
                  cols = as.name(wrap)
                )
            }

          } else {
            stop("bad formula")
          }

        }

      }

    }

  } else {
    # error
    stop("bad formula")
  }

  msg("generating plot...")
  return(p())
}
