##################
## Question 1.1 ##
##################

# Load data
library(caret)
data("GermanCredit")

# Delete two variables where all values are the same for both classes
GermanCredit[,c("Purpose.Vacation","Personal.Female.Single")] <- list(NULL)

# Check missing values
sum(is.na(GermanCredit))

# Random split to training and test set
set.seed(111)
train.index = createDataPartition(GermanCredit[,ncol(GermanCredit)],p=0.7,list=FALSE)
train = GermanCredit[train.index,]
test = GermanCredit[-train.index,]

# Train a decision tree
library(tree)
GermanCredit.tree = tree(Class ~ . , train)

# Determine the optimal tree size with 10-fold CV
set.seed(111)
GermanCredit.cv = cv.tree(GermanCredit.tree, FUN=prune.misclass, K=10)

# Plot the cross-validation results
par(mfrow=c(1,1))
plot(GermanCredit.cv$size,GermanCredit.cv$dev,type="b",
     xlab="number of leaves of the tree",ylab="CV error rate%",
     cex.lab=1.5,cex.axis=1.5)

# Prune the tree to the subtree with size 5
GermanCredit.prune = prune.misclass(GermanCredit.tree,best = 5)
par(mfrow=c(1,1))
plot(GermanCredit.prune)
text(GermanCredit.prune,pretty=1,cex=0.8)

# Predict the test instances
pred.prune = predict(GermanCredit.prune,test[,-c(10)],type="class")
table(pred.prune,test[,c(10)])

# Test error rate of the pruned tree
1 - mean(pred.prune==test[,c(10)])

##################
## Question 1.2 ##
##################

library(randomForest)

# Use 10-fold CV to optimize the parameter for random forest
fitControl=trainControl(
  method = "repeatedcv",
  number = 10,  
  repeats = 3)

set.seed(111)
rfFit=train(Class ~ . ,data=train,method="rf",metric="Accuracy",
            trControl=fitControl,tuneLength=5)

rfFit
plot(rfFit)

# Train a random forest with optimal mtyr = 16
set.seed(111)
GermanCredit.rf = randomForest(Class ~ .,data=train,mtry=16,
                               importance=TRUE,ntree=500)
pred.rf = predict(GermanCredit.rf,newdata=test[,-c(10)])
1 - mean(pred.rf==test[,c(10)])

# variable importance plot
plot(varImp(rfFit))

##################
## Question 1.3 ##
##################

library(pROC)

# random forest
rf_prediction = predict(GermanCredit.rf,newdata=test[,-c(10)],type="prob")

# decision tree
dt_prediction = predict(GermanCredit.prune,test[,-c(10)],type="vector")

# ROC curves
ROC_rf <- roc(test$Class, rf_prediction[,2])
ROC_dt <- roc(test$Class, dt_prediction[,2])

# AUC for each ROC curve
ROC_rf_auc <- auc(ROC_rf)
ROC_dt_auc <- auc(ROC_dt)

# plot ROC curves
plot(ROC_rf, col = "green", main = "ROC For Decison Tree vs Random Forest")
lines(ROC_dt, col = "red")
legend("bottomright",legend=c("Decision Tree","Random Forest"),
       col=c("red","green"),lty=c(1,1),cex=1,text.font=2)

# AUC values the ROC curves
ROC_dt_auc  
ROC_rf_auc  