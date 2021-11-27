getPool = \() {
  if (is.null(.GlobalEnv[["DBPOOL"]])) {
    .GlobalEnv[["DBPOOL"]] = dbPool(
      RPostgres::Postgres(),
      user = "citus",
      password = "citus",
      host = "citus-postgres",
      port = 5432,
      dbname = "citus"
    )

    reg.finalizer(.GlobalEnv[["DBPOOL"]], \(p) poolClose(p), onexit = TRUE)
  }

  .GlobalEnv[["DBPOOL"]]
}

migration = \(name, up, down = NULL) {
  m = list(
    name = name,
    up = up,
    down = down
  )

  class(m) <- "migration"
  m
}

format.migration = \(m) {
  glue('Migration: {m[["name"]]}
UP:
{m[["up"]]}

DOWN:
{m[["down"]]}
')
}

print.migration = \(m, ...) cat(format(m, ...), "\n")

is.migration = \(m) inherits(m, "migration")

migrationUp = \(m, ...) UseMethod("migrationUp", m)
migrationUp.migration = \(m, conn) {
  loginfo('Migrate UP(%s)', m[["name"]])
  dbExecute(conn, m[["up"]])
}

runMigrations = \(migrations) {
  for (m in migrations) if (!is.migration(m)) stop('Item is not a migration: ', format(m))

  poolWithTransaction(getPool(), \(conn) {
    for (m in migrations) migrationUp(m, conn)
  })
}

getNewRunId = \() dbGetQuery(getPool(), 'SELECT gen_random_uuid()')[1,'gen_random_uuid']
