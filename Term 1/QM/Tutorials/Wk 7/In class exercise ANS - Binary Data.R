# %% Q.0 ----
# fitting the data
td <- c(0, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 1)
temp <- c(66, 70, 69, 68, 67, 72, 73, 70, 57, 63, 70, 78, 67, 53, 67, 75, 70,
          81, 76, 79, 75, 76, 58)

shuttle <- data.frame(td, temp)

# create logit model
shuttle.glm <- glm(td ~ temp, family = "binomial",
                   data = shuttle)
summary(shuttle.glm)

# %% Q.Plot ----
fittemp <- seq(20, 85, length = 100)

# this is the numerator from equation 1 in the answer pdf
etashuttle <- coef(shuttle.glm)[1] + coef(shuttle.glm)[2] * fittemp
# this is the denominator from equation 1 in the answer pdf
fitshuttle <- exp(etashuttle)/(1 + exp(etashuttle))

ylim <- c(0, 1)

plot(fittemp, fitshuttle, xlab = "Temperature (degrees F)", ylab =
       "Probability of Thermal Distress", type = "l",
     ylim = ylim, xlim = c(20, 85),lty = 1)
points(temp, td, cex=0.5)

# Conclusion --> if temperature at the time of flight is low, then
# the probability of at least 1 primary O-ring suffered TD is high.
# In contrast, if the temp is high, then probabiltiy of TD is low