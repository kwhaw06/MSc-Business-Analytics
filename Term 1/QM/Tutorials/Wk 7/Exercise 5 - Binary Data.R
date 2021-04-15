# Exercise 4 - Model for Binary Data

# 1.a ----
library(AER)
data("SwissLabor")

# 1.b ----
SwissLabor$participation.b <- as.numeric(SwissLabor$participation)-1

# Adding a new col named "participation.b", which takes on the value
# 1/2 if participation is no/yes. as glm() does not accepts 
# the dependent variable to be of class factor.
# Then, transforming it into 0/1 for no/yes.

# 1.c ----
swiss_lpm <- lm(participation.b ~ income + age + education, data=SwissLabor)

# 1.d ----
summary(swiss_lpm)

# All variables are sig at the 5% level, except for educ.
# Income increase by 1% (keeping constant all other regressors), 
# prob of women participating in the labor force decreases by 0.18.
# Age increase by 1 unit, prob ... decrease by 0.05.
# Education increase by 1 unit, prob ... decrease by 0.01.

# 1.e ----
swiss_probit <- glm(participation.b ~ income + education + age,
                    data=SwissLabor,
                    family=binomial(link="probit"))

swiss_logit <- glm(participation.b ~ income + education + age,
                    data=SwissLabor, family=binomial)

summary(swiss_probit)
summary(swiss_logit)

# 1.f ----
# They are not comparable because the effects are 
# measured on a different scale.

# 1.g ----
# Make predictions using probit model
predictions_p <- predict(swiss_probit,
                         newdata = data.frame("education" = c(11,12),
                                              "age" = c(4,4),
                                              "income" = c(10.70, 10.70)),
                         type = "response")
# shows us the difference of participation when education incrases from
# 11 to 12, while keeping age and income the same.
diff(predictions_p)  # diff = -0.01121074 

# Make predictions using logit model
predictions_p <- predict(swiss_logit,
                         newdata = data.frame("education" = c(11,12),
                                              "age" = c(4,4),
                                              "income" = c(10.70, 10.70)),
                         type = "response")

# shows us the difference of participation when education increases from
# 11 to 12, while keeping age and income the same.
diff(predictions_p)  # diff = -0.01135786

# Conclusion --> The effects on the probability are the same for 
# the logit and probit model; that is when education increases 
# from 11 to 12 years, the probability of participation decreases by 0.01.

# 1.h ----
# Probit model
predictions_p <- predict(swiss_probit,
                        newdata= data.frame("education" = c(1,2),
                                            "age" = c(4,4),
                                            "income" = c(10.70, 10.70)),
                        type = "response")
# difference of participation when education increases
# from 1 to 2 years.
diff(predictions_p) # -0.01135786 

# Logit model
predictions_p <- predict(swiss_logit,
                        newdata= data.frame("education" = c(1,2),
                                            "age" = c(4,4),
                                            "income" = c(10.70, 10.70)),
                        type = "response")
# difference of participation when education increases
# from 1 to 2 years.
diff(predictions_p) # -0.01149688  

# Conclusion --> The effects do not change. They seem to be constant.

# 1.i ----
# The effect of education on the probability of participation is -0.011283 
# in the linear probability model which is the same as those obtained 
# using a logit and a probit.
