## Multiple Linear Regression: Moodle Exercise ##

## Set up
install.packages("faraway") 
library(faraway)

## 1.A
lm.fit <- lm(sr ~ dpi + ddpi + pop15 + pop75, data = savings)
summary(lm.fit)

## 1.B
summary(lm.fit)
# According to the F-stats, we can reject the null hypothesis that the
# coefficients are jointly zero, which implies the significance of all the
# predictors.


## 1.C
summary(lm.fit)
# According to the summary statistics, pop15 is significant at the 1% level.
# By rejecting the null, it means that there is evidence for a linear
# relationship between the pop15 and sr.


## 1.D
lm1.fit <- lm(sr ~ dpi + ddpi + pop75, data = savings)
anova(lm1.fit, lm.fit) 
# H0: The coefficient of pop75 in lm.fit is not significant
# We reject H0 as the p-value we obtained from the F-test approach is less
# than 5%. This tells us pop75's coefficient is significant in the lm.fit
# model.


## 1.E
# F-statistic value generated from anova() is the squared of 
# pop15's t-statistic in summary(lm.fit).
# You can see that the t=-3.189 which if squared is equal 
# to 10.16972 which is very close to the F test.
  

## 1.F
lm0.fit <- lm(sr ~ 1, data = savings)
library(MASS)
stepAIC(lm0.fit, ~ dpi + ddpi + pop15 + pop75, data = savings)
# According to stepAIC, The model chosen by using stepAIC is 
# sr ~ pop15 + pop75 + ddpi. Have to look at "Call" at the very bottom.


## 1.G
#  In terms of estimates coefficients and of significance, the results are 
# very similar. The only difference is that the coefficient associated with 
# pop75 is more significant.
lm.fit <- lm(sr ~ dpi + ddpi + pop15 + pop75, data = savings)
lm2.fit <- lm(sr ~ pop15 + ddpi + pop75, data = savings) 
summary(lm.fit)
summary(lm2.fit)

## 1.H
# It can be observed that there is a sign of trend in three graphs: 
# pop15 vs pop75, pop15 vs dpi, and pop75 vs dpi, which suggests the 
# possibility of collinearity between these variables. I believe
# it will be better to include just one of the aforementioned variables
# to avoid the collinearity. In this case, I choose to take out
# dpi and pop75 as pop15 is more significant than them according to the t-test.

lm.fit5 <- lm(sr ~ ddpi + pop15, data = savings)
summary(lm.fit5)

# From the summary table, for an unit increase in ddpi will lead to a
# 0.4428 unit increase in sr, and an unit increase in pop15 will lead to a
# 0.2163 unit decrease in sr.