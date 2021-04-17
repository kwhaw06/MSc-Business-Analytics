library(ISLR)
library(class)
library(ROCR)
library(caret)
str(Caravan)

summary(Caravan)   # variables are on different scale (big difference in mean)
                   # we need to scale them before using kNN

table(Caravan[,86])   # most instances are in the "No" class --> very imbalanced

####################################################
# scale the feature variables
Caravan_scale = scale(Caravan [,-86])   # don't take the class column
####################################################

# test sample index
index=1:1000
# get training and test set
train.X=Caravan_scale[-index,]
test.X=Caravan_scale[index,]
train.Y=Caravan$Purchase[-index]
test.Y=Caravan$Purchase[index]

####################################################
# kNN
set.seed(47)
knn3_pred=knn3Train(train.X, test.X, train.Y, k = 9, prob=TRUE)

####################################################
#### calculate sensitivity and specificity
source("performance-measure.R")

pos=levels(test.Y)[2]   # define "pos" as "Yes"
neg=levels(test.Y)[1]   # define "neg" as "No"

measures=performance.measure(as.factor(knn3_pred),test.Y,pos,neg)
measures

####################################################
#### compare self-defined function with functions in caret
sensitivity(as.factor(knn3_pred),test.Y,pos)   # results are the same as the one we get above
specificity(as.factor(knn3_pred),test.Y,neg)

####################################################

#### ROC curve
att=attributes(knn3_pred)$prob   # take out the predicted %

pred.ROCR = prediction(att[,2],   # the "Yes" class
                       (test.Y),  # the ground truth labels 
                       label.ordering = c("No","Yes"))

roc.curve = performance(pred.ROCR,
                        "tpr",   # true positive right = Y-axis
                        "fpr")   # false positive right = X-axis

plot(roc.curve,lwd=2,cex.lab=1.5,cex.axis=1.5,  font.lab=2,
     xlab="False positive rate (1-specificity)",
     ylab="True positive rate (sensitivity)")

#### add a line with auc=0.5
x=seq(0,1,0.01); y=x
lines(x,y,lwd =2, col =" red",lty=2)
legend("bottomright","AUC=0.683",cex=1.5,text.font=2)

#### get auc
auc = performance(pred.ROCR, measure = "auc")
auc = auc@y.values[[1]]
auc

################################################

### Dealing with imbalanced data 
### Use AUC to tune parameter k

############ Get the ROC curve by caret and pROC
#### set up train control
fitControl = trainControl(## 5-fold CV
  method = "repeatedcv",
  number = 5,
  ## repeated five times
  repeats = 5,
  summaryFunction = twoClassSummary,
  classProbs = TRUE)

#### training process
set.seed(5)
knnFit=train(train.X,train.Y, method = "knn",
             trControl = fitControl,
             metric = "ROC",   # instead of using acc, we use AUC here to tune k. AUC is called ROC.
             preProcess = c("center","scale"),
             tuneLength=5)

knnFit   # the "ROC" col = AUC

#### test process
knn.pred = predict(knnFit,test.X)
confusionMatrix(knn.pred,   # predicted labels
                test.Y,     # ground truth labels
                positive="Yes")   # specify pos class as yes class

# "no information rate" = proportion of the majority class
# "P-value" --> can't reject means model is bad
# "kappa" --> how much better is ur model compare to random guessing, 0 means equally bad. Value close to 1 means ur classifier is better than random guessing
# "Mc... P-Value" --> test the error rate of 2 classes are different or not. Value close = 0 means error rate of the classes are very different

#### draw an ROC curve by pROC package
knn.probs = predict(knnFit,test.X,type="prob")   # take the predicted %

head(knn.probs)

library(pROC)

knn.ROC = roc(predictor=knn.probs$No,
              response=test.Y)

knn.ROC$auc

plot(knn.ROC,main="ROC curve")

