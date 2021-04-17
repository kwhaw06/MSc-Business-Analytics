####################################################
##### Use LOOCV to tune k#########
####################################################

##### 
library(class)

# % get indexes for training data ----
n = 25 # the number of training data in each class
NN = dim(iris3)[1] # the total number of observations in each class

set.seed(983)
index_s=sample(1:NN,n)   # randomly select 25 indexes from each tables
index_c=sample(1:NN,n)
index_v=sample(1:NN,n)

# % get training and test set ----
train_rand = rbind(iris3[index_s,,1], iris3[index_c,,2], iris3[index_v,,3])
test_rand = rbind(iris3[-index_s,,1], iris3[-index_c,,2], iris3[-index_v,,3])

# % get class factor for training data ----
train_label = factor(c(rep("s",n), rep("c",n), rep("v",n)))

# % get class factor for test data ----
test_label_true = factor(c(rep("s",NN-n), rep("c",NN-n), rep("v",NN-n)))

# % evaluate k=1,3,5,7,9 on the training data using LOOCV ----
kk = c(1,3,5,7,9)

# initialize acc to store the mean accuracy of LOOCV for 5 $k$
acc = vector("numeric",length=length(kk))
acc

set.seed(649)
for(ii in 1:length(kk)){
  knn_pred = knn.cv(train = train_rand, cl = train_label, k = kk[ii])
  acc[ii] = mean(knn_pred == train_label)
}
# Get the first k that has the largest accuracy here we can also 
# randomly choose any k that has the largest accuracy if we have 
# several largest values.
acc

kk_LOOCV = kk[which.max(acc)]
 
# $ use the k tuned by the training set to classify the test set ----
set.seed(275)

knn_pred_test = knn(train = train_rand, test = test_rand,
                    cl = train_label, k = kk_LOOCV, prob = FALSE)

acc_test = mean(knn_pred_test == test_label_true)
acc_test
