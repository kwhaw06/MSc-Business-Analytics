### Lecture 5 - Shrinkage Methods ### 

library(ISLR)

# Under salary column some data are NA, so we want to 
# omit the rows which have NA
Hitters <- na.omit(Hitters)

# takes away the 1st column because glmnet has intercept already
# here we just have the predictors alone for RHS parameters
x <- model.matrix(Salary ~., Hitters)[,-1]
y <- Hitters$Salary

set.seed(100)
#install.packages("glmnet")
library(glmnet)

# this set the range of the lambda, which is divided into a length = 100 
grid <- 10^seq(10, -2, length = 100)

# Ridge Regression ----
# fitting a ridge regression with 100 lambda
ridge.mod <- glmnet(x, y, alpha = 0, lambda = grid)
ridge.mod

# dimension of the coefficients
dim(coef(ridge.mod))

## looking at the lambda at position 50
ridge.mod$lambda[50]
# this means we are shrinking our lambda close to 0 since lambda is very 
# large the parameters estimates when lambda = 50
coef(ridge.mod)[,50]

## look at when lambda = 750, which is position 60
ridge.mod$lambda[60]
# penalizing less here since lambda = 750
# can expect larger coefficients
coef(ridge.mod)[,60]

##  obtain the ridge regression coefficients for a new value of lambda, 
# for example, for lambda = s = 50.
predict(ridge.mod, s = 50, type = "coefficients")[1:20 ,]


# Then which lambda value do we choose? ----
# we choose the lambda with cross validation ----
# CV: Ridge Regression ----
set.seed(1)

train <- sample(1: nrow(x), nrow(x)/2)
test <- (- train)
# these 2 return the x-values, but not the y-values

# selecting the values of the response for the test data set
# this is just the sub-sample of the whole observation of y
# since the "test" dataset is 1/2 of the original datset.
y.test <- y[test]

cv.out <- cv.glmnet(x[train ,], y[train], alpha = 0)
plot(cv.out)

# finding the minimum lambda from the plot
bestlam = cv.out$lambda.min
bestlam

# choosing the best lambda which has the lowest 
# mean-squared error from the graph.
log(bestlam)

# producing the coefficients for the min lambda
out <- glmnet(x, y, alpha = 0)
predict(out, type = "coefficients", s = bestlam)[1:20 ,]

# get the MSE for the fitted model, use it to compare with Lasso later
# to see which model is better.
yhat <- predict(out, s = bestlam, newx = x[test ,])
yhat

mse <- mean((y[test] - yhat)^2)
mse

# CV: Lasso Regression ----
lasso.mod <- glmnet(x, y, alpha = 1, lambda = grid)

lasso.mod$lambda[50]
coef(lasso.mod)[,50]

lasso.mod$lambda[80]
coef(lasso.mod)[,80]

cv.out <- cv.glmnet(x[train ,], y[train], alpha = 1)
plot(cv.out)
bestlam = cv.out$lambda.min
bestlam

out <- glmnet(x, y, alpha = 1)
predict(out, type = "coefficients", s = bestlam)[1:20 ,]

yhat <- predict(out, s = bestlam, newx = x[test ,])
mse <- mean((y[test] - yhat)^2)
mse
