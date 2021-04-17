library(caret)
library(AppliedPredictiveModeling)
library(e1071)

########################################################
###############      pairs plot      ###################
########################################################

transparentTheme(trans = .4)
featurePlot(x = iris[, 1:4],   # the features (e.g. width, length, etc)
            y = iris$Species,  # the label (e.g. setosa, ver, virg)
            plot = "pairs",    # specify that we want a pairs plot
            ## Add a key at the top
            auto.key = list(columns = 3))  # add a key (symbol for each classes) at the top

########################################################
############   get training/test set   #################
########################################################

set.seed(215)

# createDataPartition --> Randomly split the data set into 
# train & test set without us doing it manually.

train.indx=createDataPartition(iris$Species,  # the labels
                               p=0.5,         # % of the training instances (e.g. 50% of each class = train data)   
                               list=FALSE,    # format of output, don't want list form, so output = vector/matrix
                               times = 1)     # how many times you want to repeat the process

train=iris[train.indx,-5]; train.label=iris[train.indx,5]
test=iris[-train.indx,-5]; test.label=iris[-train.indx,5]

########################################################
#############       knn in caret      ##################
########################################################

#### set up train control
fitControl <- trainControl(## 10-fold CV
  method = "repeatedcv",   # repeated CV
  number = 10,   # number of folds
  repeats = 5)   # repeat this process 5 times

#### training process
set.seed(596)

knnFit1=train(train,                   # features
              train.label,             # labels
              method = "knn",          # classifier method
              trControl = fitControl,
              metric = "Accuracy",
              tuneLength=10)           # num of K

knnFit1         # shows us the K that brings the highest acc
plot(knnFit1)   # visualization of K acc
                # If you have 2 K with the same acc, system will choose
                # the higher K because it is less flexible = avoid
                # overfitting.

#### test process
pred1=predict(knnFit1,   # the model we use to make prediction
              test)      # our test features

acc1=mean(pred1==test.label)
acc1

########################################################
####       specify a tuning grid     ###################

kNNGrid=expand.grid(k=c(1,3,5,7,9,11))   # instead of using the default K
                                         # to model the train data, we can
                                         # select the K we want

#### training process
set.seed(596)

knnFit2=train(train,train.label, method = "knn",
              trControl = fitControl,
              metric = "Accuracy",
              tuneGrid=kNNGrid)   # using the K we choose

knnFit2
plot(knnFit2)

#### test process
pred2=predict(knnFit2,test)
acc2=mean(pred2==test.label)
acc2

########################################################
#### preprocessing: standardise data###################
set.seed(596)

knnFit3=train(train,train.label, method = "knn",
              trControl = fitControl,
              metric = "Accuracy",
              preProcess = c("center","scale"),  # this part standardized the features
              tuneGrid=kNNGrid)

knnFit3
plot(knnFit3)

#### test process
pred3=predict(knnFit3,test)

acc3=mean(pred3==test.label)
acc3
