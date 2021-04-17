# load data
library(TSclust)
data("interest.rates")

# 2 time series
set.seed(100)
diss.PRED(interest.rates[, 13], interest.rates[, 16], h = 6, B = 2000,
          logarithm.x = TRUE, logarithm.y = TRUE, differences.x = 1,
          differences.y = 1, plot = TRUE)$L1dist

# all time series 
set.seed(100)
diffs <- rep(1, ncol(interest.rates))
logs <- rep(TRUE, ncol(interest.rates))
dpred <- diss(interest.rates, "PRED", h = 6, B = 1200, logarithms = logs,
              differences = diffs, plot = TRUE)

hc.dpred <- hclust(dpred$dist)
plot(hc.dpred)