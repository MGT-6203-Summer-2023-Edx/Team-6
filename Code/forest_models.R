
# Clean up the environment and seed the answer to everything
cat("\014")       # Clear the console (sends CTRL+L key command)
rm(list = ls())   # Clear all the variables and data
# Clear all plots
try(dev.off(dev.list()["RStudioGD"]),silent=TRUE)
try(dev.off(),silent=TRUE)


library(tidyverse)
# install.packages("tree")
library(tree)         # needed for tree function
library(randomForest) # needed for 
# install.packages("rpart")
# install.packages("rpart.plot")
# install.packages("rattle")
library(rpart)
library(rpart.plot)
library(rattle)
#install.packages("tictoc")
library(tictoc)

data = read.csv("Data/kaggle_aps/train.csv",header = TRUE)
#test = read.csv("Data/Kaggle_aps/test.csv", header = TRUE)
head(data)
summary(data)
str(data)

# Remove X and ID columns, factor all the columns except Age, Flight.Distance, Departure.Delay, and Arrival.Delay
data <- data %>%
    dplyr::select(-c(X,id)) %>%
    mutate(Gender = factor(Gender)) %>%
    mutate(Customer.Type = factor(Customer.Type)) %>%
    mutate(Type.of.Travel = factor(Type.of.Travel)) %>%
    mutate(Class = factor(Class)) %>%
    mutate(Inflight.wifi.service = factor(Inflight.wifi.service)) %>%
    mutate(Departure.Arrival.time.convenient = factor(Departure.Arrival.time.convenient)) %>%
    mutate(Ease.of.Online.booking = factor(Ease.of.Online.booking)) %>%
    mutate(Gate.location = factor(Gate.location)) %>%
    mutate(Food.and.drink = factor(Food.and.drink)) %>%
    mutate(Online.boarding = factor(Online.boarding)) %>%
    mutate(Seat.comfort = factor(Seat.comfort)) %>%
    mutate(Inflight.entertainment = factor(Inflight.entertainment)) %>%
    mutate(On.board.service = factor(On.board.service)) %>%
    mutate(Leg.room.service = factor(Leg.room.service)) %>%
    mutate(Baggage.handling = factor(Baggage.handling)) %>%
    mutate(Checkin.service = factor(Checkin.service)) %>%
    mutate(Inflight.service = factor(Inflight.service)) %>%
    mutate(Cleanliness = factor(Cleanliness)) %>%
    mutate(satisfaction=factor(ifelse(satisfaction=="satisfied", 1,0)))

str(data)            

# Drop the Arrival Delays column due to correlation
data_mod <- data %>%
    dplyr::select(-Arrival.Delay.in.Minutes)
str(data_mod)

# Stole this from Raajitha. 
# Almost all the variables has 0s. Only Departure..Arrival.time.convenient has slight more than 5% of the data.
# Imputing 0s with mode of the data
# function for mode
getmode = function(values){
    uniquev = unique(values)
    uniquev[which.max(tabulate(match(values,uniquev)))]
}

for (i in 9:ncol(data_mod)-2) {
    missing = which(data_mod[,i]==0)
    mode = as.numeric(getmode(data_mod[-missing,i]))
    data_mod[missing,i] = mode
}

sapply(data_mod,class)

data_mod = data_mod %>%
    mutate(Gender = factor(Gender)) %>%
    mutate(Customer.Type = factor(Customer.Type)) %>%
    mutate(Type.of.Travel = factor(Type.of.Travel)) %>%
    mutate(Class = factor(Class)) %>%
    mutate(Inflight.wifi.service = factor(Inflight.wifi.service)) %>%
    mutate(Departure.Arrival.time.convenient = factor(Departure.Arrival.time.convenient)) %>%
    mutate(Ease.of.Online.booking = factor(Ease.of.Online.booking)) %>%
    mutate(Gate.location = factor(Gate.location)) %>%
    mutate(Food.and.drink = factor(Food.and.drink)) %>%
    mutate(Online.boarding = factor(Online.boarding)) %>%
    mutate(Seat.comfort = factor(Seat.comfort)) %>%
    mutate(Inflight.entertainment = factor(Inflight.entertainment)) %>%
    mutate(On.board.service = factor(On.board.service)) %>%
    mutate(Leg.room.service = factor(Leg.room.service)) %>%
    mutate(Baggage.handling = factor(Baggage.handling)) %>%
    mutate(Checkin.service = factor(Checkin.service)) %>%
    mutate(Inflight.service = factor(Inflight.service)) %>%
    mutate(Cleanliness = factor(Cleanliness)) %>%
    mutate(satisfaction=factor(ifelse(satisfaction=="satisfied", 1,0)))
str(data_mod)

# Build a decision tree
model.rpart <- rpart(satisfaction~., data = data, method = "class")
model.rpart
summary(model.rpart)
fancyRpartPlot(model.rpart, main="Decision Tree Graph")
model.rpart$frame

# Plant a random forest with the "raw" data. Any NA values are omitted from the model
model.random <- randomForest(satisfaction~., data = data, na.action = na.omit, keep.forest = FALSE, importance = TRUE)
model.random
importance(model.random)
varImpPlot(model.random)

# Plant a random forest with the mod data. 0's imputed with the mode and Arrival delay removed
tic("model.random.mod")
model.random.mod <- randomForest(satisfaction~., data = data, na.action = na.omit, keep.forest = FALSE, importance = TRUE)
toc()
model.random.mod
importance(model.random.mod)
varImpPlot(model.random.mod)

