##Q(a)----
# Create data by different ways
# Use R vectors
# Use excel/csv/txt file
# Use scan()
absent = c(8,5,7,5,6,3,5,4,2,2)
distance = c(1.3, 2.9, 4.4, 5.8, 8.2, 9.9, 12.1, 13.8, 14.2, 17.7)

##Q(b)----
hospital_combine = cbind(absent, distance)
plot(hospital_combine[  ,'distance'], hospital_combine[ ,'absent'], 
     xlab = "Distance (Km)",
     ylab = "Days absent")

hospital = as.data.frame(hospital_combine)
plot(hospital$distance, hospital$absent, 
     xlab = "Distance (Km)",
     ylab = "Days absent")

##Q(c)----
hosp.lm <- lm(absent ~ distance, data = hospital)

summary(hosp.lm)

plot(hospital$distance, hospital$absent, 
     xlab = "Distance (Km)",
     ylab = "Days absent",
     xlim = c(0,20),
     ylim = c(0,8))
abline(hosp.lm, col='red')
#points(x=0, y=hosp.lm$coefficients[1], col='blue', pch=7)
#abline(h=hosp.lm$coefficients[1], type = 'n', col='green')
#abline(v=0, , col='green')
#Be careful, check the intercept
#points(x=0, y=hosp.lm$coefficients[1], col='blue')

##Extra----
help("plot")
# check xlim or ylim in help 
plot(hospital$distance, hospital$absent, 
     xlab = "Distance (Km)",
     ylab = "Days absent",
     xlim = c(0,20),
     ylim = c(0,10))
abline(hosp.lm, col='red')
#Now, check the intercept
points(x=0, y=hosp.lm$coefficients[1], col='blue')

##Q(d)----
hosp.lm$coefficients

##Q(e)----
#Method 1
y_hat = as.numeric(hosp.lm$coefficients[1])+
        as.numeric(hosp.lm$coefficients[2])*10

#Method 2
x <- data.frame(distance = 10)
predict(hosp.lm, x)

##Q(f)----
#Business domain knowledge, student own judgement

##Q(g)----
par(mfrow=c(2,3))
plot(hosp.lm)

sres<- rstandard(hosp.lm)
plot(hospital$distance, sres, xlab="Distance (Km)", ylab="Standardized residuals")


