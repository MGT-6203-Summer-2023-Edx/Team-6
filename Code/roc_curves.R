library(ggplot2)
library(ggfortify)
library(tidyverse)
library(ROCR)
library(glue)
#library(gridExtra)


is_ksvm <- function(model) {
    return("ksvm" %in% class(model))
}

is_rfc <- function(model) {
    return("randomForest" == class(model))
}

is_decision_tree <- function(model) {
    return("rpart" == class(model))
}


is_logit <- function(model) {
    model_class <- class(model)
    if ("glm" %in% model_class && "family" %in% names(model)) {
        if (model$family$family == "binomial") {
            return(TRUE)
        }
    }
    return(FALSE)
}

.get_ksvm_preds <- function(.data, model, target) {
    if (class(.data) != "data.frame") stop("First arg to .get_ksvm_preds is not a data.frame")
    .data$preds <- predict(model, .data, type = "probabilities")[,2]
    .ROCR <- .data[, c("preds", target)]
    .ROCR.preds <- prediction(.ROCR$preds, .ROCR[target])
    return(.ROCR.preds)
}
.get_logit_preds <- function(.data, model, target) {
    if (class(.data) != "data.frame") stop("First arg to .get_logit_preds is not a data.frame")
    .data$preds <- predict(model, .data, type = "response")
    .ROCR <- .data[complete.cases(.data), c("preds", target)]
    .ROCR.preds <- prediction(.ROCR$preds, .ROCR[target])
    return(.ROCR.preds)
}
.get_rfc_preds <- function(.data, model, target) {
    if (class(.data) != "data.frame") stop("First arg to .get_rfc_preds is not a data.frame")
    .data$preds <- predict(model, .data, type = "prob")[,2]
    .ROCR <- .data[complete.cases(.data), c("preds", target)]
    .ROCR.preds <- prediction(.ROCR$preds, .ROCR[target])
    return(.ROCR.preds)
}
.get_decision_tree_preds <- function(.data, model, target) {
    if (class(.data) != "data.frame") stop("First arg to .get_rfc_preds is not a data.frame")
    .data$preds <- predict(model, .data, type = "prob")[,2]
    .ROCR <- .data[complete.cases(.data), c("preds", target)]
    .ROCR.preds <- prediction(.ROCR$preds, .ROCR[target])
    return(.ROCR.preds)
}
.get_rocr_predictions <- function(.data, model, target) {
   # .data=1; model=m;target = "satisfaction";
    if (is_ksvm(model)) {
        .ROCR.preds <-  .get_ksvm_preds(.data, model, target)
    } else if (is_logit(model)) {
        .ROCR.preds <- .get_logit_preds(.data, model, target)
        
    }else if (is_rfc(model)) {
        .ROCR.preds <- .get_rfc_preds(.data, model, target)
        
    }else if (is_decision_tree(model)) {
        .ROCR.preds <- .get_rfc_preds(.data, model, target)
        
    } else {
        stop(glue("Invalid model type. Model must be a glm logit or svm, not {class(model)}."))
    }
    
    

    return(.ROCR.preds)
}
get_auc <- function(.data, model, target = "satisfaction") {
    .ROCR.preds <- .get_rocr_predictions(.data, model, target)
    .ROCR.perf.auc <- performance(.ROCR.preds, "auc")
    return(.ROCR.perf.auc@y.values[[1]])
}
plot_roc_auc_curve <-
    function(.data,
             model,
             target = "satisfaction",
             title = "ROC Curve") {
        if (class(.data) != "data.frame") stop("First arg to plot_roc_auc_curve is not a data.frame")
        .ROCR.preds <-  .get_rocr_predictions(.data, model, target)

        .ROCR.perf.roc.curve <-
            performance(.ROCR.preds, "tpr", "fpr")
        .ROCR.perf.auc <- performance(.ROCR.preds, "auc")
        .ROCR.auc <- get_auc(.data, model, target = "satisfaction")
        theme_update(plot.title = element_text(hjust = 0.5))
        return(
            autoplot(.ROCR.perf.roc.curve) +
                annotate(
                    geom = "label",
                    x = .90,
                    y = .10,
                    label = paste("AUC:", round(.ROCR.auc, 3)),
                    fill = "white"
                ) +
                ggtitle(title, )
        )
    }



.test_curves <- function() {
  source(file = "Code/preprocessor.R")
    
  preprocessed = preprocess()
  train <- preprocessed$train
  validate <- preprocessed$validate
  
  n <- dim(train)[1]
  set.seed(42)
  train.sample <- train[sample(1:n, 10000, replace = F),]


  library(kernlab)
  library(randomForest)
  library(rpart)
  # m.svm <-
  #     ksvm(
  #         x = satisfaction ~ .,
  #         data = train.sample,
  #         type = 'C-svc',
  #         kernel = "vanilladot",
  #         C = .01,
  #         scaled = T,
  #         prob.model = T
  #     )
  .data <- train.sample
  factors <- c("Online.boarding", "Checkin.service", "Inflight.wifi.service", 
               "Type.of.Travel", "Baggage.handling", "Seat.comfort")
  m.rpart <- rpart(satisfaction~., data = train, method = "class")
  m.rfc <-  randomForest(x = train[,factors], y = train[,22], ntree = 250)
  m.logit <- train %>% glm(satisfaction ~ ., "binomial", .)
  plot_roc_auc_curve(validate, m.rfc, title = "RFC Test")
  plot_roc_auc_curve(validate, m.rpart, title = "Decision Tree Test")
  
  lot_roc_auc_curve(train.sample, m.svm, title = "SVM Test")
  plot_roc_auc_curve(train, m.logit, title = "Logit Test")
  
}


# g <- grid.arrange(p.train, p.validate, ncol = 2)
# g
# # Saves the most recent ggplot object as a png
# ggsave(
#     filename = "logit_sbs_roc_plots.png",
#     plot =  g,
#     path = "Visualizations/",
#     width = 9,
#     height = 5,
#     units = "in"
# )
