# %% Lab: Principal Components Analysis

# %% import data ----
states = row.names(USArrests)
states

# columns 
names(USArrests)

# %% examine data set ----
# inspect mean
apply(USArrests, 2, mean)   # apply the mean by column = 2
                            # 1 = row, 2 = column

# inspect variance
apply(USArrests, 2, var)

# %% principal component ----
pr.out = prcomp(USArrests, scale = TRUE)
names(pr.out)
pr.out

# mean of original variables
pr.out$center

# variance of original variables
pr.out$scale

# loadings 
pr.out$rotation

# %% plotting ----
biplot(pr.out, scale = 0)

pr.out$rotation = -pr.out$rotation
pr.out$x = -pr.out$x
biplot(pr.out, scale =0)


# %% PVE
pr.var = pr.out$sdev^2
pr.var

pve = pr.var/sum(pr.var)
pve

# PVE & cumulative PVE plots
plot(pve, xlab = " Principal Component", ylab = "Proportion of
Variance Explained", ylim = c(0,1), type = "b")

plot(cumsum(pve), xlab = "Principal Component", ylab ="
Cumulative Proportion of Variance Explained", ylim = c(0,1),
     type = "b")

# %% Tutorial ----
pr.out = prcomp(USArrests, scale = TRUE)
pr.out$rotation = -pr.out$rotation
pr.out$x = -pr.out$x

# selecting which PC to plot on the biplot
biplot(pr.out, scale = 0)   # default is PC1 & PC2
biplot(pr.out, scale = 0, choices = c(1,3))   # PC1 & PC3
biplot(pr.out, scale = 0, choices = c(1,4))   # PC1 & PC4

# %% 1.9 Lab: Principal Component Analysis of Mixed Data ----
# Setup
install.packages("PCAmixdata")
library(PCAmixdata)

# Load data
data("gironde")
head(gironde$housing)   # we have mixed data: numeric & categorical variables

# splitting the data into quality & quantity variables
split <- splitmix(gironde$housing)
X1 <- split$X.quanti  # (quantitaty variables)
X2 <- split$X.quali   # (qualitative variables)

# running PCA for mix data
res.pcamix <- PCAmix(X.quanti = X1, X.quali = X2, 
                     rename.level = TRUE, graph = FALSE)

# obtaining the statistical values
res.pcamix$eig     # eigenvalue means the variance of the PC
                   # dim 1, ..., 5 = the PCs
                   # proportion = how much a PC explain the variation of the data

# extracting the loadings of the quantity variables only
res.pcamix$quanti     # PC1 is driven by density & owners
                      # PC2 is driven by primaryres

# extracting the loadings of the quality variables only
res.pcamix$levels   # this allows us to see levels contribution

res.pcamix$quali    # this doesn't show us contribution at level

# loading square of all variables
res.pcamix$sqload

# score of the PCs --> the Z of each observation i
res.pcamix$ind$coord

# %% plot for mixed data ----
par(mfrow=c(2,2))
plot(res.pcamix, choice = "ind", coloring.ind = X2$houses, label = FALSE,
     posleg = "bottomright", main ="(a) Observations")
plot(res.pcamix, choice = "levels", xlim = c(-1.5,2.5), main = "(b) Levels")
plot(res.pcamix, choice = "cor", main = "(c) Numerical variables")
plot(res.pcamix, choice = "sqload", coloring.var = T, leg = TRUE,
     posleg = "topright", main = "(d) All variables")


