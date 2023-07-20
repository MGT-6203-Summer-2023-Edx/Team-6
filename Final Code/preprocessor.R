#This function splits the data into a training and validation set
#and cleans the data. 
#This function is called by our models and makes it so that
#our models are using the exact same data with the exact same transormations.


#rm(list = ls())
library(tidyverse)

#Function to get the mode of "values"
#We will replace N/A or blank data with the mode
getmode <-  function(values) {
    uniquev = unique(values)
    uniquev[which.max(tabulate(match(values, uniquev)))]
}


if(basename(getwd())=="Final Code"){setwd("..")}
preprocess <- function() {
    set.seed(42)
    #training data is ~100,000 rows
    file_id = "1H3Qk_68U7a3-M6ctAHIii3LEfGChz7EZ"
    train_validate <- read.csv(sprintf("https://docs.google.com/uc?id=%s&export=download", file_id), header = T, stringsAsFactors = T) %>%
        
        #dropping id and arrival delay columns
        dplyr::select(-X, -id, -Arrival.Delay.in.Minutes) %>%
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
                prob = c(.75, .25) #final split is 60/20/20 train/val/test. Note that test data is in separate file
            ),
            satisfaction = as.factor(ifelse(satisfaction == "satisfied", 1, 0))
        )
    
    #test data is ~25,000 rows
    test_file_id = "1IF78CMjRwtlotSUxrMexKS9Zmxa0GTzw"
    test <- read.csv(sprintf("https://docs.google.com/uc?id=%s&export=download", test_file_id), header = T, stringsAsFactors = T) %>%
        
        #dropping id and arrival delay columns
        dplyr::select(-X, -id, -Arrival.Delay.in.Minutes) %>%
        
        # Define numerics, transform lognormal variables.
        mutate(
            Age = as.numeric(Age),
            Flight.Distance = as.numeric(log(Flight.Distance)),
            Departure.Delay.in.Minutes = log(1 + as.numeric(Departure.Delay.in.Minutes)),
            across(7:20, as.factor),
            fold = "test",
            satisfaction = as.factor(ifelse(satisfaction == "satisfied", 1, 0))
        )
    
    #calculate the mode for each likert scale feature (likert scale is integers 0 - 5)
    #note only train (not validation) data is used to calculate the mode
    likerts <- colnames(train_validate[, 7:20])
    modes <- train_validate %>%
        filter(fold == "train") %>%
        summarise(across(all_of(likerts), getmode))
    
    #replace all "0" values with the corresponding mode
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
            dplyr::select(-fold),
        validate = train_validate %>%
            filter(fold == "validation") %>%
            mutate(across(7:20, droplevels)) %>% 
            dplyr::select(-fold),
        test = test %>%
            filter(fold == "test") %>%
            mutate(across(7:20, droplevels)) %>% 
            dplyr::select(-fold)
    )
    return(preproc)
}

#splits <- preprocess()
