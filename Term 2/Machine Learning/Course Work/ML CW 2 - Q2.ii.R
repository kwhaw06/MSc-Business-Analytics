####################
### Question 2.ii ##
####################

#dataset
X=iris[51:150,-5]
y=iris[51:150,5]

#output
u=myFDA(X,y)

#load library
library(MASS)

#lda function
LDA=lda(Species~.,data=iris[51:150,])

#check LDA
str(LDA)

#coefficients
v=LDA$scaling

#cosine similarity
cs=(t(u)%*%v)/(sqrt(t(u)%*%u)*sqrt(t(v)%*%v))
cs
