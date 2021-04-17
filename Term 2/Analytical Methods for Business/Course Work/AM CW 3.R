###################################
### Step 1: Data Pre-processing ###
###################################
# load data 
pine <- read.table("pine.dat",sep = "", fill = TRUE,skip = 1)

# transpose the data
dat = as.data.frame(t(pine))

# merge all columns into 1
# install.packages("reshape")
library(reshape)
data = melt(dat)

# delete rows with NA values
data = data[-c(859:864),]

# add year
data$year=1107:1964

# delete column 1
data = data[,-1]

# extract data from 1201 to 1500
which(data$year==1201) # 95
which(data$year==1500) # 394
df = data[95:394,-2]
# extract data from 1201 to 1964
data = data[95:nrow(data),-2]

# convert to time series object
tsd = ts(df,start=1201, end=1500, frequency=1)
tsd_w = ts(data,start = 1201, end = 1964, frequency = 1)

####################################################################
### Step 2: Perform Data Transformations to Achieve Stationarity ###
####################################################################
# time series plot of tsd_w
plot(tsd_w, xlab="Year", 
     main="Douglas Fir's Tree-Ring Size from 1201 to 1964")
abline(v=1500, col='green')

# log transformation & first order differencing
ltsd = log(tsd)
dltsd = diff(ltsd)

ltsd_w=log(tsd_w)

# plot
plot(ltsd, xlab="Year", 
     main="Logged Douglas Fir's Tree-Ring Size from 1201 to 1500")
plot(dltsd, xlab="Year", 
     main="Additional Trend Removal Step")

# ACF & PACF plots
par(mfrow = c(1, 2))
acf(dltsd, main = "ACF")
pacf(dltsd, main = "PACF")

# ADF test
# install.packages("tseries")
library(tseries)
adf.test(dltsd)

##############################
### Step 3: Model Selection ##
##############################
# Model 1: ARIMA(1,1,1)
m1 <- arima(ltsd, order=c(1,1,1),
            include.mean=FALSE)

# Model 2: ARIMA(2,1,1)
m2 <- arima(ltsd, order=c(2,1,1),
            include.mean=FALSE)

# Model 3: ARIMA(1,1,2)
m3 <- arima(ltsd, order=c(1,1,2),
            include.mean=FALSE)

# Model 4: ARIMA(2,1,2)
m4 <- arima(ltsd, order=c(2,1,2),
            include.mean=FALSE)

#### Residual diagnostics 
# Model 1
par(mfrow = c(2, 2))
plot(resid(m1), main="Difference ltsd residual plot")
qqnorm(resid(m1));qqline(resid(m1))
acf(resid(m1));pacf(resid(m1))

# Model 2
par(mfrow = c(2, 2))
plot(resid(m2),main="Difference ltsd residual plot")
qqnorm(resid(m2));qqline(resid(m2))
acf(resid(m2));pacf(resid(m2))

# Model 3
par(mfrow = c(2, 2))
plot(resid(m3),main="Difference ltsd residual plot")
qqnorm(resid(m3));qqline(resid(m3))
acf(resid(m3));pacf(resid(m3))

# Model 4
par(mfrow = c(2, 2))
plot(resid(m4),main="Difference ltsd residual plot")
qqnorm(resid(m4));qqline(resid(m4))
acf(resid(m4));pacf(resid(m4))

#### AIC
AIC(m1,m2,m3,m4) 

##########################
### Step 4: Prediction ###
##########################
# install.packages("forecast")
library(forecast)
par(mfrow = c(2, 2))

# forecast 
forecast1 <- predict(m1, n.ahead = 500)
forecast2 <- predict(m2, n.ahead = 500)
forecast3 <- predict(m3, n.ahead = 500)
forecast4 <- predict(m4, n.ahead = 500)

# Model 1
plot(ltsd_w, lty = 3, main="Model 1: ARIMA(1,1,1)")
lines(ltsd, lwd = 2)
lines(forecast1$pred, lwd = 2, col = "red")
lines(forecast1$pred + forecast1$se*1.96, col = "red")
lines(forecast1$pred - forecast1$se*1.96, col = "red")

# Model 2
plot(ltsd_w, lty = 3, main="Model 2: ARIMA(2,1,1)")
lines(ltsd, lwd = 2)
lines(forecast2$pred, lwd = 2, col = "red")
lines(forecast2$pred + forecast2$se*1.96, col = "red")
lines(forecast2$pred - forecast2$se*1.96, col = "red")

# Model 3
plot(ltsd_w, lty = 3, main="Model 3: ARIMA(1,1,2)")
lines(ltsd, lwd = 2)
lines(forecast3$pred, lwd = 2, col = "red")
lines(forecast3$pred + forecast3$se*1.96, col = "red")
lines(forecast3$pred - forecast3$se*1.96, col = "red")

# Model 4
plot(ltsd_w, lty = 3, main="Model 4: ARIMA(2,1,2)")
lines(ltsd, lwd = 2)
lines(forecast4$pred, lwd = 2, col = "red")
lines(forecast4$pred + forecast4$se*1.96, col = "red")
lines(forecast4$pred - forecast4$se*1.96, col = "red")