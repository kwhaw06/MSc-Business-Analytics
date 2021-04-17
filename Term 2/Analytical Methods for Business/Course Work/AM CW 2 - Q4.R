##################
### Question 4 ###
##################

## libraries
library(mvtnorm)

## generate dataset
# initial setup
n = c(250,300,150,150,50,50) # volume of each submodels

mu1 = c(6.9,39,6.9,39) # mean vector for submodel 1
sigma1 = diag(0.1, 4, 4) # covariance matrix for submodel 1

mu2 = c(69,69,69,69) # mean vector for submodel 2
sigma2 = matrix(rep(0.25, 16), 4, 4) # covariance matrix for submodel 2
for (i in 1:4) {
  sigma2[i,i] = 0.5
}

lamda3 = c(9,9,9,9) # lamda for submodel 3

mu4 = c(39,6.9,39,6.9) # mean vector for submodel 4
sigma4 = diag(0.1, 4, 4) # covariance matrix for submodel 4

limit5 = c(-15,99) # limits for submodel 5

mu6 = c(33,33,33,33) # mean vector for submodel 6
sigma6 = diag(0.1,4,4) # covariance matrix for submodel 6


# submodel 1
set.seed(666)
data1 = rmvnorm(n[1], mu1, sigma1)

# submodel 2
set.seed(666)
data2 = rmvnorm(n[2], mu2, sigma2)

# submodel 3
set.seed(666)
data3 = cbind(
  rexp(n[3], lamda3[1]),
  rexp(n[3], lamda3[2]),
  rexp(n[3], lamda3[3]),
  rexp(n[3], lamda3[4])
)

# submodel 4
set.seed(666)
data4 = rmvt(n[4], sigma4, df=2)

# submodel 5
set.seed(666)
data5 = cbind(
  runif(n[5], limit5[1], limit5[2]),
  runif(n[5], limit5[1], limit5[2]),
  runif(n[5], limit5[1], limit5[2]),
  runif(n[5], limit5[1], limit5[2])
)

# submodel 6
data6 = rmvt(n[6], sigma6, df=2)

# combine and shuffle the data
data = rbind(data1, data2, data3, data4, data5, data6)
set.seed(666)
rows = sample(nrow(data))
data = data[rows,]

# dimension 5
set.seed(666)
data.dim5 = rnorm(sum(n))
data = cbind(data, data.dim5)

# dimension 6
set.seed(666)
data.dim6 = rt(sum(n), 2, ncp = 0)
data = cbind(data, data.dim6)

# rename the columns
colnames(data) = c("dim1", "dim2", "dim3", "dim4", "dim5", "dim6")

summary(data)

#cluster by k-means
library(factoextra)

#elbow method,k=3
fviz_nbclust(data, FUN = hcut, method = "wss")

set.seed(666)
km2 <- kmeans(data, 
              centers = 2, 
              nstart = 25) 
km3<-kmeans(data, 
            centers = 3, 
            nstart = 25) 

#more clearer
p2 <- fviz_cluster(km2, geom = "point", data = data) + ggtitle("k = 2")
p3 <- fviz_cluster(km3, geom = "point", data = data) + ggtitle("k = 3")

#visualization
library(gridExtra)
grid.arrange(p2, p3, nrow = 2)

#use clusterboot() 
library(fpc)
set.seed(666)
km2.boot <- clusterboot(data, B=100,
                        bootmethod='boot',
                        clustermethod=kmeansCBI,
                        krange=2, seed=20)
km3.boot <- clusterboot(data, B=100,
                        bootmethod='boot',
                        clustermethod=kmeansCBI,
                        krange=3, seed=20)

#cluster that are dissolved often are unstable
km2.boot
km3.boot

