# Clean up the environment and seed the answer to everything
cat("\014")       # Clear the console (sends CTRL+L key command)
rm(list = ls())   # Clear all the variables and data
# Clear all plots
try(dev.off(dev.list()["RStudioGD"]),silent=TRUE)
try(dev.off(),silent=TRUE)


source("Code/preprocessor.R")
source("Code/preprocessor_test.R")
source("Code/roc_curves.R")
library(kernlab)
library(tidyverse)
library(rpart)
library(rpart.plot)
library(rattle)     # Used for fancyRpartPlot

# Get the data
train <- data$train
val <- data$validate
test <- data$test
str(train)
str(val)
# Since rpart performs cross-validation, we need to stick the train and validation data sets back together
train.full <- rbind(train, val)
str(train.full)

model.rpart <- NULL
# Build a decision tree function
decision_tree <- function(dataset){
    cat("*** RPART for data set: ", deparse(substitute(dataset)), "***\n")
    model.rpart <- rpart(satisfaction~., data = dataset, method = "class")
    print(model.rpart)
    # summary(model.rpart)
    fancyRpartPlot(model.rpart, main = paste0("Data set:" ,deparse(substitute(dataset))), cex = 0.7)
    rsq.rpart(model.rpart)
    title(main = paste0("Data set:" ,deparse(substitute(dataset))))
    tmp <- printcp(model.rpart)
    print("R Squared value for each split")
    print(round(1 - tmp[,c(3,4)], 4))
    # print(model.rpart$frame)
    return(model.rpart)
}

# Build a function to check model accuracy against the test data set
decision_tree_acc <- function(model){
    # Predict model against the test set
    predict <- predict(model, test, type = "class")
    # Find accuracy of the model on the test data set
    acc <- mean(predict == test$satisfaction)
    print(paste0("Full training set model accuracy: ", round(acc,4)))
}

# Build decision tree for each data set
model.train.full <- decision_tree(train.full)
# Data set data information/notes
# Top Factors: Online.boarding, Inflight.wifi.service, Type.of.Travel
# Rel Error: 4 splits = 0.6837, 5 splits = 0.7093

# Check the accuracy of the model against the test data set
decision_tree_acc(model.train.full)
# Model notes: Accuracy is 0.8729. Could potentially prune the model slightly with little impact
# on accuracy.

# Since Type.of.travel is such an important factor, let's explore that factor more
# Break the data into the different classes for exploration
train.full.type_business <- train.full %>% filter(Type.of.Travel == "Business travel")
train.full.type_personal <- train.full %>% filter(Type.of.Travel == "Personal Travel")

model.train.full.type_business <- decision_tree(train.full.type_business)
# Data set data.type_business information/notes
# Top Factors: Online.boarding, Inflight.wifi, Inflight.entertainment
# This could be pruned back to 4 splits
#   rel error xerror
# 1    0.0000 0.0000
# 2    0.5874 0.5874
# 3    0.6408 0.6408
# 4    0.6909 0.6909
# 5    0.7334 0.7334

# Check the accuracy of the model against the test data set
decision_tree_acc(model.train.full.type_business)
# Model Notes: Accuracy is 0.7621. Based on the rsq plot, the model could be trimmed back
# several splits with minimal impact. Might be worth it if we want to use this model to
# explain to people what is going on.


model.train.full.type_pesonal <- decision_tree(train.full.type_personal)
# Data set data.type_personal information/notes
# Top Factors: Online.boarding, Inflight.wifi.service
#   rel error xerror
# 1    0.0000 0.0000
# 2    0.3968 0.3968
# 3    0.5050 0.5044


# For personal travel, it seems that inflight wifi and online boarding are important
decision_tree_acc(model.train.full.type_pesonal)
# Model Notes: Accuracy is 0.6847. This model could be heavily pruned.


# Models based on class
train.full.class_business <- train.full %>% filter(Class == "Business")
train.full.class_eco <- train.full %>% filter(Class == "Eco")
train.full.class_eco_plus <- train.full %>% filter(Class == "Eco Plus")

# Build the models
model.train.full.class_business <- decision_tree(train.full.class_business)
model.train.full.class_eco <- decision_tree(train.full.class_eco)
model.train.full.class_eco_plus<- decision_tree(train.full.class_eco_plus)
# Notes: The models all show in flight WiFi and entertainment along with online boarding 
# among the top factors. On the business class, we see Comfort for the first time rising
# to being an important factor.
