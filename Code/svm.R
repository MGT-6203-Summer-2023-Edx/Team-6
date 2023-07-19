source("Code/preprocessor.R")
source("Code/roc_curves.R")
library(kernlab)
library(tidyverse)


train <- preprocessed$train
validate <- preprocessed$validate


n <- dim(train)[1]
set.seed(42)
train.sample <- train[sample(1:n, 12500, replace = F), ]

costs = c()
for (cost in c(.1, 1, 10, 100)) {
    m <-
        ksvm(x=satisfaction ~ .,
             data=train.sample,
             type='C-svc',
             kernel = "vanilladot",
             C = cost,
             scaled = T,
             prob.model=T
         )
    cat("c:",
        cost,
        "train:",
        mean(predict(m, train[,-22])==train$satisfaction),
        "validate:",
        mean(predict(m, validate[,-22])==validate$satisfaction),
        "\n" )
    costs <- c(costs, m)
}

plot_roc_auc_curve(validate, costs[[1]], title="C = 0.1" )
plot_roc_auc_curve(validate, costs[[2]], title="C = 1")
plot_roc_auc_curve(validate, costs[[3]], title="C = 10")
plot_roc_auc_curve(validate, costs[[4]], title="C = 100")