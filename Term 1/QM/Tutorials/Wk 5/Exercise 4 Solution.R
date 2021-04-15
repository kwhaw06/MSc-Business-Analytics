# %% Q1 ----
# load package
library(ISLR)
set.seed(11)   # because we need to split the data randomly

train.size <- dim(College)[1] / 2
train <- sample(1:dim(College)[1], train.size)
test <- -train
College.train <- College[train, ]
College.test <- College[test, ]

# %% Q2 ---- 
lm.fit <- lm(Apps ~., data = College.train)   # true data
lm.pred <- predict(lm.fit, College.test)      # estimations
mean((College.test[, "Apps"] - lm.pred)^2)    # RSS

# %% Q3 ----
# What we have to do here is pick a lambda using training set and 
# report error on the testing set.
library(glmnet)

# create matrix for training & testing dataset
train.mat <- model.matrix(Apps ~., data = College.train)  # can remove the intercept --> look at lecture notes
test.mat <- model.matrix(Apps ~., data = College.test)

# create the amount of lambda, 100 in this case, that we want to test
grid = 10^seq(4, -2, length = 100)

# create a ridge regression on the training dataset
# cv = cross validation method
mod.ridge = cv.glmnet(train.mat, College.train[, "Apps"], alpha = 0,
                      lambda = grid, thresh = 1e-12)

# finding the lambda which produces the lowest CV error
# that is the minimum lambda
lambda.best = mod.ridge$lambda.min
lambda.best   # value = 0.1

# use this lambda to find the fit into the testing dataset
ridge.pred <- predict(mod.ridge, newx = test.mat, s = lambda.best)

# check the RSS
mean((College.test[, "Apps"] - ridge.pred)^2)
# result = Test RSS (1,026,069) is slightly lower than that of OLS (1,026,096)
# meaning ridge model fits the data better than OLS model

# %% Q4  ----
# What we have to do here is pick a lambda using training set and 
# report error on the testing set.

# fitting a lasso model
mod.lasso <- cv.glmnet(train.mat, College.train[, "Apps"], alpha = 1, lambda = grid, thresh = 1e-12)
# find the lambda that gives the lowest CV error
lambda.best <- mod.lasso$lambda.min
lambda.best
# fit the model with that lambda, and do predictions on the testing set
lasso.pred = predict(mod.lasso, newx = test.mat, s = lambda.best)

# calculate the RSS within the testing dataset
mean((College.test[, "Apps"] - lasso.pred)^2)
# Result = Test RSS (1,026,036) is slightly lower than that of OLS.

# Inspecting the coefficients
mod.lasso <- glmnet(model.matrix(Apps ~., data = College), 
                    College[, "Apps"], alpha = 1)
predict(mod.lasso, s = lambda.best, type = "coefficients")

# Q5 ----
# Results for OLS, Lasso, Ridge are comparable, very similar.