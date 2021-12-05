# from: https://www.kaggle.com/c/g-research-crypto-forecasting/discussion/291845
# def weighted_correlation(a, b, weights):
#
#   w = np.ravel(weights)
#   a = np.ravel(a)
#   b = np.ravel(b)
#
#   sum_w = np.sum(w)
#   mean_a = np.sum(a * w) / sum_w
#   mean_b = np.sum(b * w) / sum_w
#   var_a = np.sum(w * np.square(a - mean_a)) / sum_w
#   var_b = np.sum(w * np.square(b - mean_b)) / sum_w
#
#   cov = np.sum((a * b * w)) / np.sum(w) - mean_a * mean_b
#   corr = cov / np.sqrt(var_a * var_b)
#
#   return corr

weightedCorrelation = \(y, yhat, w) {
  cases = complete.cases(y, yhat, w)

  sumW = sum(w[cases])

  meanY = sum(y[cases] * w[cases]) / sumW
  varY = sum(w[cases] * (y - meanY)^2) / sumW

  meanYhat = sum(yhat[cases] * w[cases]) / sumW
  varYhat = sum(w[cases] * (yhat[cases] - meanYhat[cases])^2) / sumW

  cov = (sum(y[cases] * yhat[cases] * w[cases]) / sum(w[cases])) - (meanY * meanYhat)
  corr = cov / (sqrt(varY * varYhat))

  corr
}
