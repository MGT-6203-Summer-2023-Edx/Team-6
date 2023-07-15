library(ggplot2)
library(ggfortify)
library(tidyverse)
library(ROCR)

# Read and wrangle
df <- read.csv("Data/kaggle_aps/train.csv", header = T, 
               stringsAsFactors = F, 
               row.names = "X") %>% 
          mutate(Gender=factor(Gender),
                 Customer.Type=factor(Customer.Type),
                 Type.of.Travel=factor(Type.of.Travel),
                 Class=factor(Class),
                 satisfaction=ifelse(satisfaction=="satisfied", 1,0)) %>% 
          select(!id) 




# Train Logit
m <- df %>% glm(satisfaction ~ ., "binomial", .)

# Summary of Logit
m %>% summary(.)



# add a column for probability predictions
df$preds <- predict(m, df, "response")

# Create a Predict/True data.frame out of complete cases.
 
ROCR.df = df[complete.cases(df), c("preds", "satisfaction")]

# Create a ROCR prediction object
preds = prediction(ROCR.df$preds, ROCR.df$satisfaction)

# Create a ROCR performance object for the ROC curve
perf <- performance(preds,"tpr","fpr" )

# Create a ROCR performance object for the AUC, extract the value & round it. 
auc <- round(performance(preds, "auc")@y.values[[1]], 3)

# use autplot from ggfortify to make a pretty version of the 
# Roc curve. Adds an annotation with the AUC value. 
autoplot(perf) +
    annotate(geom="label",
             x=.90, y=.10, 
             label=paste("AUC:", round(auc,3)), 
             fill="white")

# Saves the most recent ggplot object as a png
ggsave(filename="basic_logit_roc_plot.png", path="Visualizations/",
       width =6, height=5, units="in")