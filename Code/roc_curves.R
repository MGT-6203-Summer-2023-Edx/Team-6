library(ggplot2)
library(ggfortify)
library(tidyverse)
library(ROCR)
#library(gridExtra)
source(file = "Code/preprocessor.R")


is_ksvm <- function(model) {
    return( "ksvm" %in% class(model) )
}

is_logit <- function(model) {
    model_class <- class(model)
    if ( "glm" %in% model_class && "family" %in% names(model)) {
        if (model$family$family == "binomial") {
            return(TRUE)
        }
    }
    return(FALSE)
}


.get_rocr_predictions <- function(.data, model, target) {
    if (is_ksvm(model)) {
        .data$preds <- predict(model, type = "probabilities")
        .ROCR <- .data[(.data), c("preds", target)]
    } else if (is_logit(model)) {
        .data$preds <- predict(model, .data, type = "response")
        .ROCR <- .data[complete.cases(.data), c("preds", target)]
    } else {
        stop("Invalid model type. Model must be a glm logit or svm.")
    }
    

    .ROCR.preds <- prediction(.ROCR$preds, .ROCR[target])
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
        .ROCR.preds <-  .get_rocr_predictions(.data, model, target)
        .ROCR.perf.roc.curve <-
            performance(.ROCR.preds, "tpr", "fpr")
        .ROCR.perf.auc <- performance(.ROCR.preds, "auc")
        .ROCR.auc <- round(.ROCR.perf.auc@y.values[[1]], 3)
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
                ggtitle(title,)
        )
    }




# 
# # Read and wrangle
# preprocessed <- preprocess()
# 
# train <- preprocessed$train
# validate <- preprocessed$validate
# 
# 
# # Train Logit
# m <- train %>% glm(satisfaction ~ ., "binomial", .)
# 
# # add a column for probability predictions
# plot_roc_auc_curve(train, m)
# p.train <- plot_roc_auc_curve(
#     train,
#     model = m,
#     target = "satisfaction",
#     title = "Base Logit Training ROC Curve"
# )
# p.validate <-
#     plot_roc_auc_curve(
#         validate,
#         model = m,
#         target = "satisfaction",
#         title = "Base Logit Validation ROC Curve"
#     )
#
#
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
