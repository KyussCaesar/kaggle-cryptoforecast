rpkgs = c(
  "data.table",
  "ggplot2",
  "plotly",
  "lightgbm",
  "DBI",
  "RPostgres",
  "dbplyr",
  "logging",
  "pool",
  "here",
  "glue",
  "progress",
  "rmarkdown"
)

for (p in rpkgs) {
  if (!(p %in% rownames(utils::installed.packages()))) {
    packageStartupMessage("\n==== INSTALL PKG ", p, "\n")
    utils::install.packages(p)
  }

  packageStartupMessage("\n==== LOAD PKG ", p, "\n")

  # some pkgs load _SO MUCH STUFF_
  # others, I really only want a couple things at most.
  # skip loading if they are in this list
  # can always refer to objects by pkg::object
  dontload = c(
    "R.utils",
    "plotly",
    "logging",
    "qs",
    "pryr",
    "flexdashboard",
    "zoo",
    "igraph",
    "Ckmeans.1d.dp",
    "here",
    "RPostgres",
    # almost never needed in scripts, just RStudio
    "rmarkdown",
    "markdown"
  )

  if (p %in% dontload) {
    packageStartupMessage("(not attached)")
  } else {
    library(p, character.only = TRUE)
  }
}
