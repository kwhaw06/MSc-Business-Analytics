# %% Q.1 ----
# load data
install.packages("mlbench")
library(mlbench)
data("PimaIndiansDiabetes2")
any(is.na(PimaIndiansDiabetes2))  # this tells us there are NAs in the data
PimaIndiansDiabetes2 <- na.omit(PimaIndiansDiabetes2)

# spilting the data into training (80%) and testing (20%) set randomly
set.seed(123)
# round up in case the data isn't spilt nicely
train.size <- round(0.8*(dim(PimaIndiansDiabetes2)[1]))
# sample from row 1 to nrows from dataset, size = train size
train <- sample(1:dim(PimaIndiansDiabetes2)[1], train.size)
test <- -train
# create the train & test dataset
train.data <- PimaIndiansDiabetes2[train, ]
test.data <- PimaIndiansDiabetes2[test, ]

# %% Q2 ----
# Step 1: Dummy code categorical predictor variables
# Because our response variable is a categorical data
x <- model.matrix(diabetes~., train.data)[,-1]   # selecting training set data

# Step 2: Convert the outcome (class) to a numerical variable
y <- ifelse(train.data$diabetes == "pos", 1, 0) # positive = 1, negative = 0

# Step 3: Fitting a Lasso model
library(glmnet)
set.seed(123)
cv.lasso <- cv.glmnet(x, y, alpha = 1, family = "binomial")
plot(cv.lasso)

# The plot displays the cross-validation error according to the log of 
# lambda. The left dashed vertical line indicates that the log of the 
# optimal value of lambda is approximately -4.5, which is the one that 
# minimizes the prediction error. This lambda value will give the most 
# accurate model. The exact value of lambda can be viewed as follow:

# Step 4: Finding the best lambda
cv.lasso$lambda.min

# %% Q3 ----
coef(cv.lasso, cv.lasso$lambda.min)

# From the output above, pressure and insulin have coefficients 
# exactly equal to zero.


# %% Q4 ----
# Final model with lambda.min
lasso.model <- glmnet(x, y, alpha = 1, family = "binomial",
                      lambda = cv.lasso$lambda.min)

# Make prediction on test data
x.test <- model.matrix(diabetes ~., test.data)[,-1]

probabilities <- predict(lasso.model, newx = x.test, 
                         s ="lambda.min", type = "response")

predicted.classes <- ifelse(probabilities > 0.5, "pos", "neg") # if % > 50%, then assing "pos", else assign "neg"

# Model accuracy
observed.classes <- test.data$diabetes
mean(predicted.classes == observed.classes)

# %% Q5 ----
# Fit unpenalized logistic model
logistic.model <- glm(diabetes ~., data = train.data, family = "binomial")

# Make prediction on test data
probabilities <- predict(logistic.model, test.data, type = "response")
predicted.classes <- ifelse(probabilities > 0.5, "pos", "neg")

# Model accuracy
observed.classes <- test.data$diabetes
mean(predicted.classes == observed.classes)

# Conclusion --> The model accuracy of the two approaches is the same.
