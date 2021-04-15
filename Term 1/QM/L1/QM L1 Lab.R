# Importing data
site <- read.table("site.txt", header=T)

# Plotting the data
plot(site$Square_Feet, site$Annual_Sales,
     xlab="Square feet (000)", ylab="Annual Sales ($ million)")

# Regression line
site.lm <- lm(Annual_Sales ~ Square_Feet, data = site)
summary(site.lm)

# Assessing the assumptions
par(mfrow = c(2,2))
plot(site.lm)

# Standardized residuals vs explnatory variable
sres <- rstandard(site.lm)
plot(site$Square_Feet, sres, 
     xlab="Square feet", ylab="Standardized residuals")
