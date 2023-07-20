library(tidyverse)
library(stargazer)
if(basename(getwd())=="Final Code"){setwd('..')}
read.csv("Data/kaggle_aps/train.csv",
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
           Type.of.Travel = as.factor(Type.of.Travel),
           # 
           # Inflight.wifi.service = factor(na_if(Inflight.wifi.service,0), order=T)  ,
           # Departure.Arrival.time.convenient = factor(na_if(Departure.Arrival.time.convenient,0), order=T),
           # Ease.of.Online.booking  = factor(na_if(Ease.of.Online.booking,0), order=T),
           # Gate.location = factor(na_if(Gate.location,0), order=T),
           # Food.and.drink = factor(na_if(Food.and.drink,0), order=T),
           # Online.boarding = factor(na_if(Online.boarding,0), order=T),
           # Seat.comfort = factor(na_if(Seat.comfort, 0), order=T),
           # Inflight.entertainment = factor(na_if(Inflight.entertainment, 0), order=T),
           # On.board.service = factor(na_if(On.board.service, 0), order=T),
           # Leg.room.service = factor(na_if(Leg.room.service, 0), order=T),
           # Baggage.handling = factor(na_if(Baggage.handling, 0), order=T),
           # Checkin.service = factor(na_if(Checkin.service, 0), order=T),
           # Inflight.service = factor(na_if(Inflight.service, 0), order=T),
           # Cleanliness             = factor(na_if(Cleanliness , 0), order=T),
           # 

           Inflight.wifi.service = as.numeric(na_if(Inflight.wifi.service,0))  ,
           Departure.Arrival.time.convenient = as.numeric(na_if(Departure.Arrival.time.convenient,0)),
           Ease.of.Online.booking  = as.numeric(na_if(Ease.of.Online.booking,0)),
           Gate.location = as.numeric(na_if(Gate.location,0)),
           Food.and.drink = as.numeric(na_if(Food.and.drink,0)),
           Online.boarding = as.numeric(na_if(Online.boarding,0)),
           Seat.comfort = as.numeric(na_if(Seat.comfort, 0)),
           Inflight.entertainment = as.numeric(na_if(Inflight.entertainment, 0)),
           On.board.service = as.numeric(na_if(On.board.service, 0)),
           Leg.room.service = as.numeric(na_if(Leg.room.service, 0)),
           Baggage.handling = as.numeric(na_if(Baggage.handling, 0)),
           Checkin.service  = as.numeric(na_if(Checkin.service, 0)),
           Inflight.service = as.numeric(na_if(Inflight.service, 0)),
           Cleanliness      = as.numeric(na_if(Cleanliness , 0)),

           Departure.Delay.in.Minutes = as.numeric(Departure.Delay.in.Minutes),
           Arrival.Delay.in.Minutes = as.numeric(Arrival.Delay.in.Minutes),
           satisfaction = factor(satisfaction, levels=c("neutral or dissatisfied", "satisfied"))
           
           
           
    ) %>% 
    
    rename(satisfied=satisfaction) %>%
    mutate(satisfied=ifelse(satisfied=="satisfied", " True", "False")) %>%
    
    stargazer(type = "html", 
              title = "Likert Scaled and Continuous Variables", 
              out = "Visualizations/summary_1.html", summary.stat=c("n", "mean", "median", "sd", "min","p25", "p75", "max")) %>% 
    htmlTable::htmlTable()
