source("Code/preprocessor.R")
source("Code/roc_curves.R")
library(kernlab)
library(tidyverse)


train <- preprocessed$train
validate <- preprocessed$validate


n <- dim(train)[1]
set.seed(42)
train.sample <- train[sample(1:n, 10000, replace = F), ]

costs = list()
for (cost in c(.1, 1, 10)) {
    m <-
        ksvm(x=satisfaction ~ .,
             data=train.sample,
             type='C-svc',
             kernel = "vanilladot",
             C = cost,
             scaled = T
         )
    cat("c:",
        cost,
        "train:",
        mean(predict(m, train[,-22])==train$satisfaction),
        "validate:",
        mean(predict(m, validate[,-22])==validate$satisfaction),
        "\n")
    costs[[paste("c=", cost)]] <- m
}
set.seed(42)
train.sample <- train[sample(1:n, 50000, replace = F), ]

for (cost in c(1:100, seq(100, 1000,10))) {
    m <-
        ksvm(x=satisfaction ~ .,
             data=train.sample,
             type='C-svc',
             kernel = "vanilladot",
             C = cost,
             scaled = T
        )
    cat("c:",
        cost,
        "train:",
        mean(predict(m, train[,-22])==train$satisfaction),
        "validate:",
        mean(predict(m, validate[,-22])==validate$satisfaction),
        "\n")
    costs[[paste("c=", cost)]] <- m
}