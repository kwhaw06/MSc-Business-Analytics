#### Setup ####
library(tree)
library(randomForest)
library(gbm)
library(caret)

# load data
heart=read.csv("Heart.csv",header = TRUE)

# change chr to factor level
str(heart)
heart$ChestPain <- as.factor(heart$ChestPain)
heart$Thal <- as.factor(heart$Thal)
heart$AHD <- as.factor(heart$AHD)
str(heart)

# data cleaning
sum(is.na(heart))   # check missing values

heart=heart[complete.cases(heart),]   # remove rows with missing values
#### Decision tree: full ####
# random split to training and test set
set.seed(345)
train.index=createDataPartition(heart[,ncol(heart)],p=0.7,list=FALSE)
train=heart[train.index,]
test=heart[-train.index,]

# Train a decision tree
heart.tree=tree(AHD ~ . , train)   # write it like a regression
                                   # response var ~ features, dataset

summary(heart.tree)  # show us which variables are used when building the tree
                     # num of terminal nodes = num of trees
                     # res mean dev closer to 0 the better
                     # error rate is for train set, so don't use this
 
# have a look at the details of the tree
heart.tree
            # 280.7 -> the deviance 
            # "No" -> predicted class for majority of the data at that split
            # the prob after the prediction shows us excatly how much is predicted as "No"
            # Thal is split into 2 (num 2 & 3) -> num 2 has 1 level (normal), num 3 has 2 levels
            # deviance decrease by the split of Thal
            # * -> terminal node, last node

# plot the tree
plot(heart.tree)
text(heart.tree,pretty=1)

# Test error
pred=predict(heart.tree,test[,-ncol(test)],type="class")
mean(pred==test[,ncol(test)])   # accuracy rate

#### Decision tree: prune ####

# use cv to select the subtree
set.seed(203)
heart.cv = cv.tree(heart.tree,            # original tree
                   FUN = prune.misclass)  # use misclassfication error rate to prune the tree

heart.cv   # dev --> classification error rate cuz we used it to prune
           # select tree size with the smallest error rate to avoid overfitting
           # since we have 2 tree size of the smallest error rate, 
           # so we choose the smallest size, which is 14

# plot CV results
par(mfrow=c(1,2))

plot(heart.cv$size,heart.cv$dev,type="b",
     xlab="number of leaves of the tree",ylab="CV error rate%",
     cex.lab=1.5,cex.axis=1.5)

plot(heart.cv$k,heart.cv$dev,type="b",
     xlab=expression(alpha),ylab="CV error rate%",
     cex.lab=1.5,cex.axis=1.5)

# prune the tree
heart.prune = prune.misclass(heart.tree,
                             best = 14)   # 14 is obtained from result above
plot(heart.prune)
text(heart.prune,pretty=1)

# predict the test instances
pred.prune=predict(heart.prune,test[,-ncol(test)],type="class")

mean(pred.prune==test[,ncol(test)])  # this shows us the accuracy rate
                                     # improves from before (w/o pruning) line 52 = 79%

#### using caret to build trees ####
fitcontrol=trainControl(method = "repeatedcv", number = 10,
                        repeats = 3)

set.seed(1) 
heart.rpart=train(train[,-ncol(heart)],train[,ncol(heart)], 
                  method = "rpart", tuneLength=5,
                  trControl = fitcontrol)

heart.rpart   # cp -> complexity parameter
              # Choose size of tree based on cp

# To look at the details of this tree 
print(heart.rpart$finalModel)

# plot the tree
par(mfrow=c(1,1))
plot(heart.rpart$finalModel) 
text(heart.rpart$finalModel)

# get fancy trees by rattle
library(rattle)
fancyRpartPlot(heart.rpart$finalModel)  # if Thal=normal go to left hand side

#### Bagging ####
set.seed(103)
heart.bag = randomForest(AHD~.,data=train,
                         mtry=13, # num of features we choose to do the split  
                                  # unlike random forest, we use all the features to do the split, so 13 is the num of variables of the original dataset 
                         importance=TRUE,
                         ntree=500)   # number of trees

heart.bag   # OBB -> estimate of test error

pred.bag = predict(heart.bag,newdata=test[,-ncol(test)])
mean(pred.bag==test[,ncol(test)])

#### Random forest ####
set.seed(921)
heart.rf=randomForest(AHD~.,data=train,mtry=6,importance=TRUE,ntree=500)
heart.rf

pred.rf=predict(heart.rf,newdata=test[,-ncol(test)])
mean(pred.rf==test[,ncol(test)])   # obtain mean accuracy of test set

# importance of variables
importance(heart.rf)   # the most important variable should have the largest decrease in Gini index --> tell us about node purity

varImpPlot(heart.rf)   # depend on whether u care more about the final classification accuracy or node purity, then u can look at left or right plot
                       # Thal, Ca, ChestPain, Oldpeak variables seems important when doing classification as they rank higher in both plots

#### caret for random forest ####
fitControl=trainControl(method = "repeatedcv", number = 5,
                        repeats = 3)
set.seed(2) 
rfFit=train(AHD~.,data=train,method="rf",  # rf = random forest
            metric="Accuracy",
            trControl=fitControl,tuneLength=5) # Have a look at the model
rfFit

plot(rfFit)  # this shows that when we only randomly choose 2 features to do the split we have the highest acc

rfFit$finalModel
varImp(rfFit,scale=FALSE)

#### Boosting ####
set.seed(18)
train[,ncol(train)]=ifelse(train$AHD=="No",0,1)
test[,ncol(test)]=ifelse(test$AHD=="No",0,1)
heart.boost=gbm(AHD~.,data=train,distribution="bernoulli",n.trees=5000,
                interaction.depth=2,shrinkage=0.01)
summary(heart.boost)
pred.boost=predict(heart.boost,newdata=test[,-ncol(test)],n.trees=5000,type="response")
pred.boost=ifelse(pred.boost<0.5,0,1)
mean(pred.boost==test[,ncol(test)])
