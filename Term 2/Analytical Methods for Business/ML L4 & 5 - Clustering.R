#### K-means Clustering ####
# Generate data
set.seed(2)
x=matrix(rnorm (50*2) , ncol =2)
x[1:25 ,1]=x[1:25 ,1]+3
x[1:25 ,2]=x[1:25 ,2] -4

# K-means Clustering
km.out = kmeans(x, 2)

km.out$cluster

# plot
plot(x, col =(km.out$cluster) , main="K-Means Clustering
Results with K=2", xlab ="", ylab="", pch =20, cex =2)

# means
km.out$centers

str(km.out)

km.out = kmeans(x, 2, nstart=25)

# K = 3
set.seed(3)
km.out =kmeans(x,3, nstart =1)
km.out

#### Hierarchical Clustering ####
hc.complete = hclust(dist(x), method = "complete")
hc.average = hclust(dist(x), method = "average")
hc.single = hclust(dist(x), method = "single")

# plot dendograms
par(mfrow =c(1,3))
plot(hc.complete, main = "Complete Linkage", xlab = "", sub = "", cex = .9)
plot(hc.average, main = "Average Linkage", xlab ="", sub = "", cex = .9)
plot(hc.single, main = "Single Linkage", xlab = "", sub = "", cex =.9)

cutree(hc.complete, 2)
cutree(hc.average, 2)
cutree(hc.single, 2)

# standardization
xsc=scale(x)
plot(hclust(dist(xsc), method = "complete"), main = "Hierarchical
Clustering with Scaled Features")

#### correlation based distance instead of Euclidean distance for HC ####
# example with 3 variables
x = matrix(rnorm(30*3), ncol = 3)
dd = as.dist(1 - cor(t(x)))
par(mfrow =c(1,1))
plot(hclust(dd, method = "complete"), main = "Complete Linkage with
     Correlation - Based Distance", xlab="", sub="")

# example with 2 variables
x = matrix(rnorm(30*2), ncol = 2)
cor(t(x))

#### 4.4 Example 2: Clustering ####
data("USArrests")
df <- scale(USArrests)
head(df, n = 3)

# kNN with k = 2
set.seed(100)
k2 <- kmeans(df, 2, nstart = 25)
print(k2)

# plot the clustering 
library(factoextra)
fviz_cluster(k2, data = df)

pr.out = prcomp(USArrests, scale=TRUE)
biplot(pr.out, scale=0)

# number of k clusters
k3 <- kmeans(df, 3)
k4 <- kmeans(df, 4)
k5 <- kmeans(df, 5)

p1 <- fviz_cluster(k2, geom = "point", data = df) + ggtitle("k = 2")
p2 <- fviz_cluster(k3, geom = "point", data = df) + ggtitle("k = 3")
p3 <- fviz_cluster(k4, geom = "point", data = df) + ggtitle("k = 4")
p4 <- fviz_cluster(k5, geom = "point", data = df) + ggtitle("k = 5")

library(gridExtra)
grid.arrange(p1, p2, p3, p4, nrow = 2)



#### 4.5.4 Example 3: Clustering Methods for Mixed-type Data ####
library(kamila)
library(clustMD)

# load data
data(Byar)

# log transform 
hist(Byar$Serum.prostatic.acid.phosphatase)
Byar$Serum.prostatic.acid.phosphatase <- log(Byar$Serum.prostatic.acid.phosphatase)
hist(Byar$Serum.prostatic.acid.phosphatase)

# subset cont. variables
conInd <- c(5, 6, 8:11)
conVars <- Byar[, conInd]
summary(conVars)

# subset cat. variables
catVars <- Byar[, -c(1:2, conInd, 14, 15)]
catVars[] <- lapply(catVars, factor)
summary(catVars)

# standardized cont. variables
rangeStandardize <- function(x) {
  (x - min(x)) / diff(range(x))
}

conVars <- as.data.frame(lapply(conVars, rangeStandardize))

# Semi-parametric clustering procedure
set.seed(5)
kmRes <- kamila(conVars, catVars, numClust = 3, numInit = 10, maxIter = 50)

kmRes$finalMemb

# regroup the response variable into 3 levels
ternarySurvival <- factor(Byar$SurvStat)
survNames <- c("Alive", "DeadProst", "DeadOther")
levels(ternarySurvival) <- survNames[c(1, 2, rep(3, 8))]
ternarySurvival

# 2 way table
kamila3clusters <- factor(kmRes$finalMemb, 1:3, paste("Cluster", 1:3))
(kamilaSurvTab <- table(kamila3clusters, ternarySurvival))

chisq.test(kamilaSurvTab)   # check dependence

# prediction strength
set.seed(6)
numberOfClusters <- 2:10
kmResPs <- kamila(conVars, catVars, numClust = numberOfClusters,
                  numInit = 10, maxIter = 50, calcNumClust = "ps")

# get perdiction strength values
kmResPs$nClust$psValues

# plot
library(ggplot2)
psPlot <- with(kmResPs$nClust, qplot(numberOfClusters, psValues) +
                 geom_errorbar(aes(x = numberOfClusters,
                                   ymin = psValues - stdErrPredStr,
                                   ymax = psValues + stdErrPredStr), width = 0.25))
psPlot <- psPlot + geom_hline(yintercept = 0.8, lty = 2)
psPlot + scale_x_continuous(breaks = numberOfClusters) + ylim(0, 1.1)
