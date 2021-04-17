library(class)

########################################################
############### Example in help#########################
########################################################

# %% inspect dataset ----
iris3[1,2,3]   # iris is a 3 ways df
# 1st index: observation of flower of each class, 1:50
# 2nd index: features (sepal L & W, petal L & W), 1:4
# 3rd index: class (setosa, ver, virg), 1:3

# %% get training and test set----
train = rbind(iris3[1:25,,1], iris3[1:25,,2], iris3[1:25,,3])
train
# taking all 4 features of the first 25 observation of each class
# combine them by row

test = rbind(iris3[26:50,,1], iris3[26:50,,2], iris3[26:50,,3])


# %% get class factor ----
# our new dfs don't specify the species of each observation of flower
# so we are manually adding the class factor
cl = factor(c(rep("s",25), rep("c",25), rep("v",25)))

# first 25 = setosa = s
# second 25 = ver = c
# third 25 = virg = v

# %% classification using knn, with k=3 ----
set.seed(47)
knn_pred = knn(train, test, cl, k = 3, prob=TRUE)  # getting the prediction on the test set

# %% see the result ----
# see the attributes of the knn model
att = attributes(knn_pred)   # shows us the attributes of the df 
                             # att = levels, class, prob

# get the probabilities associated with the final prediction
prob_pred = att$prob
prob_pred

# This shows us the proportion of votes for the winning class.
# For example, for the first test instance we have 1 --> this means that 
# highest prob of predicting that instance as what class (s,v or c) is 100%
# first test instance prediction as class s = 100%, class v = 0%, class c = 0%.



# %% changing the value of k ----
# 1NN
set.seed(47)
knn1_pred=knn1(train, test, cl)   # by default k=1, so don't have to specify k here

# 3NN
#install.packages("caret")
library(caret)
set.seed(47)

knn3_pred=knn3Train(train, test, cl, k = 3, prob=TRUE)

# %% get all prob ----
# get the associated prob for all 3 classes for all test instance
attributes(knn3_pred)


# knn vs knn3 function
# knn -> only accepts numeric predictors & returns the % of the winning class
# knn3 -> fixes these issues & return vote % of each class

########################################################
############### Randomly sample from data###############
########################################################

# get indexes for training data
n = 25   # the number of training data in each class
NN = dim(iris3)[1]  # the total number of observations in each class
                    # NN = 50 in this case

set.seed(983)
index_s = sample(1:NN,n)  # randomly selecting n numbers from 1 to NN
index_c = sample(1:NN,n)  # randomly selecting 25 from 50
index_v = sample(1:NN,n)

# get training and test set
train_rand = rbind(iris3[index_s,,1], iris3[index_c,,2], iris3[index_v,,3])  # randomly selecting 25 observations from each classes
test_rand = rbind(iris3[-index_s,,1], iris3[-index_c,,2], iris3[-index_v,,3])  # minus here is reverse select

# get class factor for training data
train_label = factor(c(rep("s",n), rep("c",n), rep("v",n)))

# get class factor for test data
test_label_true = factor(c(rep("s",NN-n), rep("c",NN-n), rep("v",NN-n)))

# classification using knn, with k=5
kk = 5 # number of nearest neighbors

set.seed(275)

knn_pred = knn(train = train_rand,test = test_rand,
               cl = train_label, k = kk, prob = FALSE)
