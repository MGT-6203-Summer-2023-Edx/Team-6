library(tidyverse)
library(stargazer)
library(fastDummies)
library(htmlTable)
library(scales)
if(basename(getwd())=="Final Code"){setwd("..")}
df.factors <- read.csv("Data/kaggle_aps/train.csv",
         header = T, 
         stringsAsFactors = F, 
         row.names = "X") %>% 
    select(-id) %>% 
    mutate(Gender = as.factor(Gender),
           Customer.Type = as.factor(Customer.Type),
           Age = as.numeric(Age),
           Type.of.Travel = as.factor(Type.of.Travel),
           Class           = as.factor(Class),
           Flight.Distance = as.numeric(Flight.Distance) %>% na_if(0),

           Departure.Delay.in.Minutes = as.numeric(Departure.Delay.in.Minutes),
           Arrival.Delay.in.Minutes = as.numeric(Arrival.Delay.in.Minutes),
           satisfaction = factor(satisfaction, levels=c("neutral or dissatisfied", "satisfied"))
           
           
           
    ) %>% 
    
    rename(satisfied=satisfaction) %>%
    mutate(satisfied=as.factor(ifelse(satisfied=="satisfied", 1, 0))) %>%
    select(where(is.factor)) 
 
x.1 <- xtabs(~Gender +satisfied  , dummy_cols(df.factors))
x.2 <- xtabs(~Class +satisfied  , dummy_cols(df.factors))
x.3 <- xtabs(~Type.of.Travel +satisfied  , dummy_cols(df.factors))
x.4 <- xtabs(~Customer.Type +satisfied  , dummy_cols(df.factors))

p.1 <- proportions(x.1, 1)
p.2 <- proportions(x.2, 1)
p.3 <- proportions(x.3, 1)
p.4 <- proportions(x.4, 1)

df.xtbl <- rbind(cbind(x.1, p.1),
                 cbind(x.2, p.2),
                 cbind(x.3, p.3),
                 cbind(x.4, p.4)) %>% 
    data.frame() %>% 
    mutate(X0=X0, X1=X1, X0.1=percent(as.numeric(X0.1)), X1.1=percent(as.numeric(X1.1)) ) %>% 
    rename(not.satisfied=X0, 
           satisfied=X1, 
           "not.satisfied.%"=X0.1, 
           "satisfied.%"=X1.1) 

rownames(df.xtbl)[6] <- "Business Travel"
rownames(df.xtbl)[8] <- "Disloyal Customer"


df.xtbl %>% stargazer(type="html", 
                      summary=F, 
                      title= "Target Variable Distribution across Factor Variables",
                      out = "Visualizations/summary_2.html") %>% 
    htmlTable()
