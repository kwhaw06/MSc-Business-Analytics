## L1 Exercise 

# Setting up data
distance <- c(1.3,2.9,4.4,5.8,8.2,9.9,12.1,13.8,14.2,17.7)
daysabsent <- c(8,5,7,5,6,3,5,4,2,2)


## Question A ##
# Days absent is the y variable because the manager is interested in knowing
# how does the distance between home and work for the employees affect their
# absent days.


## Question B ##
DF1 <- data.frame(distance,daysabsent)
plot(x=distance,y=daysabsent, main="Distance vs Days Absent",
     xlab="Distance to Work", ylab="Days Absent")


## Question C ##
lm.fit <- lm(daysabsent ~ distance, data=DF1)
abline(lm.fit)


## Question D ##
# The slope is negative and this implies that as the distance from work to home
# increases, the number of days absent decreases. There exists a negative linear
# relationship between the two variables. On average, people living close to 
# the hospital take more days off than people living some distance from the 
# hospital. 


## Question E ##
predict(lm.fit, data.frame(distance=c(10)),
        interval="confidence")
# Approximately 4 days.


## Question F ##
# The same slope cannot continue for arbitrarily large distances. 
# It is only valid for the range of the distance variable (1.3, 17.7). 
# The range is the min and max of the data points.
# If it continuous, then someone living 25 or more km from the hospital will 
# have a negative number of days absent. 
# The relationship might cease to be linear.


## Question G ##
par(mfrow = c(2,2))
plot(lm.fit)

# From the residuals vs fitted plot, we can observe that the residuals are 
# scattered around the 0 line, and this suggests that the relationship is 
# linear. Secondly, the residuals roughly formed a horizontal band around 0
# which suggests that the variances of the error terms are equal.
# Lastly, there no outliers can be detected from the visualization of the plot.
# Thus, we can conclude that there is evidence of linearity, equal error variances
# and no outliers in the plot.
# Furthermore, the assumption of normality does not hold here because there are
# points that are not located right on the dotted line in the QQ plot.
# Hence, normality of the plot is questionable as we have limited data points
# to be conclusive.