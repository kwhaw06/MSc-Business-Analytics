library(ISLR)
library(mgcv)
data(Wage)
gam1 <- gam(wage ~ s(age) + education + year, data = Wage)

summary(gam1)

gam.check(gam1)

plot(gam1, scale = 0)

gam2 <- gam(I(wage >250) ~ year +s(age) + education, family = binomial, data = Wage)
summary(gam2)
plot(gam2, scale = 0)
