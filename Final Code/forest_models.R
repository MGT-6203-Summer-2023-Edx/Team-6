
# Clean up the environment and seed the answer to everything
cat("\014")       # Clear the console (sends CTRL+L key command)
rm(list = ls())   # Clear all the variables and data
# Clear all plots
try(dev.off(dev.list()["RStudioGD"]),silent=TRUE)
try(dev.off(),silent=TRUE)
if(basename(getwd())=="Team-6"){setwd("Final Code/") }
source("preprocessor.R")
source("Final Code/roc_curves.R")
#library(tidyverse)
library(randomForest)
library(ROCR)
#library(caret)
library(tictoc)
data <- preprocess()
# Get our data loaded up
train <- data$train
val <- data$validate
test <- data$test

# Since randomForest performs a cross validation already, combine train and validation data sets.
train.full <- train #rbind(train, val)
train.full$satisfaction <- factor(train.full$satisfaction)

# Build a function to check model accuracy against the test data set
forest_acc <- function(model){
    
    # Predict model against the test set
    predict <- predict(model, val, type = "class")
    
    # Find accuracy of the model on the test data set
    acc <- mean(predict == val$satisfaction)
    print(paste0("Model accuracy: ", round(acc,4)))
}

# Plant a random forest with the "raw" data. Any NA values are omitted from the model
# Edited the ntree parameter down to 250 after the initial runs to help with processing time
tic()
set.seed(42)
model.random <- randomForest(x = train.full[,-22], y = train.full[,22], na.action = na.omit, 
                             keep.forest = FALSE, importance = TRUE, ntree = 250)
toc() # 106 seconds
print("*** model.random ***")
model.random # OOB Error = 4.3%
importance(model.random)
varImpPlot(model.random)
title(main = "Full Training Data Set")
# To reduce time, how many trees are needed before error converges?
plot(model.random)  # Around 250 looks good

# Attempt to optimize the random forest
# https://www.listendata.com/2014/11/random-forest-with-r.html
tic()
set.seed(42)
mtry <- tuneRF(train.full[-22],train.full$satisfaction, ntree=250,
               stepFactor=1.5,improve=0.01, trace=TRUE, plot=TRUE)
best.m <- mtry[mtry[, 2] == min(mtry[, 2]), 1]
print(mtry)
print(best.m)  # 13
toc()

# Now to build a forest using the new mtry parameter
tic()
set.seed(42)
model.random.mtry <- randomForest(x = train.full[,-22], y = train.full[,22], na.action = na.omit, ntree=250,
                             keep.forest = FALSE, importance = TRUE, mtry = 13)
toc()
print("*** model.random.mtry ***")
model.random.mtry # OOB Error= 4.0%
importance(model.random.mtry)
title(main = "Full Training Set: mtry=13")
varImpPlot(model.random.mtry)
plot(model.random.mtry)


# Choose factors with an importance greater of 60
# Online.boarding, Checkin.service, Inflight.wifi.service, Type.of.Travel,
# Baggage.handling, Seat.comfort
# 
factors <- c("Online.boarding", "Checkin.service", "Inflight.wifi.service", 
             "Type.of.Travel", "Baggage.handling", "Seat.comfort")
tic()
set.seed(42)
model.random.final<- randomForest(x = train.full[,factors], y = train.full[,22], ntree = 250)
toc() # 18.18 seconds
model.random.final  # OOB = 8.94%
plot(model.random.final)

pred <- predict(model.random.final, newdata =  val, type = "response")
forest_acc(model.random.final)  # Accuracy = 91.2%

plot_roc_auc_curve(val, model.random.final, title = "Random Forest ROC") # 0.959

