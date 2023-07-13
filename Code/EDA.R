data = read.csv("Data/kaggle_aps/train.csv",header = TRUE)

library(dplyr)

#dropping id and arrival delay columns
data = data %>%
  select(Gender,Customer.Type,Age,Type.of.Travel,Class,Flight.Distance,Inflight.wifi.service,
         Departure..Arrival.time.convenient,Ease.of.Online.booking,Gate.location,Food.and.drink,
         Online.boarding,Seat.comfort,Inflight.entertainment,On.board.service,Leg.room.service,
         Baggage.handling,Checkin.service,Inflight.service,Cleanliness,Departure.Delay.in.Minutes,
         satisfaction) %>%
  mutate(Age = as.numeric(Age)) %>%
  mutate(Flight.Distance = as.numeric(log(Flight.Distance))) %>%
  mutate(Departure.Delay.in.Minutes =as.numeric(Departure.Delay.in.Minutes))

data$Departure.Delay.in.Minutes = data$Departure.Delay.in.Minutes+1
data$Departure.Delay.in.Minutes = log(data$Departure.Delay.in.Minutes)

#imputation using mode
getmode = function(values){
  uniquev = unique(values)
  uniquev[which.max(tabulate(match(values,uniquev)))]
}

colnames(data)

modes = c()
for (i in 9:ncol(data)-2) {
  missing = which(data[,i]==0)
  if(length(missing)!=0){
    mode = as.numeric(getmode(data[-missing,i]))
    modes = c(modes,mode)
    data[missing,i] = mode
  }
  if(length(missing)==0){
    mode = as.numeric(getmode(data[,i]))
    modes = c(modes,mode)
  }
}
modes

#making the likert scale variables to factors
data = data %>%
  mutate(Gender = factor(Gender)) %>%
  mutate(Customer.Type = factor(Customer.Type)) %>%
  mutate(Type.of.Travel = factor(Type.of.Travel)) %>%
  mutate(Class = factor(Class)) %>%
  mutate(Inflight.wifi.service = factor(Inflight.wifi.service)) %>%
  mutate(Departure..Arrival.time.convenient = factor(Departure..Arrival.time.convenient)) %>%
  mutate(Ease.of.Online.booking = factor(Ease.of.Online.booking)) %>%
  mutate(Gate.location = factor(Gate.location)) %>%
  mutate(Food.and.drink = factor(Food.and.drink)) %>%
  mutate(Online.boarding = factor(Online.boarding)) %>%
  mutate(Seat.comfort = factor(Seat.comfort)) %>%
  mutate(Inflight.entertainment = factor(Inflight.entertainment)) %>%
  mutate(On.board.service = factor(On.board.service)) %>%
  mutate(Leg.room.service = factor(Leg.room.service)) %>%
  mutate(Baggage.handling = factor(Baggage.handling)) %>%
  mutate(Checkin.service = factor(Checkin.service)) %>%
  mutate(Inflight.service = factor(Inflight.service)) %>%
  mutate(Cleanliness = factor(Cleanliness)) %>%
  mutate(satisfaction=factor(ifelse(satisfaction=="satisfied", 1,0)))

#splitting the data into train and validation sets
set.seed(42)
data_split = sample(seq(1,2),size = nrow(data),replace = TRUE,prob = c(0.75,0.25))
train = data[data_split==1,]
valid = data[data_split==2,]

#checking for outliers
boxplot(train$Departure.Delay.in.Minutes)

#checking count of outliers using quantiles method
Q1 = quantile(train$Departure.Delay.in.Minutes,.25)
Q3 = quantile(train$Departure.Delay.in.Minutes,.75)
IQR = IQR(train$Departure.Delay.in.Minutes)

outliers_removed = subset(train,train$Departure.Delay.in.Minutes > (Q1 - 1.5*IQR) &
                    train$Departure.Delay.in.Minutes < (Q3 + 1.5*IQR))

dim(outliers_removed)
dim(train)
#outliers are only 12 and these might be real data. For example, a flight can be delayed for more than 3-4 hours because of bad weather, technical difficulties etc.,
#So, we decided to keep them in the data



#making the same transformations for test data as well.
test = read.csv("Data/kaggle_aps/test.csv",header = TRUE)
head(test)
colnames(test)
#one column name is different from train data. So renaming it
colnames(test)[10]="Departure..Arrival.time.convenient"

#dropping id and arrival delay columns as dimensions have to be same as of train data. Also, applying log transformation to flight distance and departure delay as 
#the same was done to the training data. Otherwise, model can perform worse on the test data and lead to unreliable results
test = test %>%
  select(Gender,Customer.Type,Age,Type.of.Travel,Class,Flight.Distance,Inflight.wifi.service,
         Departure..Arrival.time.convenient,Ease.of.Online.booking,Gate.location,Food.and.drink,
         Online.boarding,Seat.comfort,Inflight.entertainment,On.board.service,Leg.room.service,
         Baggage.handling,Checkin.service,Inflight.service,Cleanliness,Departure.Delay.in.Minutes,
         satisfaction) %>%
  mutate(Age = as.numeric(Age)) %>%
  mutate(Flight.Distance = as.numeric(log(Flight.Distance))) %>%
  mutate(Departure.Delay.in.Minutes =as.numeric(Departure.Delay.in.Minutes))

test$Departure.Delay.in.Minutes = test$Departure.Delay.in.Minutes+1
test$Departure.Delay.in.Minutes = log(test$Departure.Delay.in.Minutes)

#imputing mode
for(i in 9:ncol(test)-2){
  print(colnames(test)[i])
  print(table(test[,i]))
  cat("\n")
}

j=1
for (i in 9:ncol(test)-2) {
  missing = which(test[,i]==0)
  mode = modes[j]
  if(length(missing)!=0){
    test[missing,i] = mode
  }
  j=j+1
}

#converting data type of likert scale variables from numeric to factors
test = test %>%
  mutate(Gender = factor(Gender)) %>%
  mutate(Customer.Type = factor(Customer.Type)) %>%
  mutate(Type.of.Travel = factor(Type.of.Travel)) %>%
  mutate(Class = factor(Class)) %>%
  mutate(Inflight.wifi.service = factor(Inflight.wifi.service)) %>%
  mutate(Departure..Arrival.time.convenient = factor(Departure..Arrival.time.convenient)) %>%
  mutate(Ease.of.Online.booking = factor(Ease.of.Online.booking)) %>%
  mutate(Gate.location = factor(Gate.location)) %>%
  mutate(Food.and.drink = factor(Food.and.drink)) %>%
  mutate(Online.boarding = factor(Online.boarding)) %>%
  mutate(Seat.comfort = factor(Seat.comfort)) %>%
  mutate(Inflight.entertainment = factor(Inflight.entertainment)) %>%
  mutate(On.board.service = factor(On.board.service)) %>%
  mutate(Leg.room.service = factor(Leg.room.service)) %>%
  mutate(Baggage.handling = factor(Baggage.handling)) %>%
  mutate(Checkin.service = factor(Checkin.service)) %>%
  mutate(Inflight.service = factor(Inflight.service)) %>%
  mutate(Cleanliness = factor(Cleanliness)) %>%
  mutate(satisfaction=factor(ifelse(satisfaction=="satisfied", 1,0)))

summary(test)
