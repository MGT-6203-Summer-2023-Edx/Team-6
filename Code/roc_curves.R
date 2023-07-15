library(ggplot2)
library(ggfortify)
library(tidyverse)
library(ROCR)
#library(gridExtra)
source(file = "Code/preprocessor.R")

# # Read and wrangle
# preprocessed <- preprocess()
# 
# train <- preprocessed$train
# validate <- preprocessed$validate
# 
# 
# # Train Logit
# m <- train %>% glm(satisfaction ~ ., "binomial", .)

# add a column for probability predictions

plot_roc_auc_curve <-
    function(.data,
             model,
             target = "satisfaction",
             title = "ROC Curve") {
        .data$preds <- predict(model, .data, "response")
        .ROCR <-
            .data[complete.cases(.data), c("preds", "satisfaction")]
        .ROCR.preds <- prediction(.ROCR$preds, .ROCR$satisfaction)
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
                ggtitle(title, )
        )
    }


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
