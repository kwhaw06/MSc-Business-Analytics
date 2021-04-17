#### ACF ####
# load data
data(EuStockMarkets)
smi <- EuStockMarkets[, 2]

# ACF of a time series with trend + no seasonal effect
plot(smi)
acf(smi, lag.max = 100)

# ACF of a time series with no trend + seasonal effect
data(nottem)
plot(nottem)
acf(nottem, lag.max = 100)

# ACF of a time series with increasing trend and a seasonal effect
plot(log(AirPassengers))
acf(log(AirPassengers), lag.max = 100)

#### White Noise ####
W = ts(rnorm(200, mean = 0, sd = 1))
acf(W)
pacf(W)

#### Autoregressive Models ####
abs(polyroot(c(1,0.4,-0.2,0.3)))

autocorr <- ARMAacf(ar = c(0.4, -0.2, 0.3), 
                    lag.max = 20)

plot(0:20, autocorr, type = "h", xlab = "Lag")

pautocorr <- ARMAacf(ar = c(0.4, -0.2, 0.3), 
                     pacf = TRUE, 
                     lag.max = 20)

plot(pautocorr, type = "h", xlab = "Lag")

#### Moving Average Models ####
set.seed(21)
ts.ma1 <- arima.sim(list(ma = 0.7), # 0.7 is the coefficient, we only have 1 here.
                    n = 500)

# plotting ACF and PACF
plot(ts.ma1, ylab = "", ylim = c(-4, 4))
title("Simulation from a MA(1) Process")
acf.true <- ARMAacf(ma = 0.7, lag.max = 20)
pacf.true <- ARMAacf(ma = 0.7, pacf = TRUE, lag.max = 20)

par(mfrow = c(2, 2))
acf(ts.ma1, main = "Estimated ACF")
pacf(ts.ma1, main = "Estimated PACF")
plot(0:20, acf.true, type = "h", xlab = "Lag", main = "True ACF")
plot(pacf.true, type = "h", xlab = "Lag", main = "True PACF")

#### Example: Return of AT&T Bonds ####
dat <- read.table("attbond.dat", sep = "", header = T)
d.att <- ts(dat)
plot(d.att)
acf(d.att)

# plot the difference of the original data
plot(diff(d.att))

# acf & pacf
plot(diff(d.att), ylab = "diff(attbond)",
     main = "Daily Changes in the Return of an AT&T Bond Time")
par(mfrow = c(1, 2))
acf(diff(d.att), main = "ACF")
pacf(diff(d.att), main = "PACF")

# fitting MA(1) with CSS approach for parameter estimation
arima(diff(d.att), order = c(0, 0, 1), method = "CSS")

# fitting MA(1) with default parameter estimation
arima(diff(d.att), order = c(0, 0, 1))

# residual analysis
par(mfrow = c(2, 2))
fit <- arima(diff(d.att), order = c(0, 0, 1))
plot(resid(fit))
qqnorm(resid(fit)); qqline(resid(fit))
acf(resid(fit)); pacf(resid(fit))

# a more formal test
Box.test(resid(fit), type = "Box-Pierce", lag = 1)
Box.test(resid(fit), type = "Box-Pierce", lag = 10)

Box.test(resid(fit), type = "Ljung-Box", lag = 1)
Box.test(resid(fit), type = "Ljung-Box", lag = 10)