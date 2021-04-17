## German Credit Data

###
#   Now we try to classify the German credit data by LDA. 
#   Since we just need to distinguish between two classes, good or bad, 
#   there is no parameter to be tuned for this task.
###

library(caret)
#load german credit data from caret package

data(GermanCredit)
# classify two classes: good or bad

## Show the first 10 columns
str(GermanCredit[, 1:10])

## Delete two variables where all values are the same for both classes
GermanCredit[,c("Purpose.Vacation","Personal.Female.Single")] <- list(NULL)

# create training and test sets
set.seed(12)
trainIndex = createDataPartition(GermanCredit$Class, p = 0.7, 
                                 list = FALSE, times = 1)

train.feature = GermanCredit[trainIndex,-10] # training features
                                        # take out 10th col cuz it is the class col 
train.label = GermanCredit$Class[trainIndex] # training labels
test.feature = GermanCredit[-trainIndex,-10] # test features
test.label = GermanCredit$Class[-trainIndex] # test labels

#### training process
ldaFit=train(train.feature,train.label, 
             method = "lda",   # using lda cuz there is no need to tune in this case since C (num of class = 2) - 1 = 1 direction
             trControl = trainControl(method = "none"))  # none cuz we dont need to tune

ldaFit$finalModel

###
# Now we can predict the labels of test instances:
###

#### test process
pred=predict(ldaFit,test.feature)

acc=mean(pred==test.label)
acc

table(pred,test.label)

###
# We can see that there is a warning for variable colinearity given by the `lda` function. This means that there are variables with correlations of 1 or -1. Now let's have a look at variable colinearity. We can do this by plot the pairwise correlations. Given that there are 59 variables, a plot of all variables will be too crowded. We can creat a plot that contain a subset of the variables.
###

#### check variable colinearity
library(corrplot)
corrplot(round(cor(train.feature[,40:50]),2),  # only viewing 40th to 50th variables
         type = "upper")

# colinearity won't affect classification result.
# It only affect ur prediction for weight 
# which is under "coefficients of linear discriminants"
# weight won't be stable.