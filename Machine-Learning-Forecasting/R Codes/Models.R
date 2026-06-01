rm(list = ls())
setwd("C:\\Users\\feder\\Desktop\\Project\\Bertoia_Co (Machine Learning)")
library(tidyverse)
library(ggthemes)
library(stats)
library(readr)
library(pracma)
library(writexl)
library(fbi)
library(R.matlab)
library(dplyr)
library(rlang)
library(forecast)
library(glmnet)
library(mboost)
library(gbm)
library(xtable)



file_path <- "C:/Users/feder/Desktop/Project/Bertoia_Co (Machine Learning)/act_data.csv"
act_data <- read.csv(file_path)

# data for graphs
data2 <- act_data[1:52,]
data2_gdp = data2[,1]
data2_gdp <- as.data.frame(data2_gdp)
data2_gdp <- data2_gdp %>% 
  rename(GDPC1 = data2_gdp)

data2_4 <- act_data[1:55,]
data4_gdp = data2_4[,1]
data4_gdp <- as.data.frame(data4_gdp)
data4_gdp <- data4_gdp %>% 
  rename(GDPC1 = data4_gdp)

################### MODELS #######################

############# AR(1) ############

GDP <- act_data$GDPC1
GDP <- as.data.frame(GDP)
train_GDP <- window(GDP$GDP, end = 52)
test_GDP <- window(GDP$GDP, start = 53)
fit <- arima(train_GDP, order = c(1,0,0))
forecast(fit, h = 4)
forecast(fit, h = 1)
w_size <- length(train_GDP)

#1-STEP
h <- 1
n <- length(test_GDP)-h+1
fcmat1 <- matrix(0, nrow = n, ncol = h)

for (i in 1:n){
  x <- GDP[i:(w_size-1+i),1]
  refit <- Arima(x, order = c(1,0,0))
  fcmat1[i,]<- forecast(refit, h = h)$mean
}

mean((fcmat1 - GDP[53:78,1])^2) #0.4809598

#4-STEP
h <- 4
n <- length(test_GDP)-h+1
fcmat4 <- matrix(0, nrow = n, ncol = h)

for (i in 1:n){
  x <- GDP[i:(w_size-1+i),1]
  refit <- Arima(x, order = c(1,0,0))
  fcmat4[i,]<- forecast(refit, h = h)$mean
}

mean((fcmat4[,4] - GDP[56:78,1])^2) #0.3634437 




#### import estimates of chi & xi from MatLab ####
chi_rol <- readMat("C:\\Users\\feder\\Desktop\\Project\\Bertoia_Co (Machine Learning)\\chi_rol.mat")
chi_rol <- as.data.frame((chi_rol))
xi_rol <- readMat("C:\\Users\\feder\\Desktop\\Project\\Bertoia_Co (Machine Learning)\\xi_rol.mat")
xi_rol <- as.data.frame((xi_rol))

#r=5 q=3 

fcast_chi1 <- readMat("C:\\Users\\feder\\Desktop\\Project\\Bertoia_Co (Machine Learning)\\fcast_chi1.mat")
fcast_chi1 <- as.data.frame(fcast_chi1)
fcast_chi4 <- readMat("C:\\Users\\feder\\Desktop\\Project\\Bertoia_Co (Machine Learning)\\fcast_chi4.mat")
fcast_chi4 <- as.data.frame(fcast_chi4)


colnames(xi_rol) <- colnames(data2)
colnames(chi_rol) <- colnames(data2)
colnames(fcast_chi1) <- colnames(data2)
colnames(fcast_chi4) <- colnames(data2)



############# FHLR1 ############ 
#(Only forecast through common part, i.e. chi)

#1-STEP 
FHLR1 <- fcast_chi1 %>% 
  select(GDPC1) 

train_GDP <- as.data.frame(train_GDP)
train_GDP <- train_GDP %>% 
  rename(GDPC1 = train_GDP)

# Graph
FHLR1 <- rbind(train_GDP, FHLR1)

plot.ts(FHLR1, col=2, xlim = c(0, 78), ylim = c(-5,5), ylab="GDPC1", xlab="Time (Quarters)")
points(act_data$GDPC1, type = "l", col = 1)
abline(v="52", col=8, lty=3, h=0)

#MSE
mean((FHLR1[53:78,] - act_data[53:78,]$GDPC1)^2) #0.3868886



#4-STEP 
FHLR1.4step <- fcast_chi4 %>% 
  select(GDPC1)
FHLR1.4step <- FHLR1.4step[4:26,]
FHLR1.4step <- as.data.frame(FHLR1.4step)
FHLR1.4step <- FHLR1.4step %>% 
  rename(GDPC1 = FHLR1.4step)


#Graph
FHLR1.4step <- rbind(data4_gdp, FHLR1.4step)

plot.ts(FHLR1.4step, col=2, xlim = c(0, 78), ylim = c(-5,5), ylab="GDPC1", xlab="Time (Quarters)")
points(act_data$GDPC1, type = "l", col = 1)
abline(v="52", col=8, lty=2, h=0)

#MSE
mean((FHLR1.4step[56:78,] - act_data[56:78,]$GDPC1)^2) #0.2801673



################ FHLR2 ############ 
#(Forecast also idiosyncratic part, i.e. xi, through ar(1))

#1-STEP
xi_gdp <- xi_rol$GDPC1
xi_gdp <- as.data.frame(xi_gdp)
xi_gdp_train <- window(xi_gdp$xi_gdp, end = 52)
fit <- arima(xi_gdp_train, order = c(1,0,0))
w_size <- length(xi_gdp_train)

h <- 1
n <- 26-h+1
fcmat1.xi <- matrix(0, nrow = n, ncol = h)
xi_gdp.iter <- matrix(0, nrow = n, ncol = h)

for (i in 1:n){
  x <- xi_gdp[1+(w_size * (i-1)):(w_size * i),]
  refit <- Arima(x, order = c(1,0,0))
  xi_gdp.iter[i,] <- xi_gdp[(w_size  * (i+h)), 1] 
  fcmat1.xi[i,]<- forecast(refit, h = h)$mean[h]
}

mean((fcmat1.xi - xi_gdp.iter)^2) #0.1599282 MSE of the xi's forecasts

#x=chi+xi
gdp_fhlr2 = FHLR1[53:78,] + fcmat1.xi
gdp_fhlr2 <- as.data.frame(gdp_fhlr2)
gdp_fhlr2 <- gdp_fhlr2 %>% 
  rename( GDPC1 = V1)

# Graph
FHLR2 <- rbind(train_GDP, gdp_fhlr2) 

plot.ts(FHLR2, col=2, xlim = c(0, 78), ylim = c(-5,5), ylab="GDPC1", xlab="Time (Quarters)")
points(act_data$GDPC1, type = "l", col = 1)
abline(v="52", col=8, lty=3,h=0)

# MSE
mean((FHLR2[53:78,] - act_data[53:78,]$GDPC1)^2) #0.3756181



#4-STEP
h <- 4
n <- 26-h+1
fcmat4.xi <- matrix(0, nrow = n, ncol = h)
xi_gdp4.iter <- matrix(0, nrow = n, ncol = 1)


for (i in 1:n){
  x <- xi_gdp[1+(w_size * (i-1)):(w_size * i),]
  refit <- Arima(x, order = c(1,0,0))
  xi_gdp4.iter[i,] <- xi_gdp[(w_size  * (i+h)), 1]
  fcmat4.xi[i,]<- forecast(refit, h = h)$mean
}

# check whether we assigned the correct values into the test-set
#xi_gdp[260,]-xi_gdp4.iter[1,]
#xi_gdp[260+52,]-xi_gdp4.iter[2,] ##etc

mean((fcmat4.xi[,4] - xi_gdp4.iter)^2) #0.1195454 MSE for xi's

#x=chi+xi
gdp_fhlr2.4step = FHLR1.4step[56:78,] + fcmat4.xi[,4]
gdp_fhlr2.4step <- as.data.frame(gdp_fhlr2.4step)
gdp_fhlr2.4step <- gdp_fhlr2.4step %>% 
  rename( GDPC1 = gdp_fhlr2.4step)

#Graph
FHLR2.4step <- rbind(data4_gdp, gdp_fhlr2.4step) 
plot.ts(FHLR2.4step, col=2, xlim = c(0, 78), ylim = c(-5,5), ylab="GDPC1", xlab="Time (Quarters)")
points(act_data$GDPC1, type = "l", col = 1)
abline(v="52", col=8, lty=3,h=0)

#MSE
mean((gdp_fhlr2.4step[,1] - act_data[56:78,1])^2) #0.2809238





######################## ML1 ##########################
# Forecast on xi_train with Lasso 

#1-STEP
xi_rol.mat <- as.matrix(xi_rol)


# 1-step
w_size <- 52
h <- 1
n <- 26-h+1
fcmat1.lasso <- matrix(0, nrow = n, ncol = h)
xi_testmat.lasso <- matrix(0, nrow = n, ncol = h) 

for (i in 1:n){
  x <- xi_rol.mat[1+(w_size * (i-1)):(w_size * i), -1]
  y <- xi_rol.mat[1+(w_size * (i-1)):(w_size * i), 1]
  testx <- xi_rol.mat[(w_size  * (i+h)), -1]
  xi_testmat.lasso[i,] <- xi_rol.mat[(w_size  * (i+1)), 1] 
  set.seed(1)
  cv.out <- cv.glmnet(x, y, alpha = 1)
  bestlam <- cv.out$lambda.min
  lasso.refit <- glmnet(x, y, alpha = 1, lambda = bestlam)
  fcmat1.lasso[i,] <- predict(lasso.refit, s = bestlam, newx = testx)
}

mean((fcmat1.lasso - xi_testmat.lasso[,1])^2) #MSE for predicting xi's (0.002846866)

## x = chi+ xi
FHLR1 <- fcast_chi1 %>% 
  select(GDPC1) 
ML1_1 <- FHLR1 + fcmat1.lasso

mean((ML1_1[,1] - act_data[53:78,1])^2) #0.1188436

## ???
#lasso.coef <- predict(lasso.train, type = "coefficients", s = bestlam)[,]
#lasso.coef[lasso.coef != 0]

#Graph
ML1_1g = rbind(data2_gdp, ML1_1)

plot.ts(ML1_1g, col=2, xlim = c(0, 78), ylim = c(-5,5), ylab="GDPC1", xlab="Time (Quarters)")
points(act_data$GDPC1, type = "l", col = 1)
abline(v="52", col=8, lty=3,h=0)



# 4-step
w_size <- 52
h <- 4
n <- 26-h+1
fcmat4.lasso <- matrix(0, nrow = n, ncol = h)
xi_testmat.lasso <- matrix(0, nrow = n, ncol = 1) 

for (i in 1:n){
  x <- xi_rol.mat[1+(w_size * (i-1)):(w_size * i), -1]
  y <- xi_rol.mat[1+(w_size * (i-1)):(w_size * i), 1]
  testx <- xi_rol.mat[(w_size  * (i+h)), -1]
  xi_testmat.lasso[i,] <- xi_rol.mat[(w_size  * (i+h)), 1] 
  set.seed(1)
  cv.out <- cv.glmnet(x, y, alpha = 1)
  bestlam <- cv.out$lambda.min
  lasso.refit <- glmnet(x, y, alpha = 1, lambda = bestlam)
  fcmat4.lasso[i,] <- predict(lasso.refit, s = bestlam, newx = testx)
}

mean((fcmat4.lasso[,4] - xi_testmat.lasso[,1])^2) #MSE for predicting xi's (0.004159054)


## x = chi+ xi
FHLR1_4 <- fcast_chi4 %>% 
  select(GDPC1) 
ML1_4 = FHLR1_4[4:26,] + fcmat4.lasso[,4]

#MSE
mean((ML1_4 - act_data[56:78,1])^2) #0.1167942

#Graph

ML1_4 <- as.data.frame(ML1_4)
ML1_4 <- ML1_4 %>% 
  rename(GDPC1 = ML1_4)

ML1_4g <- rbind(data4_gdp, ML1_4)


plot.ts(ML1_4g, col=2, xlim = c(0, 78), ylim = c(-5,5), ylab="GDPC1", xlab="Time (Quarters)")
points(act_data$GDPC1, type = "l", col = 1)
abline(v="52", col=8, lty=3,h=0)



############# ML 2 #############
#forecast on xi with Boosting
library(gbm)

#1 STEP AHEAD
w_size <- 52
h <- 1
n <- 26-h+1
fcmat1.boost <- matrix(0, nrow = n, ncol = h)
xi_testmat.boost <- matrix(0, nrow = n, ncol = h) 


for (i in 1:n){
  xi_testmat.boost[i,] <- xi_rol.mat[(w_size)*(i+1),1]
}


for (i in 1:n){
  ML2 <- gbm(GDPC1 ~ ., data = xi_rol[1+(w_size * (i-1)):(w_size * i),],
             distribution = "gaussian", shrinkage = 0.0001, cv.folds = 10,
             verbose=F, bag.fraction=0.7, n.trees = 5000, interaction.depth = 4)
  testx <- xi_rol[(w_size)*(i+1),]
  fcmat1.boost[i,] <- predict(ML2, newdata = testx, n.trees = 5000) #prediction with boosting
}

mean((fcmat1.boost[,1] - xi_testmat.boost[,1])^2) #MSE for predicting xi's (0.07939002)

#x = chi + xi
ML2_1 <- FHLR1 + fcmat1.boost[,1]

#MSE
mean((ML2_1[,1] - act_data[53:78,1])^2) #0.282289

#Graph
ML2_g = rbind(data2_gdp, ML2_1)

plot.ts(ML2_g, col=2, xlim = c(0, 78), ylim = c(-5,5), ylab="GDPC1", xlab="Time (Quarters)")
points(act_data$GDPC1, type = "l", col = 1)
abline(v="52", col=8, lty=3,h=0)

#????
#head(summary(ML2)) #show most important variables
#plot(ML2, i = "OUTBS")
#plot(ML2, i = "OUTNFB")

#???


#4 STEPS AHEAD 
w_size <- 52
h <- 4
n <- 26-h+1
fcmat4.boost <- matrix(0, nrow = n, ncol = h)
xi_testmat.boost <- matrix(0, nrow = n, ncol = 1) 


for (i in 1:n){
  xi_testmat.boost[i,] <- xi_rol.mat[(w_size)*(i+1),1]
}


for (i in 1:n){
  ML2 <- gbm(GDPC1 ~ ., data = xi_rol[1+(w_size * (i-1)):(w_size * i),],
             distribution = "gaussian", shrinkage = 0.0001, cv.folds = 10,
             verbose=F, bag.fraction=0.7, n.trees = 5000, interaction.depth = 4)
  testx <- xi_rol[(-3+ (w_size*(h+i))):((h+i)*(w_size)),]
  fcmat4.boost[i,] <- predict(ML2, newdata = testx, n.trees = 5000) #prediction with boosting
}

mean((fcmat4.boost[,4] - xi_testmat.boost[,1])^2) #MSE for predicting xi's (0.1694464)



#x = chi + xi
ML2_4 = FHLR1_4[4:26,] + fcmat4.boost[,4]

# MSE
mean((ML2_4 - act_data[56:78,1])^2) #0.1980291

# Graph 

ML2_4 <- as.data.frame(ML2_4)
ML2_4 <- ML2_4 %>% 
  rename(GDPC1 = ML2_4)

ML2_g <- rbind(data4_gdp, ML2_4)


plot.ts(ML2_g, col=2, xlim = c(0, 78), ylim = c(-5,5), ylab="GDPC1", xlab="Time (Quarters)")
points(act_data$GDPC1, type = "l", col = 1)
abline(v="52", col=8, lty=3,h=0)



######## DGR1 ######
# Forecast on x with Lasso 

#1-STEP
act_data.mat <- as.matrix(act_data)


# 1-step
w_size <- 52
h <- 1
n <- 26-h+1
x_fcmat1.lasso <- matrix(0, nrow = n, ncol = h)
x_testmat.lasso <- matrix(0, nrow = n, ncol = h) 

for (i in 1:n){
  x <- act_data.mat[i: (w_size+i-1), -1]
  y <- act_data.mat[i: (w_size+i-1), 1]
  testx <- act_data.mat[w_size+i, -1]
  x_testmat.lasso[i,] <- act_data.mat[(w_size + i), 1] 
  set.seed(1)
  cv.out <- cv.glmnet(x, y, alpha = 1)
  bestlam <- cv.out$lambda.min
  lasso.refit <- glmnet(x, y, alpha = 1, lambda = bestlam)
  x_fcmat1.lasso[i,] <- predict(lasso.refit, s = bestlam, newx = testx)
}

#MSE
mean((x_fcmat1.lasso - x_testmat.lasso[,1])^2) #......

## ???
#lasso.coef <- predict(lasso.train, type = "coefficients", s = bestlam)[,]
#lasso.coef[lasso.coef != 0]

#Graph
DGR1_1 = x_fcmat4.lasso[,1]
DGR1_1 <- as.data.frame(DGR1_1)
DGR1_1 <- DGR1_1 %>% 
  rename(GDPC1 = DGR1_1)
DGR1_1 = rbind(data2_gdp, x_fcmat1.lasso)

plot.ts(DGR1_1, col=2, xlim = c(0, 78), ylim = c(-5,5), ylab="GDPC1", xlab="Time (Quarters)")
points(act_data$GDPC1, type = "l", col = 1)
abline(v="52", col=8, lty=3,h=0)



# 4-step
w_size <- 52
h <- 4
n <- 26-h+1
x_fcmat4.lasso <- matrix(0, nrow = n, ncol = h)
x_testmat.lasso <- matrix(0, nrow = n, ncol = 1) 

for (i in 1:n){
  x <- act_data.mat[i:(w_size+i-1), -1]
  y <- act_data.mat[i:(w_size+i-1), 1]
  testx <- act_data.mat[(w_size+i), -1]
  x_testmat.lasso[i,] <- act_data.mat[(w_size+i), 1] 
  set.seed(1)
  cv.out <- cv.glmnet(x, y, alpha = 1)
  bestlam <- cv.out$lambda.min
  lasso.refit <- glmnet(x, y, alpha = 1, lambda = bestlam)
  x_fcmat4.lasso[i,] <- predict(lasso.refit, s = bestlam, newx = testx)
}

#MSE
mean((x_fcmat4.lasso[,4] - x_testmat.lasso[,1])^2) #.....


#Graph
DGR1_4 = x_fcmat4.lasso[,4]
DGR1_4 <- as.data.frame(DGR1_4)
DGR1_4 <- DGR1_4 %>% 
  rename(GDPC1 = DGR1_4)

DGR1_4g <- rbind(data4_gdp, DGR1_4)


plot.ts(DGR1_4g, col=2, xlim = c(0, 78), ylim = c(-5,5), ylab="GDPC1", xlab="Time (Quarters)")
points(act_data$GDPC1, type = "l", col = 1)
abline(v="52", col=8, lty=3,h=0)





######## DGR2 ######

##### GDP
#1STEP
w_size <- 52
h <- 1
n <- 26-h+1

fcmat1.boost <- matrix(0, nrow = n, ncol = h)

for (i in 1:n){
  testx <- act_data[w_size+i,]
  set.seed(12)
  DGR2 <- gbm(GDPC1 ~ ., data = act_data[i:w_size+i-1,] , cv.folds = 10, 
              distribution = "gaussian", shrinkage = 0.1, verbose=F, 
              bag.fraction=0.9, n.trees = 1000, interaction.depth = 6)
  fcmat1.boost[i,] <- predict(DGR2, newdata = testx , n.trees = 1000)
}

#MSE
mean((fcmat1.boost[,1] - act_data[53:78,1])^2) #0.1639374


#4STEP
w_size <- 52
h <- 4
n <- 26-h+1

fcmat4.boost <- matrix(0, nrow = n, ncol = h)

#Graph
fcmat1.boost <- as.data.frame(fcmat1.boost)
fcmat1.boost <- fcmat1.boost %>% 
  rename( GDPC1 = V1
  )

DGR2 <- rbind(data2_gdp, fcmat1.boost)

plot.ts(DGR2, col=2, xlim = c(0, 78), ylim = c(-5,5), ylab="GDPC1", xlab="Time (Quarters)")
points(act_data$GDPC1, type = "l", col = 1)
abline(v="52", col=8, lty=3, h=0)


for (i in 1:n){
  testx <- act_data[(w_size+i):(w_size+i+3),]
  set.seed(12)
  DGR2 <- gbm(GDPC1 ~ ., data = act_data[i:w_size+i-1,], cv.folds = 10, 
              distribution = "gaussian", shrinkage = 0.1, verbose=F, 
              bag.fraction=0.9, n.trees = 1000, interaction.depth = 6)
  fcmat4.boost[i,] <- predict(DGR2, newdata = testx , n.trees = 1000)
}

#MSE
mean((fcmat4.boost[,4] - act_data[56:78,1])^2) #0.1403481

#Graph
fcmat4.boost <- as.data.frame(fcmat4.boost)
fcmat4.boost <- fcmat4.boost %>% 
  rename(GDPC1 = V1)

DGR2 <- rbind(data4_gdp, fcmat4.boost)

plot.ts(DGR2, col=2, xlim = c(0, 78), ylim = c(-5,5), ylab="GDPC1", xlab="Time (Quarters)")
points(act_data$GDPC1, type = "l", col = 1)
abline(v="52", col=8, lty=3, h=0)







######## MSE's ##########
###AR1
#1-step
AR_1 <- mean((fcmat1 - act_data[53:78,]$GDPC1)^2) #0.4809598
#4-step
AR_4 <- mean((fcmat4[,4] - act_data[56:78,1])^2) #0.3634437 !!!!!!! shouldn't be lower than in 1-step I guess



###FHLR1
#1-step
FHLR1_1 <- mean((FHLR1[,1] - act_data[53:78,]$GDPC1)^2) #0.3868886
#4-step
FHLR1_4 <- mean((FHLR1.4step[56:78,] - act_data[56:78,]$GDPC1)^2) #0.2801673



###FHLR2
#1-step
FHLR2_1 <- mean((FHLR2[53:78,] - act_data[53:78,]$GDPC1)^2) #0.3756181
#4-step
FHLR2_4 <- mean((gdp_fhlr2.4step[,1] - act_data[56:78,1])^2) #0.2809238



###ML1
#1-step
ML1_1 <- mean((ML1_1[,1] - act_data[53:78,1])^2) #0.1188436

#4-step
ML1_4 <- mean((ML1_4[,1] - act_data[56:78,1])^2) #0.1167942


###ML2
#1-step
ML2_1 <- mean((ML2_1[,1] - act_data[53:78,1])^2) #0.282289
#4-step
ML2_4 <- mean((ML2_4[,1] - act_data[56:78,1])^2) #0.1980291


###DGR1
#1-step
DGR1_1 <- mean((x_fcmat1.lasso - x_testmat.lasso[,1])^2) #......
#4-step
DGR1_4 <- mean((x_fcmat4.lasso[,4] - x_testmat.lasso[,1])^2) #.....
###DGR2
#1-step
DGR2_1 <- mean((fcmat1.boost[,1] - act_data[53:78,1])^2) #0.1639374

#4-step
DGR2_4 <- mean((fcmat4.boost[,4] - act_data[56:78,1])^2) #0.1403481


###### MSE's Table ####
# ratios
FHLR1_1R <- FHLR1_1/AR_1
FHLR1_4R <- FHLR1_4/AR_4

FHLR2_1R <- FHLR2_1/AR_1
FHLR2_4R <- FHLR2_4/AR_4

ML1_1R <- ML1_1/AR_1
ML1_4R <- ML1_4/AR_4

ML2_1R <- ML2_1/AR_1
ML2_4R <- ML2_4/AR_4

# table
ratios = matrix(c(FHLR1_1R,FHLR1_4R, FHLR2_1R,FHLR2_4R, ML1_1R,ML1_4R, ML2_1R,ML2_4R, DGR1_1,DGR1_4, DGR2_1,DGR2_4), nrow = 2, byrow = FALSE)

colnames(ratios) = c('FHLR1','FHLR2', 'ML1', 'ML2','DGR1', 'DGR2')
rownames(ratios) <- c('h = 1','h = 4')

ratios=as.table(ratios)
print(xtable(ratios, type = "latex"), file = "C:...\\ratios.tex")




