library(DBI)
library(data.table)
library(ggplot2)
library(dplyr)

conn <- DBI::dbConnect(
  RPostgres::Postgres(),
  user = "citus",
  password = "citus",
  host = "citus-postgres",
  port = 5432,
  dbname = "citus",
)

dbListTables(conn)

df = dbGetQuery(conn, "SELECT * FROM trn WHERE asset_name = 'Bitcoin'")
setDT(df)

head(df)

df$ts = as.integer(df$ts)
df$asset_id <- NULL
df$asset_name <- NULL
df$asset_weight <- NULL

model <- lm(target ~ ., df)
model

df$prediction = predict(model, df)

db_table = "lm_results_bitcoin"
dbRemoveTable(conn, db_table)

dbCreateTable(conn, db_table, df)
dbAppendTable(conn, db_table, df)

dbDisconnect(conn)
