###########################################
##### Use the lda function in MASS#########
###########################################

##### 
library(MASS) # the lda function is in the MASS library

##### 
# Prepare training and test set:
n=25 # the number of training data in each class
NN=dim(iris)[1]/3  # the total number of observations in each class
set.seed(983)
index_s=sample(which(iris$Species=="setosa"),n)
index_c=sample(which(iris$Species=="versicolor"),n)
index_v=sample(which(iris$Species=="virginica"),n)

# get training and test set
train_rand = rbind(iris[index_s,], iris[index_c,], iris[index_v,])
test_rand = rbind(iris[-c(index_s,index_c,index_v),])

# get class factor for training data
train_label= factor(c(rep("s",n), rep("c",n), rep("v",n)))

# get class factor for test data
test_label_true=factor(c(rep("s",NN-n), rep("c",NN-n), rep("v",NN-n)))

##### 
# fit the lda model
fit1=lda(Species~.,           # y ~ x1, x2, ...
         data=train_rand)     # data must contain features and labels
fit1

#### interpretation of fit 1 ####

# "Prior % of groups" -> the % of each class in the original data
# "Group means" -> original group means
# "Coefficients of linear discriminates" -> refers to directions (in this case we have 3 classes, so max 2 directions)
# "Proportion of trace" -> discrimination power for each direction
                         # This is the proportion of between-group and within-group standard deviation. 
                         # You can understand it as how much separation we achieve on each direction. 

################################################################

##### prediction for test set
pred=predict(fit1,test_rand[,-5])
pred

#### interpretation of pred ####

# "class" -> predicted class for each flower
# "posterior" -> % of a flower is a particular class (all classes are shown), 
               # then we classify the flower to the class with the highest %
# "x" -> the 2D location of the flowers when projecting from 4D (4 classes) to 
       # 2D plot for classification purpose


################################################################

##### get the classification accuracy
acc = mean(test_rand[,5]==pred$class)
acc
