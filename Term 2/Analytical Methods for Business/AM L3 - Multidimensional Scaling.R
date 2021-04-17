#### Classical MDS ####

#install.packages("readstata13")
library(readstata13)
cerealnut <- read.dta13("cerealnut.dta")
cerealnut

summary(cerealnut[,-1])   # inspect data

apply(cerealnut[,-1], 2, var)   # variance

cereal.dist <- dist(cerealnut[,-1])   # calculate the Euclidean distances

cereal.mds <- cmdscale(cereal.dist)   # MDS
cereal.mds

# display the brand names in the plot
rownames(cereal.mds) <- cerealnut$brand
plot(cereal.mds, type = "n", xlab = "Dimension 1", ylab = "Dimension 2",
     xlim = c(-200, 250), ylim = c(-200, 250))
text(cereal.mds, rownames(cereal.mds), cex=1)

# scaling
cerealnut.sc <-scale(cerealnut[,-1])

# repeat the same steps for the scaled variables
cereal.sc.dist <- dist(cerealnut.sc)
cereal.sc.mds <- cmdscale(cereal.sc.dist)
rownames(cereal.sc.mds) <- cerealnut$brand
plot(cereal.sc.mds, type = "n", xlab = "Dimension 1", ylab = "Dimension 2")
text(cereal.sc.mds, rownames(cereal.sc.mds), cex=1)

# PCA & MDS
pr.out = prcomp(cerealnut[,-1], scale=TRUE)

pr.out$rotation = -pr.out$rotation
pr.out$x = -pr.out$x

plot(pr.out$x[,1:2], type='n', xlab='PC1', ylab='PC2')
text(pr.out$x[,1:2], rownames(cereal.sc.mds), cex=1)

#### Ordinal MDS ####
brand.ratings <- read.csv("http://goo.gl/IQl8nc")
head(brand.ratings)
tail(brand.ratings)

# aggregate the data by mean
brand.mean <- aggregate(. ~ brand, data=brand.ratings, mean)
brand.mean

rownames(brand.mean) <- brand.mean[, 1] # use brand for the row names
brand.mean <- brand.mean[, -1] # remove brand name column
brand.mean

# ranking the data by each column
brand.rank <- data.frame(lapply(brand.mean, function(x) ordered(rank(x))))
brand.rank

# find the distance between the ranks
library(cluster)
brand.dist.r <- daisy(brand.rank, metric="gower")

# plot
library(MASS)
brand.mds.r <- isoMDS(brand.dist.r)

plot(brand.mds.r$points, type="n")
text(brand.mds.r$points, rownames(brand.mean), cex=2)