# Lab 1 ----
# Load data
library(MASS)

# Linear model
lm.fit <- lm(medv ~ lstat, data = Boston)
par(mfrow = c(2,2))
plot(lm.fit)

# Model with a polynomial of degree 2
lm.fit2 <- lm(medv ~ lstat +I(lstat ^2), data = Boston)
par(mfrow = c(2,2))
plot(lm.fit2)

summary(lm.fit2)

# Model with a polynomial of degree 5
lm.fit5 <- lm(medv ~ poly(lstat ,5), data = Boston)
par(mfrow = c(2,2))
plot(lm.fit2)
summary(lm.fit5)

# Lab 2----
# Generating non-linear data----
set.seed(100)
x <- seq(0, pi * 2, 0.1)
sin_x <- sin(x)

y <- sin_x + rnorm(n = length(x), mean = 0, sd = sd(sin_x / 2))
Sample_data <- data.frame(y,x)

# plotting the non-linear relationship between x & y
par(mfrow = c(1,1))
plot(x,y)

# Fit polynomial models with different degrees
x11()
par(mfrow = c(2, 3))

degree.p <- c(2, 4, 6, 8, 10, 20)

for(i in 1:length(degree.p)){
  m2 <- lm(y ~ poly(x, degree.p[i]), data = Sample_data)
  plot(Sample_data$x, Sample_data$y)
  lines(sort(Sample_data$x), fitted(m2)[order(Sample_data$x)], lwd = 2)
}


# Lab TPRS ----
library(mgcv)

# number of basis
no.b <- 3 # or 4, 5 ...

# GAM = our function
# s = smooth function = the f(x) in the notes
gam(y ~ s(x, bs = "tp", k = no.b, fx = TRUE))  # fx = TRUE means w/o the penalty term

# plotting the model with different number of basis
x11()
par(mfrow = c(2, 3))
no.b <- c(2, 3, 4, 5, 6, 20) + 1
for(i in 1:length(no.b)){
  m3 <- gam(y ~ s(x, bs = "tp", k = no.b[i], fx = TRUE), data = Sample_data)
  plot(Sample_data$x, Sample_data$y )
  lines(sort(Sample_data$x), fitted(m3)[order(Sample_data$x)], lwd = 2)
}

# Choosing different value of lambda
x11()
par(mfrow = c(1, 3))
sps <- c(0.00001, 1, 1000)   # 3 values of lambda
for(i in 1:length(sps)){
  m4 <- gam(y ~ s(x, bs = "tp", k = 30), sp = sps[i], data = Sample_data)
  plot(Sample_data$x, Sample_data$y )
  lines(sort(Sample_data$x), fitted(m4)[order(Sample_data$x)], lwd = 2)
}

# the package will choose the best lambda for us automatically
par(mfrow = c(1, 1))
m5 <- gam(y ~ s(x, bs = "tp", k = 30), data = Sample_data) # if we dont state lambda value, then it will get the opmitzied lambda value

# plotting
plot(Sample_data$x, Sample_data$y)
lines(sort(Sample_data$x), fitted(m5)[order(Sample_data$x)], lwd = 2)


m5$sp # estimated smoothing parameter

# Confidence intervals and p-values
plot(m5, residuals = TRUE, shade = TRUE)
summary(m5)
AIC(m5)

# residual analysis for GAM
gam.check(m5)


# Lab Gam
library(mgcv)
pisa <- read.csv("pisasci2006.csv")

# fitting a gam model for overall sci score with income predictor only
# linear model
mod_lm <- gam(Overall ~ Income, data = pisa)
summary(mod_lm)

# additive model
mod_gam1 <- gam(Overall ~ s(Income), data = pisa)
summary(mod_gam1)

# linear model with more response variables
mod_lm2 <- gam(Overall ~ Income + Edu + Health, data=pisa)
summary(mod_lm2)

# additive model with more resposne variables
mod_gam2 <- gam(Overall ~ s(Income) + s(Edu) + s(Health), data = pisa)
summary(mod_gam2)

# smooth function for income and edc, but not health
mod_gam2B = update(mod_gam2, .~.-s(Health) + Health, data = pisa)
summary(mod_gam2B)

# visualizing the effect of income and edc on the overall sci score
plot(mod_gam2B, pages = 1, seWithMean = TRUE, shade = TRUE, scale = 0)

# residual check
gam.check(mod_gam2B)


# gam with interaction term
mod_gam3 <- gam(Overall ~ te(Income, Edu), data =pisa)
summary(mod_gam3)

vis.gam(mod_gam3, type = 'response', plot.type = 'persp',
        phi = 30, theta = 30, n.grid = 500, border = NA)
