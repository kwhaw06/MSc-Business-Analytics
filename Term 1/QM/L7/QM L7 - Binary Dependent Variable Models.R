# Loading data
#install.packages("AER")
library(AER)
data("SwissLabor")

# Linear Probability Model ----
# participation is recorded as Yes or No
# R doesn't recognize it as numeric automatically, we need to do it
# when transform data to numeric, Yes = 2, No = 1
# by minusing 1 we change it to Yes = 1, No = 0
SwissLabor$participation <- as.numeric(SwissLabor$participation) - 1
swiss_lpm <- lm(participation ~ ., data = SwissLabor)
summary(swiss_lpm)

summary(predict(swiss_lpm))

# Probit & Logit Model ----
data("SwissLabor")

# Probit model ----
swiss_probit <- glm(participation ~ ., data = SwissLabor, 
                    family = binomial(link = "probit"))

summary(swiss_probit)

# finding the marginal effects of continuous regressors
pav <- mean(dnorm(predict(swiss_probit, type = "link")))
pav * coef(swiss_probit)

# finding the marginal effects of binary regressors
SwissLaborS <- SwissLaborNS <- SwissLabor

SwissLaborS$foreign <- 'yes'
SwissLaborNS$foreign <- 'no'

predictionsS <- predict(swiss_probit, newdata = SwissLaborS, type = "response")
predictionsNS <- predict(swiss_probit, newdata = SwissLaborNS, type = "response")

mean(predictionsS) - mean(predictionsNS)

# Lasso model ----
# fit a lasso model
swiss_logit <- glm(participation ~ ., data = SwissLabor, family = binomial)
summary(swiss_logit)

# find the marginal effect for continuous variable regressors
lav <- mean(dlogis(predict(swiss_logit, type = "link")))
lav * coef(swiss_logit)

# find the marginal effect for binary variable regressors
predictionsS <- predict(swiss_logit, newdata = SwissLaborS, type = "response")
predictionsNS <- predict(swiss_logit, newdata = SwissLaborNS, type = "response")

mean(predictionsS) - mean(predictionsNS)

# Assess the fit of a binary regression model ----
# Use both confusion matrix and ROC curve.

# confusion matrix
table(true = SwissLabor$participation, pred = round(fitted(swiss_probit)))
table(true = SwissLabor$participation, pred = round(fitted(swiss_logit)))

# ROC
#install.packages("ROCR")
library(ROCR)
pred <- prediction(fitted(swiss_probit), SwissLabor$participation)

par(mfrow=c(1,2))
plot(performance(pred, "acc"))
plot(performance(pred, "tpr", "fpr"))
abline(0, 1, lty = 2)
