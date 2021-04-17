####################
### Question 2.i ###
####################

myFDA <- function(X,y){
  ########################################################
  # This function calculates the linear discriminant for binary
  # classification.
  # Input: Feature matrix, X (N by p) and label vector, y (N by 1)
  # Output: Linear discriminant, w (p by 1)
  ########################################################
  
  ## Step 1: Data Preparation
  # 1.1: Get class 
  class1=unique(y)[1]
  class2=unique(y)[2]
  
  # 1.2: Combine label and features
  train_X = cbind(X,y)
  
  # 1.3: Get dataset for different class
  X1=train_X[y==class1,TRUE]
  X2=train_X[y==class2,TRUE]
  
  # 1.4: Delete label for calculating
  x1<- X1[,-ncol(train_X=='y')]
  x2<- X2[,-ncol(train_X=='y')]
  
  ## Step 2: Calculation
  # 2.1: Calculate mean
  mu1 = apply(x1,2,mean)
  mu2 = apply(x2,2,mean)
  
  # 2.2: Calulate cov of matrix
  S1=cov(x1)
  S2=cov(x2)
  
  # 2.3: Calculate within 
  S_w=S1+S2
  
  ## Step 3: Obtain the optimal w
  # Optimal w
  w=solve(S_w)%*%(mu1-mu2)
  
  return(w)
}