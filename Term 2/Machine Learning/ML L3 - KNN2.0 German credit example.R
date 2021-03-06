library(caret)

# load german credit data from caret package
data(GermanCredit)
# classify two status: good or bad customer

## Show the first 10 columns
str(GermanCredit[, 1:10])

## Delete two variables where all values are the same for both classes
GermanCredit[,c("Purpose.Vacation","Personal.Female.Single")] <- list(NULL)

# create training and test sets
set.seed(12)

trainIndex = createDataPartition(GermanCredit$Class, p = 0.7, list = FALSE, times = 1)

train.feature=GermanCredit[trainIndex,-10] # training features
                                           # -10 cuz need take out the classes
train.label=GermanCredit$Class[trainIndex] # training labels

test.feature=GermanCredit[-trainIndex,-10] # test features
test.label=GermanCredit$Class[-trainIndex] # test labels

#### set up train control
fitControl <- trainControl(## 10-fold CV
  method = "repeatedcv",
  number = 10,
  ## repeated five times
  repeats = 5)

#### training process
set.seed(5)

knnFit=train(train.feature,train.label, method = "knn",
             trControl = fitControl,
             metric = "Accuracy",
             preProcess = c("center","scale"),
             tuneLength=10)   # 10 K values but not 1 to 10

knnFit
plot(knnFit)

#### test process
pred=predict(knnFit,test.feature)
acc=mean(pred==test.label)
acc



## Fatty Acid Composition Data

A set of data where seven fatty acid compositions were used to classify commercial oils as either pumpkin (labeled A), sunflower (B), peanut (C), olive (D), soybean (E), rapeseed (F) and corn (G). Our aim is to classify an unknown commercial oil to one of the seven categories based on its seven fatty acid compositions. 

This dataset is in the `caret` package. We can load the data by using the `data( )` command.
```{r load oil data}
library(caret)
#load oil data from caret package
data(oil)
```
Now we can check some basic properties of this dataset.
```{r oil data property}
dim(fattyAcids) # check the dimensions of features
table(oilType) # table of oil types
```
First, we divide the dataset to a training and a test set.
```{r oil data train/test}
# create training and test sets
set.seed(32)
trainIndex = createDataPartition(oilType, p = 0.7, list = FALSE, times = 1)
train.feature=fattyAcids[trainIndex,] # training features
train.label=oilType[trainIndex] # training labels
test.feature=fattyAcids[-trainIndex,] # test features
test.label=oilType[-trainIndex] # test labels
```
Then, we can train a kNN classifier based on the training set. The value of `k` is tuned by 10-fold CV.
```{r oil data knn,echo = FALSE}
#### set up train control
fitControl <- trainControl(## 10-fold CV
  method = "repeatedcv",
  number = 10,
  ## repeated five times
  repeats = 5)
#### training process
set.seed(5)
knnFit=train(train.feature,train.label, method = "knn",
             trControl = fitControl,
             metric = "Accuracy",
             preProcess = c("center","scale"),
             tuneLength=10)
knnFit
plot(knnFit)
```

Now we can classify the test data by the trained kNN classifier.
```{r oil data test}
#### test process
pred=predict(knnFit,test.feature)
acc=mean(pred==test.label)
acc
```


## Pima Indians Diabetes Data
In this dataset, we aim to predict the onset of diabetes in female Pima Indians from medical record data. This dataset can be loaded from the `mlbench` package.
```{r load diabetes data}
library(mlbench)
#load Pima Indians Diabetes data from mlbench package
data(PimaIndiansDiabetes)
dim(PimaIndiansDiabetes)
levels(PimaIndiansDiabetes$diabetes)
head(PimaIndiansDiabetes)
table(PimaIndiansDiabetes$diabetes)
```

Divide the dataset to training and test sets.
```{r diabetes data train/test}
# create training and test sets
set.seed(76)
trainIndex = createDataPartition(PimaIndiansDiabetes$diabetes, p = 0.7, list = FALSE, times = 1)
train.feature=PimaIndiansDiabetes[trainIndex,-9] # training features
train.label=PimaIndiansDiabetes$diabetes[trainIndex] # training labels
test.feature=PimaIndiansDiabetes[-trainIndex,-9] # test features
test.label=PimaIndiansDiabetes$diabetes[-trainIndex] # test labels
```

Train a kNN classifier and tune the value of `k` by 10-fold CV.
```{r diabetes data knn,echo = FALSE}
#### set up train control
fitControl <- trainControl(## 10-fold CV
  method = "repeatedcv",
  number = 10,
  ## repeated five times
  repeats = 5)
#### training process
set.seed(5)
knnFit=train(train.feature,train.label, method = "knn",
             trControl = fitControl,
             metric = "Accuracy",
             preProcess = c("center","scale"),
             tuneLength=10)
knnFit
plot(knnFit)
```

Predict the labels of the test set.
```{r diabetes data test}
#### test process
pred=predict(knnFit,test.feature)
acc=mean(pred==test.label)
acc
```
