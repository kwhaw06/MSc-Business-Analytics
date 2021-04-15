# Setting up library
install.packages("MASS")
library(MASS)

fix(Boston)
names(Boston)
?Boston

### Linear model
# Standard syntax -> lm(y ~ x,data)
lm.fit <- lm(medv~lstat, data=Boston)

### Summary
summary(lm.fit)

# Confidencence Interval
confint(lm.fit)

# Prediction Intervals
predict(lm.fit, data.frame(lstat = c(5, 10, 15)),
        interval = "confidence")
predict(lm.fit, data.frame(lstat = c(5, 10, 15)),
        interval = "prediction")
# Prediction interval is always wider than confidence interval

plot(lstat, medv)
abline(lm.fit)

# Diagnostic plots
par(mfrow = c(2,2))
plot(lm.fit)


