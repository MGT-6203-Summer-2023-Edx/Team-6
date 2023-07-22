library(dplyr)
library(reshape)
library(ggplot2)
if(basename(getwd())=="Final Code"){setwd("..") }
file_id = "1H3Qk_68U7a3-M6ctAHIii3LEfGChz7EZ"
data <- read.csv(sprintf("https://docs.google.com/uc?id=%s&export=download", file_id), header = T, stringsAsFactors = T) %>%
  select(-X,-id) %>%
  mutate(Age = as.numeric(Age),
         Flight.Distance = as.numeric(log(Flight.Distance)),
         Departure.Delay.in.Minutes = as.numeric(Departure.Delay.in.Minutes),
         Arrival.Delay.in.Minutes = as.numeric(Arrival.Delay.in.Minutes),
         across(7:20, as.factor),
         satisfaction = as.factor(ifelse(satisfaction == "satisfied", 1, 0)))

summary(data)

#Arrival Delay has 310 NAs. Dropping all the NA values to check for correlations
data1 = data[!is.na(data$Arrival.Delay.in.Minutes), ]

#correlations after removing blanks
correlation = round(cor(data1[c(
  "Age",
  "Flight.Distance",
  "Departure.Delay.in.Minutes",
  "Arrival.Delay.in.Minutes"
)]), 2)

#generating heatmap
cor_mod = melt(correlation)

ggplot(data = cor_mod, aes(x = X1,y = X2, fill=value)) +
  geom_tile(color= "white") +
  theme(axis.text.x = element_text(angle = 45, vjust = 1, size = 9, hjust = 1)) +
  scale_fill_gradient2(low = "blue", high = "red", mid = "gray", midpoint = 0, limit = c(-1,1), space = "Lab", 
                       name="Correlation",guide = guide_colorbar(barheight = 4)) +
  coord_fixed() +
  geom_text(aes(X2, X1, label = value), color = "black", size = 3) +
  labs(title = "Heatmap") +
  theme(axis.title.x = element_blank(), axis.title.y = element_blank())

#since arrival and departure delays are highly correlated, arrival delay column is dropped without removing blank rows
data_mod = data[,c(1:21,23)]

#checking the count 0s for likert scale categorical variables
for(i in 9:ncol(data_mod)-2){
  print(colnames(data_mod)[i])
  print(table(data_mod[,i]))
  cat("\n")
}

#Almost all the variables has 0s. Only Departure.Arrival.time.convenient has slight more than 5% of the data. Since the data is ordinal, imputing 0s with mode.
#writing a function for mode
getmode = function(values){
  uniquev = unique(values)
  uniquev[which.max(tabulate(match(values,uniquev)))]
}

#calculating mode
likerts <- colnames(data_mod[, 7:20])
modes <- data_mod %>%
  summarise(across(all_of(likerts), getmode))

#replace all "0" values with the corresponding mode
for (col.name in likerts) {
  data_mod[which(data_mod[col.name] == 0), col.name] = modes[[1, col.name]]
}

data_mod = data_mod %>%
  mutate(across(7:20, droplevels))
summary(data_mod)
sapply(data_mod,class)

#correlations for categorical variables
corr = c()
cat1 = c()
cat2 = c()
for (i in c(1,2,4,5,7:20)) {
  for (j in c(1,2,4,5,7:20)) {
    x = as.numeric(ordered(data_mod[,i])) #this is not treating x and y simply as continuous numbers. It is treating them as ranks
    y = as.numeric(ordered(data_mod[,j]))
    correlation = cor(x, y, method = "spearman")
    cat1 = c(cat1,colnames(data_mod)[i])
    cat2 = c(cat2,colnames(data_mod)[j])
    corr = c(corr,correlation)
  }
}
cat_corr = data.frame(cat1,cat2,corr)

#heatmap for categorical variables
library(ggplot2)
ggplot(cat_corr,aes(x=cat1,y=cat2,fill=corr)) +
  geom_tile() +
  theme(axis.text.x = element_text(angle = 45, vjust = 1, size = 9, hjust = 1)) +
  scale_fill_gradient2(mid="#FBFEF9",low="#0C6291",high="#A63446", midpoint = 0, limit = c(-1,1), space = "Lab", 
                       name="Correlation",guide = guide_colorbar(barheight = 4)) +
  geom_text(aes(label = round(corr,2)), color = "black", size = 2.3) +
  labs(title = "Heatmap for Categorical variables") +
  theme(axis.title.x = element_blank(), axis.title.y = element_blank())

#plots for categorical variables
cat_plot = function(variable,xlabel){
  ggplot(data_mod, aes(x=variable,fill=satisfaction)) +
    geom_histogram(stat="count",position = "identity",alpha=0.5) +
    xlab(xlabel)
}

custType = ggplot(data_mod, aes(x=Customer.Type,fill=satisfaction)) +
  geom_histogram(stat="count",position = "identity",alpha=0.5)+
  scale_x_discrete(labels = c("disloyal","loyal"))

travelType = ggplot(data_mod, aes(x=Type.of.Travel,fill=satisfaction)) +
  geom_histogram(stat="count",position = "identity",alpha=0.5)+
  scale_x_discrete(labels=c("Business","Personal"))

gender = cat_plot(data_mod$Gender,"Gender")
age = cat_plot(data_mod$Age,"Age")
class = cat_plot(data_mod$Class,"Class")
wifi = cat_plot(data_mod$Inflight.wifi.service,"Inflight.wifi.service")
depArrConvenience = cat_plot(data_mod$Departure.Arrival.time.convenient,"Departure.Arrival.time.convenient")
onlinebooking = cat_plot(data_mod$Ease.of.Online.booking,"Ease.of.Online.booking")
gate = cat_plot(data_mod$Gate.location,"Gate.location")
food = cat_plot(data_mod$Food.and.drink,"Food.and.drink")
onlineBoarding = cat_plot(data_mod$Online.boarding,"Online.boarding")
seat = cat_plot(data_mod$Seat.comfort,"Seat.comfort")
entertainment = cat_plot(data_mod$Inflight.entertainment,"Inflight.entertainment")
onboard = cat_plot(data_mod$On.board.service,"On.board.service")
legroom = cat_plot(data_mod$Leg.room.service,"Leg.room.service")
baggage = cat_plot(data_mod$Baggage.handling,"Baggage.handling")
checkin = cat_plot(data_mod$Checkin.service,"Checkin.service")
inflightService = cat_plot(data_mod$Inflight.service,"Inflight.service")
clean = cat_plot(data_mod$Cleanliness,"Cleanliness")

library(ggpubr)
ggarrange(gender,custType,age,travelType,class,wifi,depArrConvenience,onlinebooking,gate,food,onlineBoarding,seat,entertainment,onboard,legroom,baggage,checkin,
          inflightService,clean,ncol=4,nrow=5)

age_custtype = ggplot(data_mod, aes(x=Age,fill=Customer.Type)) +
  geom_histogram(stat="count",position = "identity",alpha=0.5)

checkin_class = ggplot(data_mod, aes(x=Checkin.service,fill=Class)) +
  geom_histogram(stat="count",position = "identity",alpha=0.5)

seat_class = ggplot(data_mod, aes(x=Seat.comfort,fill=Class)) +
  geom_histogram(stat="count",position = "identity",alpha=0.5)

food_class = ggplot(data_mod, aes(x=Food.and.drink,fill=Class)) +
  geom_histogram(stat="count",position = "identity",alpha=0.5)

ggarrange(age_custtype, checkin_class, seat_class, food_class, ncol=2, nrow=2)

#numeric variable transformations
#plotting flight distance for various transformations
qqplot = function(variable,title){
  qqnorm(variable,main = title)
  qqline(variable)
}

hist_plot = function(variable,xlabel,title){
  ggplot(data = data_mod) +
    geom_histogram(mapping = aes(x=variable), bins = 30) +
    xlab(xlabel) +
    labs(title = title)
}

qqplot(data_mod$Flight.Distance, "QQ Plot - Flight Distance")
hist_plot(data_mod$Flight.Distance,"Flight.Distance","Flight Distance")

qqplot(log(data_mod$Flight.Distance), "QQ Plot - log of Flight Distance")
hist_plot(log(data_mod$Flight.Distance),"Flight.Distance","Log transformed Flight Distance")

qqplot(sqrt(data_mod$Flight.Distance), "QQ Plot - SQRT of Flight Distance")
hist_plot(sqrt(data_mod$Flight.Distance),"Flight.Distance","SQRT of Flight Distance")

#box-cox transformation of flight distance
library(MASS)
b = boxcox(lm(Flight.Distance~1,data = data_mod))
lambda = b$x[which.max(b$y)]
distance = (data_mod$Flight.Distance^lambda - 1)/lambda

qqplot(sqrt(distance), "QQ Plot - boxcox for Flight Distance")
hist_plot(sqrt(distance),"Flight.Distance","Flight Distance transformed by boxcox")
#boxcox also yielded same results as log tranformation

#box plots to check outliers
boxplot(data_mod$Flight.Distance)
boxplot(sqrt(data_mod$Flight.Distance))
boxplot(log(data_mod$Flight.Distance))
boxplot(distance)

#plots for departure delay with various transformations
qqplot(data_mod$Departure.Delay.in.Minutes, "QQ Plot - Departure delay")
hist_plot(data_mod$Departure.Delay.in.Minutes,"Departure.Delay.in.Minutes","Departure delay")

qqplot(log(data_mod$Departure.Delay.in.Minutes+1), "QQ Plot - log of Departure delay")
hist_plot(log(data_mod$Departure.Delay.in.Minutes+1),"Departure.Delay.in.Minutes","Log transformed Departure delay")

qqplot(sqrt(data_mod$Departure.Delay.in.Minutes), "QQ Plot - SQRT of Departure delay")
hist_plot(sqrt(data_mod$Departure.Delay.in.Minutes),"Departure.Delay.in.Minutes","SQRT of Departure delay")

#outliers in departure delay
boxplot(data_mod$Departure.Delay.in.Minutes)
boxplot(sqrt(data_mod$Departure.Delay.in.Minutes))
boxplot(log(data_mod$Departure.Delay.in.Minutes+1))

#Both flight distance and departure delay do not assume normal distribution even after transformations and box plot shows lots of data as outliers except for 
#the log transformed data. Hence, based on our group’s judgement, we decided to apply log transformation to both variables
data_mod$Departure.Delay.in.Minutes = data_mod$Departure.Delay.in.Minutes+1
data_mod$Departure.Delay.in.Minutes = log(data_mod$Departure.Delay.in.Minutes)
data_mod$Flight.Distance = log(data_mod$Flight.Distance)

#As per the box plots, Flight distance doesn't have any outliers after transformation but departure delay has.

#All the above transformations are simplied in a function in the "Preprocessor" file. It has the code for log transformations, imputation and data split to train and valid
#We pulled the data from that function and checked for outliers in the train set
#The z-score is effective method if the data is normally distributed which is not the case with our data. Hence, choosing IQR method to check and remove outliers.
if(basename(getwd())=="Team-6"){setwd("Final Code/") }
source("preprocessor.R")
data_all = preprocess()
train = data_all$train
Q1 = quantile(train$Departure.Delay.in.Minutes,.25)
Q3 = quantile(train$Departure.Delay.in.Minutes,.75)
IQR = IQR(train$Departure.Delay.in.Minutes)

outliers_removed = subset(train,train$Departure.Delay.in.Minutes > (Q1 - 1.5*IQR) &
                            train$Departure.Delay.in.Minutes < (Q3 + 1.5*IQR))
dim(train)
dim(outliers_removed)
#outliers are only 12 and these might be real data. For example, a flight can be delayed for more than 3-4 hours because of bad weather, technical difficulties etc.,
#So, we decided to keep them in the data
