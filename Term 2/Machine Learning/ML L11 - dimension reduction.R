#### Independent component analysis ####
# get source matrix
S <- cbind(sin((1:1000)/20), rep((((1:200)-100)/100), 5))

# get mixing matrix
M <- matrix(c(0.291, 0.6557, -0.5439, 0.5572), 2, 2)

# plot source signals
par(mfrow = c(1, 2))
plot(1:1000, S[,1], type = "l",xlab = "source 1",ylab="",cex.lab=1.5,cex.axis=1.5,lwd=2)
plot(1:1000, S[,2], type = "l", xlab = "source 2",ylab="",cex.lab=1.5,cex.axis=1.5,lwd=2)

# mix the source signals to get the observed signals X
X <- S %*% M
par(mfrow = c(1, 2))
plot(1:1000, X[,1], type = "l",xlab = "observation 1",ylab="",cex.lab=1.5,cex.axis=1.5,lwd=2)
plot(1:1000, X[,2], type = "l", xlab = "observation 2",ylab="",cex.lab=1.5,cex.axis=1.5,lwd=2)

# apply ICA (independent component analysis)
library(fastICA)
set.seed(20)
latent = fastICA(X, 2, fun = "logcosh", alpha = 1,
                 row.norm = FALSE, maxit = 200,
                 tol = 0.0001, verbose = TRUE)

# the estimated source signals are in S
par(mfrow = c(1, 2))
plot(1:1000, latent$S[,1], type = "l", xlab = "Esource 1",ylab="",cex.lab=1.5,cex.axis=1.5,lwd=2)
plot(1:1000, latent$S[,2], type = "l", xlab = "Esource 1",ylab="",cex.lab=1.5,cex.axis=1.5,lwd=2)

#### Kernel principal component analysis ####
flame=read.table("flame.txt")
plot(flame[flame$V3==1,1],flame[flame$V3==1,2],cex=1.5,
     col="red",pch=16,xlim=c(0.5,14.2),ylim=c(14.45,27.80),
     xlab="X1",ylab="X2")
points(flame[flame$V3==2,1],flame[flame$V3==2,2],cex=1.5,col="blue",pch=17)
##### PCA
pr.out=prcomp(flame[,1:2], scale=TRUE)
plot(pr.out$x[flame$V3==1,1:2],col="red",pch=16,cex=1.5,
     xlab="PC1",ylab="PC2",xlim=c(-2.65,1.69),ylim=c(-2.06,1.77))
points(pr.out$x[flame$V3==2,1:2],cex=1.5,col="blue",pch=17)
##### kernel PCA
library(kernlab)
par(mfrow = c(1, 4))
##### sigma=0.01
kpc=kpca(~.,data=flame[,-3],kernel="rbfdot",
         kpar=list(sigma=0.01),features=2)
plot(rotated(kpc)[flame$V3==1,1:2],col="red",pch=16,cex=1.5,
     xlab="KPC1",ylab="KPC2",xlim=c(-8.80,10.06),ylim=c(-7.0,10.70),
     main="sigma=0.01")
points(rotated(kpc)[flame$V3==2,1:2],cex=1.5,col="blue",pch=17)
##### sigma=0.1
kpc=kpca(~.,data=flame[,-3],kernel="rbfdot",
         kpar=list(sigma=0.1),features=2)
plot(rotated(kpc)[flame$V3==1,1:2],col="red",pch=16,cex=1.5,
     xlab="KPC1",ylab="KPC2",xlim=c(-8.80,10.06),ylim=c(-7.0,10.70),
     main="sigma=0.1")
points(rotated(kpc)[flame$V3==2,1:2],cex=1.5,col="blue",pch=17)
##### sigma=0.5
kpc=kpca(~.,data=flame[,-3],kernel="rbfdot",
         kpar=list(sigma=0.5),features=2)
plot(rotated(kpc)[flame$V3==1,1:2],col="red",pch=16,cex=1.5,
     xlab="KPC1",ylab="KPC2",xlim=c(-8.80,10.06),ylim=c(-7.0,10.70),
     main="sigma=0.5")
points(rotated(kpc)[flame$V3==2,1:2],cex=1.5,col="blue",pch=17)
##### sigma=1
kpc=kpca(~.,data=flame[,-3],kernel="rbfdot",
         kpar=list(sigma=1),features=2)
plot(rotated(kpc)[flame$V3==1,1:2],col="red",pch=16,cex=1.5,
     xlab="KPC1",ylab="KPC2",xlim=c(-8.80,10.06),ylim=c(-7.0,10.70),
     main="sigma=1")
points(rotated(kpc)[flame$V3==2,1:2],cex=1.5,col="blue",pch=17)

#### Isometric feature mapping ###############
library(RDRToolbox)
library(rgl)
library(KODAMA)
##### get the swiss roll data
x=swissroll()
labels=c(rep(1,250),rep(2,250),rep(3,250),rep(4,250))
cols=c("black","red","blue","green")
open3d()
plot3d(x, col=cols[as.numeric(as.factor(labels))],box=FALSE,size=3)
rgl.postscript("swissroll.pdf", fmt="pdf")
##### isomap
swissIsomap = Isomap(data=x, dims=2, k=10)
plotDR(data=swissIsomap$dim2, labels=(labels),axesLabels=c("", ""), 
       legend=TRUE) 
title(main="k=10")
##### get residual plot
swissResidual = Isomap(data=x, dims=1:3, k=10, plotResiduals=TRUE)



