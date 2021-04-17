# % setup ----
# install.packages("lavaan")

library(lavaan)

dat <- HolzingerSwineford1939[HolzingerSwineford1939$school=="Grant-White",]
dat <- dat[, -c(1:6)]

names(dat) <- c("visual", "cubes", "lozenge", "paragraph", "sentence", "wordm",
                "add", "counting", "straight")
dat[1:3, ]
# % Preparing Data ----
fa.cor <- cor(dat)

# % Determining the Number of Factors ----
fa.eigen <- eigen(fa.cor)
fa.eigen$values
sum(fa.eigen$values)

fa.eigen$values   # rule 1

cumsum(fa.eigen$values)/9   # rule 2

# Cattell's Scree Plot
plot(fa.eigen$values, type = "b", ylab = "Eigenvalues", xlab = "Factor")

# % Estimation of Model/Factor Analysis ----
fa.res <- factanal(x = dat, factors = 4, rotation = "none")
fa.res

# % Factor Rotation ----
fa.res <- factanal(x = dat, factors = 4, rotation = "promax")
print(fa.res, cut = 0.2)

# % Factor Score ----
fa.res <- factanal(x = dat, factors = 4, rotation = "promax", scores = "Bartlett")
head(fa.res$scores)

summary(lm(Factor2 ~ Factor1, data = as.data.frame(fa.res$scores)))
