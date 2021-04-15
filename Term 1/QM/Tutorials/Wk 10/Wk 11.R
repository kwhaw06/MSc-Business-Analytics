#install.packages("gamair")
library(gamair)
data(wine)

wm<-gam(price~s(h.rain)+s(s.temp)+s(h.temp)+s(year),
        data=wine,family=Gamma(link=identity),gamma=1.4)
summary(wm)

plot(wm,pages=1,residuals=TRUE,pch=1,scale=0)
acf(residuals(wm))
gam.check(wm)
predict(wm,wine,se=TRUE)
