library(e1071)
data(iris)
attach(iris)

#### classification mode ####
# default with factor response:
model = svm(Species ~ ., data = iris)  # svm automatically do classification if ur response variable is cat.
                                       # or do regression if ur resposne variable is numerical.
                                       # if want to do classification when response = numeric, then transform it into a factor first

# alternatively the traditional interface:
model = svm(iris[,-5], iris[,5])

print(model)  # by default, the parameter C is set to cost = 1

summary(model)  # (8 22 21) -> num of support vector from class 1 to 3

# test with train data
pred = predict(model, iris[,-5])  # just example, hasn't split test and train data set
# (same as:)
pred = fitted(model)

# Check accuracy:
table(pred, iris[,5])  # confusion matrix of our prediction
                       # only have 2 + 2 = 4 misclassification

# compute decision values and probabilities:
pred = predict(model, iris[,-5], decision.values = TRUE)

attr(pred, "decision.values")[1:4,]  # for col 1 = set/vers if value of instance = pos we classify as set, if value = neg we classify as vers
                                     # for row 1, vote = set, set, vers
                                     # instance 1 = classify as set cuz majority vote = set

pred[1:4]  # shows us the prediction of the first 4 instances

# visualize (classes by color, SV by crosses):
plot(cmdscale(dist(iris[,-5])),
     col = as.integer(iris[,5]),
     pch = c("o","+")[1:150 %in% model$index + 1])
     # we have 3 classes here
     # "+" = data points that are support vectors
     # "o" = all other instances
     # the "+" form a circle around each class -> so this tells us we are using a non-linear kernel

# get probabilities
model = svm(iris[,-5], iris[,5], probability = TRUE)
pred = predict(model, iris[,-5], decision.values = TRUE, probability = TRUE)

attr(pred, "decision.values")[1:4,]  # pred based on dec values or % will achieve the same result

attr(pred, "probabilities")[1:4,]  # shows the pred % of each class for each instance
                                   # setosa class has highest % for the 1st instance      

#### tune parameters for radial kernel using CV ####
set.seed(392)
tune.out= tune(svm, iris[,-5], iris[,5],
               ranges = list(gamma = 2^(-1:1), cost = 2^(2:4)),  # we can tune gamma and cost to whatever values we want
               tunecontrol = tune.control(sampling = "cross"),cross=10)  # tune by CV, 10-fold

summary(tune.out)  # choose the pair of gamma & cost with the smallest error rate
                   # cost starts from 4 cuz we specified it earlier "cost = 2^(2:4)"

plot(tune.out)  # dark color = low error rate
                # when gamma & cost = very small, we have the lowest error rate

# use the best model to predict the training instances
tune.out$best.model  # this allow us to extract the best model

pred=predict(tune.out$best.model,iris[,-5])

table(pred, iris[,5])  # improved from previous confusion matrix
                       # now only has 1 + 2 = 3 misclassfication, instead of 4

#### se svm in caret ####
library(caret)

#load german credit data from caret package
data(GermanCredit)
# classify two status: good or bad

## Show the first 10 columns
str(GermanCredit[, 1:10])

## Delete two variables where all values are the same for both classes
GermanCredit[,c("Purpose.Vacation","Personal.Female.Single")] <- list(NULL)

#Get training and test sets
set.seed(12)
trainIndex = createDataPartition(GermanCredit$Class, p = 0.7, list = FALSE, times = 1)
train=GermanCredit[trainIndex,] # training set
test=GermanCredit[-trainIndex,-10] # test set

#train the model
fitControl=trainControl(
  method = "repeatedcv",
  number = 5,
  repeats = 3)

set.seed(2333)
svm.Radial=train(Class ~., data = train, method = "svmRadial",  # svm with radial kernel
                 trControl=fitControl,
                 preProcess = c("center", "scale"),
                 tuneLength = 5)

svm.Radial  # choose the C with the highest accuracy, C = 4

plot(svm.Radial)

# tune both parameters (C and gamma)
grid_radial=expand.grid(sigma = c(0.01, 0.1, 1,10),
                        C = c(0.01, 0.1, 1, 10))

fitControl=trainControl(
  method = "repeatedcv",
  number = 5,
  repeats = 3)

set.seed(2333)
svm.Radialg=train(Class ~., data = train, method = "svmRadial",
                  trControl=fitControl,
                  preProcess = c("center", "scale"),
                  tuneGrid = grid_radial)

svm.Radialg  # the very bottom shows the model with the optimized parameters

plot(svm.Radialg)

