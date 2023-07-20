source("Code/preprocessor.R")
source("Code/roc_curves.R")
library(kernlab)
library(tidyverse)
preprocessed <- preprocess()
train <- preprocessed$train
validate <- preprocessed$validate


n <- dim(train)[1]
set.seed(42)
train.sample <- train[sample(1:n, 15000, replace = F),]

# costs = c()
# for (cost in c(.1, 1, 10, 100)) {
#     m <-
#         ksvm(x=satisfaction ~ .,
#              data=train.sample,
#              type='C-svc',
#              kernel = "vanilladot",
#              C = cost,
#              scaled = T,
#              prob.model=T
#          )
#     cat("c:",
#         cost,
#         "train:",
#         mean(predict(m, train[,-22])==train$satisfaction),
#         "validate:",
#         mean(predict(m, validate[,-22])==validate$satisfaction),
#         "\n" )
#     costs <- c(costs, m)
# }

m <-
    ksvm(
        x = satisfaction ~ .,
        data = train.sample,
        type = 'C-svc',
        kernel = "vanilladot",
        C = 100,
        scaled = T,
        prob.model = T
    )

plot_roc_auc_curve(validate, m, title = "SVM with C=100")

svm.coefs <- data.frame(colSums(m@xmatrix[[1]] * m@coef[[1]]))
colnames(svm.coefs) <- "Coefficient"
svm.coefs <- svm.coefs %>% dplyr::arrange(Coefficient)

ggplot(svm.coefs, aes(x = Coefficient, y = reorder(rownames(svm.coefs), abs(Coefficient)))) +
    geom_bar(stat = "identity") +
    #coord_flip() +
    theme_minimal() +
    labs(title = "Feature Importance",
         x = "Coefficient",
         y = "Features")
