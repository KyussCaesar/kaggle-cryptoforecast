library(data.table)
library(DBI)

import(db)
import(util)

trn = fread("data/train.csv")

# fix the names
setnames(trn, "timestamp", "ts")
setnames(trn, "Asset_ID", "asset_id")
setnames(trn, "Count", "num_trades")
setnames(trn, "Open", "open")
setnames(trn, "High", "hi")
setnames(trn, "Low", "lo")
setnames(trn, "Close", "close")
setnames(trn, "Volume", "num_units")
setnames(trn, "VWAP", "vwap")
setnames(trn, "Target", "target")

# fix the types
trn$ts = as.POSIXct(trn$ts, origin = "1970-01-01")
trn$asset_id = as.integer(trn$asset_id)
trn$num_trades = as.integer(trn$num_trades)

# enrich
details = fread("data/asset_details.csv")
setnames(details, "Asset_ID", "asset_id")
setnames(details, "Weight", "asset_weight")
setnames(details, "Asset_Name", "asset_name")
details$asset_id = as.integer(details$asset_id)

trn = merge(trn, details, by = "asset_id")

# do load

batchSize = 10000
numBatches = ceiling(nrow(trn) / batchSize)
pb = mkbar("Loading training data into DB", numBatches)

poolWithTransaction(db$getPool(), \(conn) {
  dbExecute(conn, 'DELETE FROM trn;')

  pb$tick(0)
  for (i in 1:(numBatches)) {
    i1 = 1 + ((i - 1) * batchSize)
    i2 = min(i1 + batchSize - 1, nrow(trn))
    dbAppendTable(conn, 'trn', trn[i1:i2,])
    pb$tick()
  }
})
