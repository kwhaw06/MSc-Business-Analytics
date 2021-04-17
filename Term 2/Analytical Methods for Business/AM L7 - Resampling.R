#### 5.3.1 Leave-One-Out Cross-Validation ####

## linear regression example
library(ISLR)
library(boot)

# fit a glm so we can use CV
glm.fit = glm(mpg ~ horsepower, data = Auto)
cv.err = cv.glm(Auto, glm.fit)

cv.err$delta

## polynomial regression example 
cv.error = rep (0, 5)

for(i in 1:5){
  glm.fit = glm(mpg ~ poly(horsepower, i), data = Auto)
  cv.error[i] = cv.glm(Auto, glm.fit)$delta[1]
}

cv.error

#### 5.3.2 k-Fold Cross-Validation ####
set.seed(1)
cv.error.10 = rep(0, 10)

for (i in 1:10) {
  glm.fit = glm(mpg ~ poly(horsepower, i), data = Auto)
  cv.error.10[i] = cv.glm(Auto, glm.fit, K = 10)$delta[1]
}

cv.error.10

#### 5.3.3 Estimating the Accuracy of a Statistic of Interest ####
# create a function
alpha.fn = function(data, index){
  X = data$X[index]
  Y = data$Y[index]
  (var(Y)-cov (X,Y))/(var(X)+var(Y) -2* cov(X,Y))
}

# use the function to estimate alpha
library(ISLR)
data(Portfolio)
alpha.fn(Portfolio, 1:100)

# construct new bootstrap data set with the resampling with replacement 
set.seed(1)
alpha.fn(Portfolio, sample(100, 100, replace = T))

# bootstrap
library(boot)
boot(Portfolio, alpha.fn, R = 1000)

# obtain all alphas
boot1 = boot(Portfolio, alpha.fn, R = 1000)
boot1$t

sd(boot1$t)  # getting the SE

mean(boot1$t) - boot1$t0   # bias value

#### 5.3.4 Estimating the Accuracy of a Linear Regression Model ####
data(Auto)
boot.fn = function(data, index) coef(lm(mpg ~ horsepower, data = data, subset = index))
boot.fn(Auto, 1:392)

# perform bootstrap
boot2 = boot(Auto, boot.fn, 1000)
boot2

# plot
plot(Auto$horsepower, Auto$mpg)

## quadratic model ##
# bootstrap estimates
# bootstrap function
boot.fn = function(data, index)
  coefficients(lm(mpg ~ horsepower + I(horsepower^2), 
                  data = data, subset = index))

# bootstrap quadratic
set.seed (1)
boot(Auto, boot.fn, 1000)

# analytical estimates 
summary(lm(mpg ~ horsepower + I(horsepower^2), data = Auto))$coef

