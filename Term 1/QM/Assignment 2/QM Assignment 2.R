# %% Q1 ----
# % Step 1: importing the data & data cleaning ----
data <- read.table("wage.txt", header=T)

# making negative experience values to meaningful 0's
data$experience <- ifelse(data$experience < 0, 0, data$experience)

# unique values under wage column
sum(is.na(data))

# % Step 2: Fitting the data
# checking the minimum value of wage
min(data['wage'])   

# Fitting Gamma GLM to the data
model_gamma <- glm(wage ~ ., data=data, family=Gamma(link="log"))
summary(model_gamma)

par(mfrow=c(2,2))
plot(model_gamma)

