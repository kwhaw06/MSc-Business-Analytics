### Loading data
house <-read.table("house.txt", header = TRUE)
house

# ploting graph without the data points,
# can do this by include type = n,'n' means none
plot(house$Size, house$Value, type = "n", main = "House value vs Size",
     xlab = "Size", ylab = "Value")

# Showing the size of the houses that don't have a fire place
points(house$Size[house$Fireplace=="No"], house$Value[house$Fireplace=="No"],
       pch=1)

# Showing the size of the houses that have a fire place
points(house$Size[house$Fireplace=="Yes"], house$Value[house$Fireplace=="Yes"],
       pch=8)

# Adding legend
legend(1.2, 237, c("Yes", "No"), pch =c(8,1))


### Fitting a simple linear regression - Model A
house.lmA <- lm(Value ~ Size, data = house)
summary(house.lmA)

# Same step as before
par(mfrow = c(1, 2))
plot(house$Size, house$Value, type = "n", main = "House value vs Size: Model A",
     xlab = "Size", ylab = "Value")
points(house$Size[house$Fireplace == "No"], house$Value[house$Fireplace == "No"], pch = 1)
points(house$Size[house$Fireplace == "Yes"], house$Value[house$Fireplace == "Yes"], pch = 8)
legend(1.2, 237, c("Yes", "No"), pch =c(8,1), bty="n")

# Add a fitted line
abline(house.lmA)

# residuals vs fitted value
sresA <- rstandard(house.lmA)
fitsA <- fitted(house.lmA)

plot(fitsA, sresA, type = "n", main = "Stand. Residuals vs Fitted Values",
     xlab = "Fitted values", ylab = "Standardized residuals")
points(fitsA[house$Fireplace == "No"], sresA[house$Fireplace == "No"], pch = 1)
points(fitsA[house$Fireplace == "Yes"], sresA[house$Fireplace == "Yes"], pch = 8)


### Adding a binary varaible - Model B
house.lmB <- lm(Value ~ Size + Fireplace, data = house)
summary(house.lmB)

# Plotting 
par(mfrow = c(1, 2))
plot(house$Size, house$Value, type = "n", main = "House value vs Size: Model B",
     xlab = "Size", ylab = "Value")
points(house$Size[house$Fireplace == "No"], house$Value[house$Fireplace == "No"], pch = 1)
points(house$Size[house$Fireplace == "Yes"], house$Value[house$Fireplace == "Yes"], pch = 8)

legend(1.2, 237, c("Yes", "No"), pch =c(8,1), bty="n")

# Fitting 2 lines
ld <- seq(min(house$Size), max(house$Size), 0.1)
lines(ld, predict(house.lmB, data.frame(Size = ld, Fireplace = rep("Yes", length(ld))),
                  type = "response"))
lines(ld, predict(house.lmB, data.frame(Size = ld, Fireplace = rep("No", length(ld))),
                  type = "response"))

# residual vs fitted
sresB <- rstandard(house.lmB)
fitsB <- fitted(house.lmB)
plot(fitsB, sresB, type = "n", main = "Stand. Residuals vs Fitted Values")
points(fitsB[house$Fireplace == "No"], sresB[house$Fireplace == "No"], pch = 1)
points(fitsB[house$Fireplace == "Yes"], sresB[house$Fireplace == "Yes"], pch = 8)


### Adding an interaction term - Model C
house.lmC <- lm(Value ~ Size * Fireplace, data = house)
summary(house.lmC)

# model selection ----- 

house.lmA <- lm(Value ~ Size, data = house)
house.lmB <- lm(Value ~ Size + Fireplace, data = house)
house.lmC <- lm(Value ~ Size * Fireplace, data = house)

library("MASS")
anova(house.lmC)

# regression using dummy variable II ----
library(ISLR)
names(Carseats)

lm.fit <- lm(Sales ~ ., data=Carseats)
summary(lm.fit)

anova(lm.fit)

lm.fit <- lm(Sales ~ ., data=Carseats)
lm.fit2 <- update(lm.fit, ~ ., -ShelveLoc)
anova(lm.fit2, lm.fit)

# Changing the base category of a factor variable ----
Carseats <- within(Carseats, ShelveLoc <- relevel(ShelveLoc, ref="Good"))
lm.fit <- lm(Sales ~ ., data=Carseats)
summary(lm.fit)
