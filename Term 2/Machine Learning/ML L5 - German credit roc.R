# When we have imbalanced data, the traditional classifying methods don't
# work well. What we can do is resampling the data such that we increase
# the minority data, so we have a more balanced data set. This is called
# upsampling. Another approach is down sampling, which is reducing
# majority class to minority. Most popular is upsampling method.

library(ISLR)
library(class)
library(caret)
library(pROC)
library(MASS)

data("GermanCredit")

## Delete two variables where all values are the same for both classes
GermanCredit[,c("Purpose.Vacation","Personal.Female.Single")] <- list(NULL)

## Create training/test split
# create training and test sets
set.seed(12)
trainIndex = createDataPartition(GermanCredit$Class, p = 0.7, list = FALSE, times = 1)
train.feature=GermanCredit[trainIndex,-10] # training features
train.label=GermanCredit$Class[trainIndex] # training labels
test.feature=GermanCredit[-trainIndex,-10] # test features
test.label=GermanCredit$Class[-trainIndex] # test labels

##########################
# WITHOUT SMOTE FUNCTION #
##########################

## kNN
#### knn ####
#### set up train control
fitControl <- trainControl(## 5-fold CV
  method = "repeatedcv",
  number = 5,
  ## repeated five times
  repeats = 5,
  summaryFunction = twoClassSummary,
  classProbs = TRUE)

#### training process
set.seed(5)
knnFit=train(train.feature,train.label, method = "knn",
             trControl = fitControl,
             metric = "ROC",
             preProcess = c("center","scale"),
             tuneLength=10)
knnFit

#### LDA ####
ldaFit=train(train.feature,train.label, method = "lda",
             trControl = trainControl(method = "none"))

ldaFit$finalModel

#### Plot ROC curves for kNN and LDA on one plot ####
#### ROC curve for knn
library(pROC)
knn.pred <- predict(knnFit,test.feature)
confusionMatrix(knn.pred,test.label)

knn.probs <- predict(knnFit,test.feature,type="prob")
head(knn.probs)

knn.ROC <- roc(predictor=knn.probs$Bad,
               response=test.label)

knn.ROC$auc
plot(knn.ROC,main="ROC curve")

#### ROC curve for lda ####
lda.pred <- predict(ldaFit,test.feature)
confusionMatrix(lda.pred,test.label)

lda.probs <- predict(ldaFit,test.feature,type="prob")
head(lda.probs)

lda.ROC <- roc(predictor=lda.probs$Bad,
               response=test.label)
lda.ROC$auc

lines(lda.ROC,col="blue") ## add a line to previous plot
legend("bottomright",legend=c("kNN","LDA"),
       col=c("black","blue"),lty=c(1,1),cex=1,text.font=2)

#######################
# WITH SMOTE FUNCTION #
#######################

# To rebalance the dataset, we can simply use the following 
#``trainControl` setting.

# check if data is imbalanced
table(GermanCredit$Class)
# 300 Bad, 700 Good --> not so balanced

#### knn with smote ####
#### set up train control
fitControls <- trainControl(## 5-fold CV
  method = "repeatedcv",
  number = 5,
  ## repeated five times
  repeats = 5,
  summaryFunction = twoClassSummary,
  classProbs = TRUE,
  sampling="smote")   # up sampling just need this 1 line

#### training process
set.seed(5)

knnFits=train(train.feature,train.label, method = "knn",
              trControl = fitControls,
              metric = "ROC",
              preProcess = c("center","scale"),
              tuneLength=10)

knnFits

# The same applies to LDA.

#### lda with SMOTE ####
set.seed(5)
ldaFits=train(train.feature,train.label, method = "lda",
              trControl = trainControl(sampling="smote"))   # same here, just add smote
ldaFits
ldaFits$finalModel


# Now we can draw the ROC curves the same as before.

#### ROC curve for knn with SMOTE ####
knn.preds <- predict(knnFits,test.feature)
confusionMatrix(knn.preds,test.label)
knn.probss <- predict(knnFits,test.feature,type="prob")
head(knn.probss)
knn.ROCs <- roc(predictor=knn.probss$Bad,
                response=test.label)
knn.ROCs$auc
plot(knn.ROCs,main="ROC curve")

#### ROC curve for lda 
lda.preds <- predict(ldaFits,test.feature)
confusionMatrix(lda.preds,test.label)
lda.probss <- predict(ldaFits,test.feature,type="prob")
head(lda.probss)
lda.ROCs <- roc(predictor=lda.probss$Bad,
                response=test.label)
lda.ROCs$auc
lines(lda.ROCs,col="blue")
legend("bottomright",legend=c("kNN","LDA"),
       col=c("black","blue"),lty=c(1,1),cex=1,text.font=2)