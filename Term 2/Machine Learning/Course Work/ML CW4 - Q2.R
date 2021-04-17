#### Step 1: Generate data and the plot ####
set.seed(1)
X <- matrix(rnorm(150*2), ncol = 2)

# Horizontal translation
transl.1 <- 4  # translation for the 2nd class
transl.2 <- 8  # translation for the 3rd class

# Applying horizontal translation to the 2nd class
X[51:75, ] <- X[51:75, ] + transl.1  
X[76:100, ] <- X[76:100, ] - transl.1

# Applying horizontal translation to the 3rd class
X[101:125, ] <- X[101:125, ] + transl.2  
X[126:150, ] <- X[126:150, ] - transl.2

# Assigning classes to the data points
y <- c(rep(0, 50), rep(1, 50), rep(2, 50))  # the vertical translation 
dat <- data.frame(x = X, y = as.factor(y))  # turn y into a factor object

# Scatter plot
plot(X, col = y + 1 , pch = 19)
legend("bottomright", legend = paste("Group", 1:3), col = 1:3, pch = 19, bty = "n")

#### Step 2: Split the data set to a training (50%) and a test set (50%) ####
library(caret)

set.seed(1)
train.index = createDataPartition(dat[,ncol(dat)],p=0.5,list=FALSE)
train = dat[train.index,] 
train.x = train[,-c(3)]; train.y = train[,c(3)]
test = dat[-train.index,]
test.x = test[,-c(3)]; test.y = test[,c(3)]

#### Step 3: Train the SVM models with different kernel ####
library(e1071)

# Set fit control with 5-fold CV
fitControl=trainControl(
  method = "repeatedcv",
  number = 5,
  repeats = 3)

### Polynomial Kernel ###
# Tune parameters
grid_poly = expand.grid(degree = c(2,3,4),
                        scale = c(0.01, 0.1, 1),
                        C = c(0.01, 0.1, 1, 10))

# Train SVM model with the polynomial kernel
set.seed(1)
svm.poly = train(train.x, train.y, method = "svmPoly",
                 trControl = fitControl,
                 preProcess = c("center", "scale"),
                 tuneGrid = grid_poly)

svm.poly
plot(svm.poly)

# Predicting the test set
pred_svm.poly = predict(svm.poly, test.x)
table(pred_svm.poly, test.y)

# Prediction accuracy
sum(diag(table(pred_svm.poly, test.y))/sum(table(pred_svm.poly, test.y)))

### RBF Kernel ###
# Tune parameters
grid_radial=expand.grid(sigma = c(0.01, 0.1, 1,10),
                        C = c(0.01, 0.1, 1, 10))

# Train SVM model with the RBF kernel
set.seed(1)
svm.RBF = train(train.x, train.y, method = "svmRadial",
                trControl = fitControl,
                preProcess = c("center", "scale"),
                tuneGrid = grid_radial)

svm.RBF
plot(svm.RBF)

# Predicting the test set
pred_svm.RBF = predict(svm.RBF, test.x)
table(pred_svm.RBF, test.y)

# Prediction accuracy
sum(diag(table(pred_svm.RBF, test.y))/sum(table(pred_svm.RBF, test.y)))

### Linear Kernel ###
# Tune parameters
grid_linear = expand.grid(C = c(0.01, 0.1, 1, 10))

# Train SVM model with the linear kernel
set.seed(1)
svm.linear = train(train.x, train.y, method = "svmLinear",
                   trControl = fitControl,
                   preProcess = c("center", "scale"),
                   tuneGrid = grid_linear)

svm.linear
plot(svm.linear)

# Predicting the test set
pred_svm.linear = predict(svm.linear, test.x)
table(pred_svm.linear, test.y)

# Prediction accuracy
sum(diag(table(pred_svm.linear, test.y))/sum(table(pred_svm.linear, test.y)))
