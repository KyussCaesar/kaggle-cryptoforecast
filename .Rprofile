Sys.setenv(TZ = "Pacific/Auckland")

dub = \(x, pattern, replacement) sub(pattern, replacement, x, fixed = TRUE)
gdub = \(x, pattern, replacement) gsub(pattern, replacement, x, fixed = TRUE)

as.path.modulename = \(modulename, ...) paste0(here::here(), "/", modulename |> gdub(".", "/") |> paste0(".R"))

import = \(thing, ...) {
  modulename = deparse(substitute(thing))
  path = as.path.modulename(modulename)

  if (file.exists(path)) return(import.path(path, ...))

  UseMethod("import", thing)
}

import.path = \(path, reload = FALSE) {
  stopifnot(length(path) == 1, endsWith(path, ".R"))

  p = here::here(path)

  name = p |>
    dub(paste0(here::here(), "/"), "") |>
    dub("/", ".") |>
    dub(".R", "")

  oldE = .GlobalEnv[[p]]
  if (!is.null(oldE)) {
    if (!reload) {
      return(oldE)
    }
  }

  newE = new.env(parent = .GlobalEnv)
  newE$module.path = path

  source(p)#, local = newE)

  .GlobalEnv[[p]] = TRUE #newE
  invisible(newE)
}

import.environment = \(e, ...) import.path(e$module.path, ...)
import.character = \(path, ...) import.path(path, ...)

reImport = \(mod, reload = TRUE, ...) {
  modulename = deparse(substitute(mod))
  path = as.path.modulename(modulename)
  import.path(path, reload = reload, ...)
}

# importFrom = \(mod, ...) UseMethod("importFrom", mod)
# importFrom.environment = \(mod, what, local = .GlobalEnv) {
#   whatName = deparse(substitute(what))
#   whatVal = mod[[whatName]]
#
#   stopifnot(!is.null(whatVal))
#   local[[whatName]] = whatVal
#   invisible(whatVal)
# }

source(here::here("prelude.R"))
