## LECTURE 4 EXERCISE ##

# 1.a ----
#install.packages("wooldridge")
library(wooldridge)
data(wage1)

# 1.b ----
lm1.fit <- lm(wage ~ female + educ + exper + tenure, data=wage1) 

# 1.c ----
summary(lm1.fit)

# 1.d ----
summary(lm1.fit)

# 1.e ----
lm2.fit <- lm(wage ~ female, data=wage1)

# 1.f ----
summary(lm2.fit)

# 1.g ----
summary(lm1.fit)
summary(lm2.fit)

# 1.h ----
t.test(wage1$wage[wage1$female==1],
       wage1$wage[wage1$female==0], var.equal = TRUE)

# 1.i ----
lm3.fit <- lm(wage ~ female*educ + exper + tenure, 
              data=wage1)
summary(lm3.fit)
