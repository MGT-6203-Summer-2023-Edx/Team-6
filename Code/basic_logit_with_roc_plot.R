library(ggplot2)
library(ggfortify)
library(tidyverse)

df <- read.csv("Data/kaggle_aps/train.csv", header = T, 
               stringsAsFactors = F, 
               row.names = "X") %>% 
          mutate(Gender=factor(Gender),
                 Customer.Type=factor(Customer.Type),
                 Type.of.Travel=factor(Type.of.Travel),
                 Class=factor(Class),
                 satisfaction=ifelse(satisfaction=="satisfied", 1,0)) %>% 
          select(!id) 
    

m <- df %>% glm(satisfaction ~ ., "binomial", .)

m %>% summary(.)

df$preds <- predict(m, df, "response")
ROCR.df = k.aps.clean[complete.cases(k.aps.clean), c("preds", "satisfaction")]
preds = prediction(ROCR.df$preds, ROCR.df$satisfaction)
perf <- performance(preds,"tpr","fpr" )

auc <- round(performance(preds, "auc")@y.values[[1]], 3)
autoplot(perf) +
    annotate(geom="label", x=.90, y=.10, label=paste("AUC:", round(auc,3)), fill="white")
ggsave(filename="basic_logit_roc_plot.png", path="Visualizations/", 
       width =6, height=5, units="in")