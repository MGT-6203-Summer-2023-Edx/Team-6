source("Code/preprocessor.R")
source("Code/roc_curves.R")
library(kernlab)
library(tidyverse)

preprocessed = preprocess()
train <- preprocessed$train
validate <- preprocessed$validate
# Train Logit
m <- train %>% glm(satisfaction ~ ., "binomial", .)

# Summary of Logit
m %>% summary(.)

plot_roc_auc_curve(train, m, "satisfaction", "Training")
plot_roc_auc_curve(validate, m, "satisfaction", "Validation")
