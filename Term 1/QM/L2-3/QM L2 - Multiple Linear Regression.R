## Lecture 2 - Multiple Linear Regression

# Setting up the model
library(MASS)
lm.fit <- lm(medv ~ lstat + age, data = Boston)
summary(lm.fit)

# Calculating the quantile of the distribution.
# Getting the 95% confidence interval points for t-stats
qt(0.025, 503)
# if your t-value is outside the range, then reject

# Lecture note exercise: Oil
oil <- read.table("oil.txt")
names(oil) <- c("spirit","gravity","pressure","distil","endpoint")
oil.lm <- lm(spirit ~ gravity + pressure + distil + endpoint, data = oil)
summary(oil.lm)

# Remove insignificant regressor (pressure)
oil3.lm <- lm(spirit ~ gravity + distil + endpoint, data = oil)
summary(oil3.lm)

# Remove gravity
oil2.lm <- lm(spirit ~ distil + endpoint, data = oil)
summary(oil2.lm)

# compare 2 nested models
# F-test only works on nested models
anova(oil.lm,oil2.lm)

# We may, if desired, calculate the confidence and prediction intervals.
x <- data.frame(distil = 200, endpoint = 400)

confidence <-predict(oil2.lm, x, se.fit = T, interval = c("confidence"))
confidence

prediction <-predict(oil2.lm, x, se.fit = T, interval = c("prediction"))
prediction

summary(oil)

# Model Selection
library(MASS)

oil0.lm <- lm(spirit ~ 1, data = oil)

stepAIC(oil0.lm, ~ gravity + pressure + distil + endpoint, data = oil)

# Residual analysis
par(mfrow = c(2, 2))
plot(oil2.lm)

