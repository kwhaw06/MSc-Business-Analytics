# Step 1: importing the data & data cleaning ----
data <- read.table("wage.txt", header=T)

# making negative experience values to meaningful 0's
data$experience <- ifelse(data$experience < 0, 0, data$experience)
# take the log of wage
data$logwage <- log(data$wage)
# dropping variable id & wage from the dataset
data$id <- NULL
data$wage <- NULL

###### Question 1 ----
# fitted model
model.1 <- lm(logwage ~ ., data = data) 

# Step 2: Detect multicollinearity
library(car)
vif(model.1)

# Step 3: Checking variables significance
anova(model.1)  # all of the variables are significant

model.2 <- lm(logwage ~. -ethnicity, data=data)  # data sets for F-test
model.3 <- lm(logwage ~. -smsa, data=data)       # testing the significance
model.4 <- lm(logwage ~. -region, data=data)     # of the qualitative variables
model.5 <- lm(logwage ~. -parttime, data=data)

anova(model.2, model.1)  # ethnicity
anova(model.3, model.1)  # smsa
anova(model.4, model.1)  # region
anova(model.5, model.1)  # parttime

# Step 4: Fitted model with interaction terms
model.it <- lm(logwage ~. + education*smsa + experience*smsa
                + experience*parttime, data = data)
summary(model.it)
anova(model.it)

# Step 5: Residual analysis
model.res_analy <- lm(logwage ~ education + experience, data = data)
  
par(mfrow = c(2,2))
plot(model.res_analy)
