####################
### Question 1.i ###
####################

library(caret)
library(pROC)

# import data
data = read.csv("newthyroid.txt")

# check whether data is imbalanced
table(data$class)

# create training and test sets
set.seed(12)
trainIndex = createDataPartition(data$class, p = 0.7, 
                                 list = FALSE, times = 20)

# create empty vectors to store knn and lda AUC values
knn.AUC.list = c()
lda.AUC.list = c()

for(i in 1:ncol(trainIndex)){
  # create training and test sets
  trainIndex.ite = trainIndex[,i]
  
  train.feature = data[trainIndex.ite,-1] # training features
  train.label = data$class[trainIndex.ite] # training labels
  test.feature = data[-trainIndex.ite,-1] # test features
  test.label = data$class[-trainIndex.ite] # test labels
  
  # set up train control
  fitControls <- trainControl(## 5-fold CV
    method = "repeatedcv",
    number = 5,
    ## repeated five times
    repeats = 5,
    summaryFunction = twoClassSummary,
    classProbs = TRUE,
    sampling="smote") #use up smote to improve the data set
  
  # knn - training process
  set.seed(45)
  knnFits=train(train.feature,train.label, 
                method = "knn",
                trControl = fitControls,
                metric = "ROC",
                preProcess = c("center","scale"),
                tuneGrid= expand.grid(k = c(seq(3,21,2))))
  
  # ROC curve for knn with SMOTE
  knn.preds <- predict(knnFits,test.feature)
  confusionMatrix(knn.preds,as.factor(test.label))
  knn.probss <- predict(knnFits,test.feature,type="prob")
  head(knn.probss)
  knn.ROCs <- roc(predictor=knn.probss$h,
                  response=test.label)
  
  # Append knn AUC of each loop to knn.AUC.list
  knn.AUC.list[i] = knn.ROCs$auc
  
  # LDA - training process
  set.seed(45)
  ldaFits = train(train.feature,train.label,
                  method = "lda",
                  trControl = trainControl(sampling="smote"))
  
  # ROC curve for LDA with SMOTE
  lda.preds <- predict(ldaFits,test.feature)
  confusionMatrix(lda.preds,as.factor(test.label))
  lda.probss <- predict(ldaFits,test.feature,type="prob")
  head(lda.probss)
  lda.ROCs <- roc(predictor=lda.probss$h,
                  response=test.label)
  
  # Append LDA AUC of each loop to lda.AUC.list
  lda.AUC.list[i] = lda.ROCs$auc
}

# inspect both AUC lists
knn.AUC.list
lda.AUC.list

#####################
### Question 1.ii ###
#####################

# first random split
trainIndex_1st = trainIndex[,1]

# create training and test set
train.feature_1st = data[trainIndex_1st,-1] # training features
train.label_1st=data$class[trainIndex_1st] # training labels
test.feature_1st=data[-trainIndex_1st,-1] # test features
test.label_1st=data$class[-trainIndex_1st] # test labels

## knn with smote
# set up train control
fitControls <- trainControl(## 5-fold CV
  method = "repeatedcv",
  number = 5,
  ## repeated five times
  repeats = 5,
  summaryFunction = twoClassSummary,
  classProbs = TRUE,
  sampling="smote")

# training process
set.seed(45)
knnFits=train(train.feature_1st,train.label_1st, method = "knn",
              trControl = fitControls,
              metric = "ROC",
              preProcess = c("center","scale"),
              tuneLength=10)

## lda with SMOTE
set.seed(45)
ldaFits=train(train.feature_1st,train.label_1st,
              method = "lda",
              trControl = trainControl(sampling="smote"))

## ROC curve for knn with SMOTE
knn.probss <- predict(knnFits,test.feature_1st,type="prob")
knn.ROCs <- roc(predictor=knn.probss$h,
                response=test.label_1st)
plot(knn.ROCs,main="ROC curve")

## ROC curve for lda
lda.probss <- predict(ldaFits,test.feature,type="prob")
lda.ROCs <- roc(predictor=lda.probss$h,
                response=test.label_1st)
lines(lda.ROCs,col="red")
legend("bottomright",legend=c("kNN","LDA"),
       col=c("black","red"),lty=c(1,1),cex=1,text.font=2)

######################
### Question 1.iii ###
######################

#check the auc value for kNN and LDA
knn.AUC.list
lda.AUC.list

#plot boxplots
boxplot(knn.AUC.list,lda.AUC.list,
        main = "boxplots for comparision(knn vs LDA)",
        names = c("kNN", "LDA"),
        col = c("orange","red"),
        border = "brown",
        horizontal = TRUE,
        notch = FALSE
)