#### Question 1.a ####

# %% Setup
library(rospca)

set.seed(111)
data1 <- dataGen(m=1, n=100, p=9, SD=c(20,5,10), 
                 a=c(0.7,0.9,0.8), bLength=3)

View(data1)
class(data1)

#### Question 1.b ####
# %% Extract the data and transform it from list to dataframe
df1 <- as.data.frame(data1$data)

# %% Estimated correlation
# the first 3 variables with inner corr = 0.7
cor1_3 = cor(df1[,1:3])
mean(cor1_3)

# the second 3 variables with inner corr = 0.9
cor4_6 = cor(df1[,4:6])
mean(cor4_6)

# the last 3 variables with inner corr = 0.8
cor7_9 = cor(df1[,7:9])
mean(cor7_9)

# %% Estimated standard deviation
# the first 3 variables with SD = 20
sd1_3 <- apply(df1[,1:3],2,sd)
mean(sd1_3)

# the second 3 variables with SD = 5
sd4_6 <- apply(df1[,4:6],2,sd)
mean(sd4_6)

# the last 3 variables with SD = 10
sd7_9 <- apply(df1[,7:9],2,sd)
mean(sd7_9)

#### Question 1.c ####
set.seed(111)
data2 <- dataGen(m=1, n=100, p=9, SD=c(20,5,10), 
                 a=c(0,0,0), bLength=3)

df2 <- as.data.frame(data2$data)

#### Question 1.d ####

# %% step 1: inspect mean and variance
apply(df1, 2, mean)
apply(df1, 2, var)
apply(df2, 2, mean)
apply(df2, 2, var)

# %% step 2: fit PCA & biplot
pr1.out <- prcomp(df1, scale = TRUE)
pr2.out <- prcomp(df2, scale = TRUE)

# the scaled mean and standard deviation
pr1.out$center
pr1.out$scale

pr1.out$rotation

# create two biplots
biplot(pr1.out, scale = 0, cex = 0.5, 
       cex.axis = 0.5, cex.lab = 0.5)
biplot(pr2.out, scale = 0, cex = 0.5,
       cex.axis = 0.5, cex.lab = 0.5)

# %% step 3: PVE and cumulative PVE
# the variance explained by each PC
pr1.out$sdev
pr1.var = pr1.out$sdev ^2
pr1.var

# the proportion of variance explained by each PC
pve1 = pr1.var/sum(pr1.var)
pve1

# plot PVE1 and cumulative PVE1
plot(pve1, xlab='Principal Component', 
     ylab='Proportion of Variance Explained',
     ylim=c(0,1), type='b')

plot(cumsum(pve1), xlab='Principal Component',
     ylab='Cumulative Proportion of Variance Explained',
     ylim=c(0,1), type='b')

# repeat the same steps for df2
pr2.out$sdev
pr2.var = pr2.out$sdev ^2
pve2 = pr2.var/sum(pr2.var)

plot(pve2, xlab='Principal Component', 
     ylab='Proportion of Variance Explained',
     ylim=c(0,1), type='b')

plot(cumsum(pve2), xlab='Principal Component',
     ylab='Cumulative Proportion of Variance Explained',
     ylim=c(0,1), type='b')

#### Question 2 ####
# import data
data <- read.table("UNSY97.txt", header = TRUE)
View(data)

# add country column
data$Country <- c("Albania", "Argentina", "Australia", "Austria", "Benin", 
                  "Bolivia", "Brazil", "Cambodia", "China", "Colombia", 
                  "Croatia", "El Salvador", "France", "Greece", "Guatemala",
                  "Iran", "Italy", "Malawi", "Netherlands", "Pakistan",
                  "Papua New Guinea", "Peru", "Romania", "USA", "Zimbabwe")
summary(data)

# check the variance to see if these variables are comparable
apply(data[,-6], 2, var)

# scale the variances of data
df.sc = scale(data[,-6])

# compute Euclidean distance
df.sc.dist <- dist(df.sc)

### 1 dimension ###
df.sc.mds.1 <- cmdscale(df.sc.dist, k=1)
index <- seq(1, nrow(df.sc.mds.1), 1)

# plot
stripchart(df.sc.mds.1, xlim=c(-3,5), xlab='1 Dimension')
text(df.sc.mds.1, 1.1, labels=index,cex=0.7)

### 2 dimension ###
df.sc.mds.2 <- cmdscale(df.sc.dist, k=2)

# plot 
rownames(df.sc.mds.2) <-data$Country
plot(df.sc.mds.2, type='n', xlab='Dimension 1',
     ylab='Dimension 2', cex.axis = 0.7, cex.lab = 0.7)
text(df.sc.mds.2, rownames(df.sc.mds.2), cex=0.7)
