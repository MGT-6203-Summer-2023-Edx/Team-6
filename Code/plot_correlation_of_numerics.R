library(tidyverse)
library(reshape)

setwd(dir = "c:/School/GT6203_DAB/Team-6/")

# Select variablles, define types
df <- read.csv("Data/kaggle_aps/train.csv", header = TRUE) %>%
               select(Gender, Customer.Type, Age, Type.of.Travel, Class, Flight.Distance, Inflight.wifi.service, 
                      Departure.Arrival.time.convenient, Ease.of.Online.booking, Gate.location, Food.and.drink, 
                      Online.boarding, Seat.comfort, Inflight.entertainment, On.board.service, Leg.room.service, 
                      Baggage.handling, Checkin.service, Inflight.service, Cleanliness, Departure.Delay.in.Minutes, 
                      Arrival.Delay.in.Minutes, satisfaction) %>%
               mutate(Age = as.numeric(Age)) %>%
               mutate(Flight.Distance = as.numeric(Flight.Distance)) %>%
               mutate(Departure.Delay.in.Minutes =as.numeric(Departure.Delay.in.Minutes)) %>%
               mutate(Arrival.Delay.in.Minutes = as.numeric(Arrival.Delay.in.Minutes)) 

# Drop records where Arrival delay is blank
df %>% filter(!is.na(Arrival.Delay.in.Minutes)) %>% 
    # Select numeric columns
    select(Age, Flight.Distance, Departure.Delay.in.Minutes, Arrival.Delay.in.Minutes) %>% 
    # Calculate correlations
    cor(.) %>% 
    # Round off values
    round(., 2) %>% 
    # Melt (wide to long) the data for plotting
    melt(.) %>% 
  ggplot(., aes(x = X1,y = X2, fill=value)) +
    geom_tile(color= "white") +
    theme(axis.text.x = element_text(angle = 45, vjust = 1, 
                                     size = 9, hjust = 1)) +
    scale_fill_gradient2(low = "blue", high = "red", mid = "gray", 
                         midpoint = 0, limit = c(-1,1), space = "Lab", 
                         name="Correlation",guide = guide_colorbar(barheight = 4)) +
    coord_fixed() +
    geom_text(aes(X2, X1, label = value), color = "black", size = 2) +
    labs(title = "Correlation of Numeric Variables") +
    theme(axis.title.x = element_blank(), axis.title.y = element_blank())

    
ggsave(filename="correlation_of_numeric_vars.png", path="Visualizations/", 
       width =6, height=6, units="in")
    