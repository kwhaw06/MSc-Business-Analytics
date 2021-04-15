# load data
dat <- read.table("GHJ_food_income.txt", header = TRUE)
attach(dat)

# plotting a scatter plot ----
plot(Food ~ Income, xlab = "Weekly Household Income ($)",
     ylab = "Weekly Household Expenditure on Food (Log $)")

# Fitting a lm / simple linear model ----
foodLM <- lm(Food ~ Income)
summary(foodLM)

# Fitting a glm ----
foodGLM <- glm(Food ~ Income)
summary(foodGLM) 

# Everything is same except the glm one has a dispersion parameter, 
# null and residual deviance, and AIC.
# Dispersion parameter value is the square of RSE from the lm.

# plot deviance residual ----
plot(residuals(foodGLM) ~ fitted(foodGLM),
     xlab = expression(hat(y)[i]),
     ylab = expression(r[i]))
abline(0, 0, lty = 2)

# the residuals scattered around 0 = sign of normally distributed

# residual analysis ----
par(mfrow=c(2,2))
plot(foodGLM)

# checking residuals of different definitions
resid(foodGLM, type="response")
resid(foodGLM, type="working")
resid(foodGLM, type="deviance")
resid(foodGLM, type="pearson")
