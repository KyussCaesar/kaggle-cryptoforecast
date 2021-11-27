#' Baseline Model: Target = 0
import(db)
import(metrics)

ms = metrics()
mt.name(ms, "baseline-target-zero")
mt.started_at(ms)

set.seed(573922)

dts = getQuery('SELECT DISTINCT ts FROM trn WHERE target IS NOT NULL;')

trnAmt = 6#0 * 24 * 30 * 2 # months
tstAmt = 6#0 * 24 * 30 * 2 # months

lastTrainIdx = sample(trnAmt:(nrow(dts) - tstAmt - 15 - 1), 1)

# minDate = dts[lastTrainIdx - trnAmt + 1,ts]
# maxDate = dts[lastTrainIdx + 15 + tstAmt,ts]

# trnIdxs = (lastTrainIdx - trnAmt + 1):lastTrainIdx
# tstIdxs = (lastTrainIdx + 15 + 1):(lastTrainIdx + 15 + tstAmt)

minDate = dts[lastTrainIdx + 15 + 1,ts]
maxDate = dts[lastTrainIdx + 15 + tstAmt,ts]

df = getQuery('SELECT ts, target FROM trn WHERE ts BETWEEN $1 AND $2 AND target IS NOT NULL;', params = list(minDate, maxDate))

prediction = 0
df$error = df[,"target"] - prediction

ggplot(df, aes(error)) + geom_histogram()

mae = median(abs(df[,error]))
mt.mae(ms, mae)
mt.finished_at(ms)
