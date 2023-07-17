#rm(list = ls())
library(tidyverse)

getmode <-  function(values) {
    uniquev = unique(values)
    uniquev[which.max(tabulate(match(values, uniquev)))]
}



preprocess <- function() {
    
    train_validate <- read.csv("Data/kaggle_aps/train.csv", header = T, stringsAsFactors = T) %>%
        
        #dropping id and arrival delay columns
        select(-X, -id, -Arrival.Delay.in.Minutes) %>%
        # Define numerics, transform lognormal variables.
        mutate(
            Age = as.numeric(Age),
            Flight.Distance = as.numeric(log(Flight.Distance)),
            Departure.Delay.in.Minutes = log(1 + as.numeric(Departure.Delay.in.Minutes)),
            across(7:20, as.factor),
            fold = sample(
                c("train", "validation"),
                n(),
                replace = T,
                prob = c(.7, .3)
            ),
            satisfaction = as.factor(ifelse(satisfaction == "satisfied", 1, 0))
        )
    
    test <- read.csv("Data/kaggle_aps/test.csv", header = T, stringsAsFactors = T) %>%
        
        #dropping id and arrival delay columns
        select(-X, -id, -Arrival.Delay.in.Minutes) %>%
        
        # Define numerics, transform lognormal variables.
        mutate(
            Age = as.numeric(Age),
            Flight.Distance = as.numeric(log(Flight.Distance)),
            Departure.Delay.in.Minutes = log(1 + as.numeric(Departure.Delay.in.Minutes)),
            across(7:20, as.factor),
            fold = "test",
            satisfaction = as.factor(ifelse(satisfaction == "satisfied", 1, 0))
        )
    
    
    likerts <- colnames(train_validate[, 7:20])
    modes <- train_validate %>%
        filter(fold == "train") %>%
        summarise(across(all_of(likerts), getmode))
    
    
    for (col.name in likerts) {
        train_validate[which(train_validate[col.name] == 0), col.name] <-
            modes[[1, col.name]]
        test[which(test[col.name] == 0), col.name] <-
            modes[[1, col.name]]
        
    }
    preproc = list(
        train = train_validate %>%
            filter(fold == "train") %>%
            mutate(across(7:20, droplevels)) %>% 
            select(-fold),
        validate = train_validate %>%
            filter(fold == "validation") %>%
            mutate(across(7:20, droplevels)) %>% 
            select(-fold),
        test = test %>%
            filter(fold == "test") %>%
            mutate(across(7:20, droplevels)) %>% 
            select(-fold)
    )
    return(preproc)
}

#splits <- preprocess()