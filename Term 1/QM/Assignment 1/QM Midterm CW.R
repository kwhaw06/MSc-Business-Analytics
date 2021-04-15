# importing the data
data <- read.table("wage.txt", header=T)
data

# data Cleaning --> getting rip of person id
data["id"] <- NULL
str(data)

# setting up the regression model which include all variables
wage.lm1 <- lm(wage ~ ., data = data)
summary(wage.lm1)

library(MASS)
anova(wage.lm1)

# adding all possible interaction terms
wage.lm2 <- lm(wage ~ (education + experience + ethnicity + smsa + region + 
                         parttime)^2, 
               data = data)

summary(wage.lm2)
anova(wage.lm2)
