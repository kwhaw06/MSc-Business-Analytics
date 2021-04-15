#needed libraries up to now
library("car")
library("MASS")

#attach the dataset after is imported
attach(dataset)

#making non-sense negative experience values to meaningful 0's
dataset$experience <- ifelse(dataset$experience < 0, 0, dataset$experience)


#intorduction to our variables (means, quartiles)
#specify the nature of them and what they represent
#which are quantitative, which are qualitatitve
summary(dataset$wage)  
summary(dataset$education)
summary(dataset$region)
summary(dataset$ethnicity)
summary(dataset$smsa)
summary(dataset$parttime)
summary(dataset$experience)


#fitting a model with all variables
model <- lm(wage~.-id, data = dataset)
summary(model)

#correlinearity checked using vif
vif(model)

