##################################
###### Logistic regression ######
##################################
library(ISLR)

# have a look at the dataset
str(Smarket)
View(Smarket)

# get the correlation between predictors
# cor(Smarket)
cor(Smarket[, -9])   # delete the 9th column from the data set
                     # cuz we can't calculate cor for factor variables

# fit a logistic regression model
glm.fits = glm(Direction ~ Lag1 + Lag2 + Lag3 + Lag4 + Lag5 + Volume,
               data = Smarket, family = binomial)

summary(glm.fits)   # all p-value are high, so all not significant

# %% Classification

# Step 1: predict the probability that the market will go up
glm.probs = predict(glm.fits, type = "response")   # this is wrong cuz we aren't predicting on the test data set
glm.probs[1:10]
contrasts(Smarket$Direction)   # tell us Up is recognised as 0 or 1

# Step 2: classification based on the predicted probabilities
glm.pred = ifelse(glm.probs > .5, "Up", "Down")
glm.pred


####################################################
###### Train the model based on training data ######
###### Test the model for test data ######
####################################################

# get training data indexes
train = (Smarket$Year < 2005)

# get test data
Smarket.2005 = Smarket[!train, ]

dim(Smarket.2005)   # 252 rows, 9 features

Direction.2005 = Smarket$Direction[!train]

# train a logistic regression model based on training data
glm.fits = glm(Direction ~ Lag1 + Lag2 + Lag3 + Lag4 + Lag5 + Volume,
               data = Smarket, family = binomial, subset = train)

summary(glm.fits)

# predict probabilities that the market will go up for the test data
glm.probs = predict(glm.fits, Smarket.2005, type = "response")

# classification of the test data
glm.pred = ifelse(glm.probs > .5, "Up", "Down")

# now compare prediction to the ground truth
Direction.2005 = Smarket$Direction[!train]
Direction.2005[1:10]   # ground truth

glm.pred[1:10]   # prediction

# we can see the predictions don't match the actual data in general
