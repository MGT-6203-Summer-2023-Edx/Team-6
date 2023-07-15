rm(list = ls())
library(tidyverse)

getmode = function(values) {
    uniquev = unique(values)
    uniquev[which.max(tabulate(match(values, uniquev)))]
}


data = read.csv("Data/kaggle_aps/train.csv", header = TRUE) %>%

    #dropping id and arrival delay columns
    select(-X,-id,-Arrival.Delay.in.Minutes) %>%

    # Define numerics, transform lognormal variables.
    mutate(
        Age = as.numeric(Age),
        Flight.Distance = as.numeric(log(Flight.Distance)),
        Departure.Delay.in.Minutes = log(1 + as.numeric(Departure.Delay.in.Minutes))
    )

likerts <- colnames(data[,7:20])
modes <- data %>%
    summarise(across(all_of(likerts), getmode))


for (col.name in likerts){
    data[which(data[col.name]==0), col.name] <- modes[[1, col.name]]
}
preproc = list(data=data, modes=modes)