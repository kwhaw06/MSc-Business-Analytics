########################################################
################ Data Preparation ######################
########################################################

# %% install package and import library
# install.packages(("kernlab"))
# install.packages(("class"))
library(kernlab)
library(class)
data(spam)
# ?spam

# %% get row index of spam and non_spam dataset
type = spam$type
s = which(type == "spam")
ns = which(type == "nonspam")

########################################################
########### Training and Test Set and CL ###############
########################################################

# %% Randomly select 100 rows for spam and nonspam training set
train_n = 100

# get the index for spam and non-spam rows
set.seed(111)
train_s_index = sample(s, train_n) 
train_ns_index = sample(ns, train_n) 

# get the rows for spam and non-spam
train_s = spam[train_s_index,] 
train_ns = spam[train_ns_index,] 

# combine two 100 rows and delete the last column (type)
train = rbind(train_s, train_ns) 
train = train[,-58] 

# %% Randomly select 50 rows for spam and non-spam test set
test_n = 50

# the rest of rows to avoid repetition
s_1 = s[-train_s_index] 
ns_1 = ns[-train_ns_index]

# get the index for spam and non-spam rows
set.seed(111)
test_s_index = sample(s_1, test_n) 
test_ns_index = sample(ns_1, test_n) 

# get the rows for spam and non-spam
test_s = spam[test_s_index,] 
test_ns = spam[test_ns_index,] 

# combine two 100 rows and delete the last column (type)
test = rbind(test_s, test_ns) 
test = test[, -58] 

# %% get class factor for training data
cl = factor(c(rep("spam", train_n), rep("nonspam", train_n)))

########################################################
################# kNN classification ###################
########################################################

# 1 Nearest Neighbours(1NN)
set.seed(47)
knn_pred_1 = knn(train, test, cl, k = 1, prob=TRUE)
knn_pred_1

# 9 Nearest Neighbours(9NN)
set.seed(47)
knn_pred_9 = knn(train, test, cl, k = 9, prob=TRUE)
knn_pred_9

# 25 Nearest Neighbours(25NN)
set.seed(47)
knn_pred_25 = knn(train, test, cl, k = 25, prob=TRUE)
knn_pred_25

########################################################
################### Check Error Term ###################
########################################################

# define true_label
true_label = factor(c(rep("spam", test_n), rep("nonspam", test_n)))

# prediction accuracy
acc_1NN = mean(knn_pred_1 == true_label)
acc_9NN = mean(knn_pred_9 == true_label)
acc_25NN = mean(knn_pred_25 == true_label)

# compare prediction accuracy when k = 1, 9, 25
acc_1NN
acc_9NN
acc_25NN