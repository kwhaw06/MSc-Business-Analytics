##################
### Question 2 ###
##################

#### Question 2.a ####
library(MASS)
data("Boston")

# estimate mean of medv
mu <- mean(Boston$medv)
mu

# estimate standard error of mu
n <- nrow(Boston)  # number of observations
se <- sqrt(var(Boston$medv)/n)
se

#### Question 2.b ####
# create a function
alpha.fn = function(data, index){
  x <- data$medv[index]
  return(mean(x))
}

# bootstrap
library(boot)
set.seed(1)
boot1 = boot(Boston, alpha.fn, R = 10000)
se_boot = sd(boot1$t)
se_boot

#### Question 2.c ####
# bootstrap estimate 95% confidence interval
lower = mean(Boston$medv) - 1.96*se_boot 
mean = mean(Boston$medv)
upper = mean(Boston$medv) + 1.96*se_boot

lower
mean
upper

# t-test 95% confidence interval
t.test(Boston$medv)

#### Question 2.d ####
med <- median(Boston$medv)
med

#### Question 2.e ####
# create a function
alpha.fn = function(data, index){
  x <- data$medv[index]
  return(median(x))
}

# bootstrap
library(boot)
set.seed(1)
boot1 = boot(Boston, alpha.fn, R = 10000)
se_boot = sd(boot1$t)
se_boot

#### Question 2.f ####
tenth_perc <- quantile(Boston$medv, 0.1)
tenth_perc

#### Question 2.g ####
# create a function
alpha.fn = function(data, index){
  x <- data$medv[index]
  return(quantile(x, 0.1))
}

# bootstrap
library(boot)
set.seed(1)
boot1 = boot(Boston, alpha.fn, R = 10000)
se_boot = sd(boot1$t)
se_boot
