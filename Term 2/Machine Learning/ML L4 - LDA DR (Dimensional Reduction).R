####################################################
##### Use LDA as a dimension reduction method#########
####################################################

library(caret)

#load german credit data from caret
data(GermanCredit)

# classify two status: good or bad
## Show the first 10 columns
str(GermanCredit[, 1:10])

## Delete two variables where all values are the same for both classes
GermanCredit[,c("Purpose.Vacation","Personal.Female.Single")] <- list(NULL)

####################################################
##### use knn directly --> Approach 1
# create training and test sets
set.seed(12)
trainIndex = createDataPartition(GermanCredit$Class, p = 0.7, list = FALSE, times = 1)

train.feature=GermanCredit[trainIndex,-10] # training features
train.label=GermanCredit$Class[trainIndex] # training labels
test.feature=GermanCredit[-trainIndex,-10] # test features
test.label=GermanCredit$Class[-trainIndex] # test labels

# set up train control
fitControl <- trainControl(## 10-fold CV
  method = "repeatedcv",
  number = 10,
  ## repeated five times
  repeats = 5)

# training process
set.seed(5)
knnFit=train(train.feature,train.label, method = "knn",
             trControl = fitControl,
             metric = "Accuracy",   # choose the K with the highest acc
             preProcess = c("center","scale"),   # pre-processing all variables by standardise the features 
             tuneLength=10)   # means choose 10 K starting from 5

knnFit   # shows us the accuracy of each K

plot(knnFit)
knnFit$finalModel   # telling us that K=9 is the best

# test process
pred=predict(knnFit,test.feature)

acc=mean(pred==test.label)
acc   # shows us the acc when use K=9 on test set

####################################################
##### use lda to reduce dimension before using knn ---> Approach 2

# reduce dimension by lda
library(MASS)

fit=lda(train.feature,train.label)

train.feature.proj=predict(fit,train.feature)$x  # "x" --> the projected points
                                                 # "x" only has 1 column (LDA1) cuz we only have 2 classes meaning only 1 direction
test.feature.proj=predict(fit,test.feature)$x

# set up train control
fitControl <- trainControl(## 10-fold CV
  method = "repeatedcv",
  number = 10,
  ## repeated five times
  repeats = 5)

# training process of knn
set.seed(5)
knnFit2=train(train.feature.proj,train.label, method = "knn",
              trControl = fitControl,
              metric = "Accuracy",
              preProcess = c("center","scale"),
              tuneLength=10)

knnFit2  # 1 predictor -> reduce dimension from 59 (variables) to 1 (point)
         # result -> K = 21 = the best option
plot(knnFit2)   # can see this from plot too

knnFit2$finalModel

# test process
pred2=predict(knnFit2,test.feature.proj)
acc2=mean(pred2==test.label)
acc2

# Result -> Dimension reduction by LDA in this data set improves acc of kNN
# But LDA doesn't work well on all sort of data set, need to check which model is better