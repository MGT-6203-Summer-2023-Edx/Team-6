source("Code/preprocessor.R")
source("Code/roc_curves.R")
library(kernlab)
library(tidyverse)


train <- preprocessed$train

# means <- train %>% summarize(across(where(is.numeric), mean)) %>% select(-satisfaction)
# std.devs <- train %>% summarize(across(where(is.numeric), sd)) %>% select(-satisfaction)
# 
# apply.standardize <- function(data, means, std.devs){
#     n <- dim(data)[1]
#     for (.column in colnames(data)){
#         
#         subtractor <- rep(means[.column], n)
#         divisor <- rep(std.devs[.column], n)
#         data[.column] <- (data[.column] - subtractor)/divisor
#         
#     }
#     return(data)
#     
# }

n <- dim(train)[1]
train.sample <- train[sample(1:n, 10000, replace = F ),]
m <- ksvm(satisfaction ~ ., train.sample)

summary(m)
# 
# apply.standardize(train %>% select(where(is.numeric), -satisfaction),
#                   means = means, 
#                   std.devs=std.devs)

