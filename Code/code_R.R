library(tidyverse)
library(reshape)

data = read.csv("Data/kaggle_aps/train.csv",header = TRUE)
head(data)
summary(data)

data = data %>%
  select(Gender,Customer.Type,Age,Type.of.Travel,Class,Flight.Distance,Inflight.wifi.service,
         Departure.Arrival.time.convenient,Ease.of.Online.booking,Gate.location,Food.and.drink,
         Online.boarding,Seat.comfort,Inflight.entertainment,On.board.service,Leg.room.service,
         Baggage.handling,Checkin.service,Inflight.service,Cleanliness,Departure.Delay.in.Minutes,
         Arrival.Delay.in.Minutes,satisfaction) %>%
  mutate(Age = as.numeric(Age)) %>%
  mutate(Flight.Distance = as.numeric(Flight.Distance)) %>%
  mutate(Departure.Delay.in.Minutes =as.numeric(Departure.Delay.in.Minutes)) %>%
  mutate(Arrival.Delay.in.Minutes = as.numeric(Arrival.Delay.in.Minutes))



dim(data)

#correlations for numeric variables - gives NA as arrival delay has missing values
round(cor(data[c("Age","Flight.Distance","Departure.Delay.in.Minutes","Arrival.Delay.in.Minutes")]),2)

#data with no NA
data1 = data[!is.na(data$Arrival.Delay.in.Minutes),]
dim(data1)

#correlations after removing blanks
correlation = round(cor(data1[c("Age","Flight.Distance","Departure.Delay.in.Minutes","Arrival.Delay.in.Minutes")]),2)

#heatmap
cor_mod = melt(correlation)
cor_mod

ggplot(data = cor_mod, aes(x = X1,y = X2, fill=value)) +
  geom_tile(color= "white") +
  theme(axis.text.x = element_text(angle = 45, vjust = 1, 
                                   size = 9, hjust = 1)) +
  scale_fill_gradient2(low = "blue", high = "red", mid = "gray", 
                       midpoint = 0, limit = c(-1,1), space = "Lab", 
                       name="Correlation",guide = guide_colorbar(barheight = 4)) +
  coord_fixed() +
  geom_text(aes(X2, X1, label = value), color = "black", size = 2) +
  labs(title = "Heatmap") +
  theme(axis.title.x = element_blank(), axis.title.y = element_blank())


#since arrival and departure delays are highly correlated, let's drop arrival delay column without dropping blank rows
data_mod = data[,c(1:21,23)]
dim(data_mod)
head(data_mod)
sapply(data_mod, class)


qqnorm(data_mod$Flight.Distance,main = "QQ Plot - Flight Distance")
qqline(data_mod$Flight.Distance)

qqnorm(log(data_mod$Flight.Distance),main = "QQ Plot - log of Flight Distance")
qqline(log(data_mod$Flight.Distance))

qqnorm(sqrt(data_mod$Flight.Distance),main = "QQ Plot - SQRT of Flight Distance")
qqline(sqrt(data_mod$Flight.Distance))

ggplot(data = data_mod) +
  geom_histogram(mapping = aes(x=Flight.Distance), bins = 30) +
  labs(title = "Flight Distance")

ggplot(data = data_mod) +
  geom_histogram(mapping = aes(x=log(Flight.Distance)), bins = 20) +
  labs(title = "Log transformed Flight Distance")

ggplot(data = data_mod) +
  geom_histogram(mapping = aes(x=sqrt(Flight.Distance)),bins = 20) +
  labs(title = "SQRT of Flight Distance")

#box-cox transformation of flight distance
library(MASS)
b = boxcox(lm(Flight.Distance~1,data = data_mod))
lambda = b$x[which.max(b$y)]
lambda

data_mod$distance = (data_mod$Flight.Distance^lambda - 1)/lambda

head(data_mod)
dim(data_mod)

qqnorm(sqrt(data_mod$distance),main = "QQ Plot- boxcox for Flight Dist")
qqline(sqrt(data_mod$distance))

ggplot(data = data_mod) +
  geom_histogram(mapping = aes(x=distance), bins = 30) +
  labs(title = "Flight Distance")

#box plots to check outliers
boxplot(data_mod$Flight.Distance)
boxplot(sqrt(data_mod$Flight.Distance))
boxplot(log(data_mod$Flight.Distance))
boxplot(data_mod$distance)


#qq plots for departure delay
qqnorm(data_mod$Departure.Delay.in.Minutes, main = "Departure delay")
qqline(data_mod$Departure.Delay.in.Minutes)

qqnorm(sqrt(data_mod$Departure.Delay.in.Minutes), main = "SQRT of Departure delay")
qqline(sqrt(data_mod$Departure.Delay.in.Minutes))

qqnorm(log(data_mod$Departure.Delay.in.Minutes+1), main = "log of Departure delay")
qqline(log(data_mod$Departure.Delay.in.Minutes+1))

ggplot(data = data_mod) +
  geom_histogram(mapping = aes(x=Departure.Delay.in.Minutes), bins = 30)

ggplot(data = data_mod) +
  geom_histogram(mapping = aes(x=sqrt(Departure.Delay.in.Minutes)), bins = 30)

ggplot(data = data_mod) +
  geom_histogram(mapping = aes(x=log(Departure.Delay.in.Minutes+1)), bins = 30)

#outliers in departure delay
boxplot(data_mod$Departure.Delay.in.Minutes)
boxplot(sqrt(data_mod$Departure.Delay.in.Minutes))
boxplot(log(data_mod$Departure.Delay.in.Minutes+1))

qqnorm(data_mod$Age, main = "Age")
qqline(data_mod$Age)


#applying log transformations to flight distance and departure delay as those are better compared to other transformations
data_mod$Departure.Delay.in.Minutes = data_mod$Departure.Delay.in.Minutes+1
data_mod$Departure.Delay.in.Minutes = log(data_mod$Departure.Delay.in.Minutes)

data_mod$Flight.Distance = log(data_mod$Flight.Distance)

#removing outliers using quantiles
Q1 = quantile(data_mod$Departure.Delay.in.Minutes,.25)
Q3 = quantile(data_mod$Departure.Delay.in.Minutes,.75)
IQR = IQR(data_mod$Departure.Delay.in.Minutes)

outliers = subset(data_mod,data_mod$Departure.Delay.in.Minutes > (Q1 - 1.5*IQR) &
                    data_mod$Departure.Delay.in.Minutes < (Q3 + 1.5*IQR))
dim(outliers)

qqnorm(outliers$Departure.Delay.in.Minutes, main = "Dep delay")
qqline(outliers$Departure.Delay.in.Minutes)

ggplot(data = outliers) +
  geom_histogram(mapping = aes(x=Departure.Delay.in.Minutes), bins = 30)

boxplot(outliers$Departure.Delay.in.Minutes)


#removing outliers using z-score
data_mod_1 = data_mod
data_mod_1$zscore = (abs(data_mod_1$Departure.Delay.in.Minutes - mean(data_mod_1$Departure.Delay.in.Minutes))/sd(data_mod_1$Departure.Delay.in.Minutes))

new = subset(data_mod_1,data_mod_1$zscore<3)
dim(new)
summary(new)

qqnorm(new$Departure.Delay.in.Minutes, main = "Dep delay")
qqline(new$Departure.Delay.in.Minutes)

ggplot(data = new) +
  geom_histogram(mapping = aes(x=Departure.Delay.in.Minutes), bins = 30)

boxplot(new$Departure.Delay.in.Minutes)

#z-score is effective method if the data is normally distributed which is not the case with our data. Hence, choosing
#IQR method to remove outliers.
#writing the code again
head(data_mod)
dim(data_mod)
Q1 = quantile(data_mod$Departure.Delay.in.Minutes,.25)
Q3 = quantile(data_mod$Departure.Delay.in.Minutes,.75)
IQR = IQR(data_mod$Departure.Delay.in.Minutes)

data_mod = subset(data_mod,data_mod$Departure.Delay.in.Minutes > (Q1 - 1.5*IQR) &
                    data_mod$Departure.Delay.in.Minutes < (Q3 + 1.5*IQR))
dim(data_mod)

#checking 0s for each categorical variable
for(i in 9:ncol(data_mod)-2){
  print(colnames(data_mod)[i])
  print(table(data_mod[,i]))
  cat("\n")
}

#Almost all the variables has 0s. Only Departure..Arrival.time.convenient has slight more than 5% of the data.
#Imputing 0s with mode of the data
#function for mode
getmode = function(values){
  uniquev = unique(values)
  uniquev[which.max(tabulate(match(values,uniquev)))]
}

for (i in 9:ncol(data_mod)-2) {
  missing = which(data_mod[,i]==0)
  mode = as.numeric(getmode(data_mod[-missing,i]))
  data_mod[missing,i] = mode
}

sapply(data_mod,class)

data_mod = data_mod %>%
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

summary(data_mod)
sapply(data_mod,class)

#correlations for categorical variables
library(polycor)
polychor(data_mod$Checkin.service,data_mod$Checkin.service)

corr = c()
cat1 = c()
cat2 = c()
for (i in c(1,2,4,5,7:20)) {
  for (j in c(1,2,4,5,7:20)) {
    correlation = polychor(data_mod[,i],data_mod[,j],maxcor = 1)
    cat1 = c(cat1,colnames(data_mod)[i])
    cat2 = c(cat2,colnames(data_mod)[j])
    corr = c(corr,correlation)
  }
}
length(corr)
length(cat1)
length(cat2)
cat_corr = data.frame(cat1,cat2,corr)
head(cat_corr)

#heatmap
library(ggplot2)
ggplot(cat_corr,aes(x=cat1,y=cat2,fill=corr)) +
  geom_tile() +
  theme(axis.text.x = element_text(angle = 45, vjust = 1, 
                                   size = 9, hjust = 1)) +
  scale_fill_gradient2(mid="#FBFEF9",low="#0C6291",high="#A63446", 
                       midpoint = 0, limit = c(-1,1), space = "Lab", 
                       name="Correlation",guide = guide_colorbar(barheight = 4)) +
  geom_text(aes(label = round(corr,2)), color = "black", size = 2) +
  labs(title = "Heatmap for Categorical variables") +
  theme(axis.title.x = element_blank(), axis.title.y = element_blank())


#plots for categorical variables
gender = ggplot(data_mod, aes(x=Gender,fill=satisfaction)) +
  geom_histogram(stat="count",position = "identity",alpha=0.5)

class = ggplot(data_mod, aes(x=Class,fill=satisfaction)) +
  geom_histogram(stat="count",position = "identity",alpha=0.5)

seat = ggplot(data_mod, aes(x=Seat.comfort,fill=satisfaction)) +
  geom_histogram(stat="count",position = "identity",alpha=0.5)

seat_class = ggplot(data_mod, aes(x=Seat.comfort,fill=Class)) +
  geom_histogram(stat="count",position = "identity",alpha=0.5)

age = ggplot(data_mod, aes(x=Age,fill=satisfaction)) +
  geom_histogram(position = "identity",alpha=0.5)

checkin = ggplot(data_mod, aes(x=Checkin.service,fill=Class)) +
  geom_histogram(stat="count",position = "identity",alpha=0.5)

clean = ggplot(data_mod, aes(x=Cleanliness,fill=satisfaction)) +
  geom_histogram(stat="count",position = "identity",alpha=0.5)

library(ggpubr)
ggarrange(gender,seat,seat_class,age,checkin,clean,
          ncol=1,nrow=6)

#stepwise regression
model_all = glm(satisfaction~.,data=data_mod, family = binomial(link = "logit"))
model_intercept = glm(satisfaction~1,data=data_mod, family = binomial(link = "logit"))

forward = step(model_intercept,scope = formula(model_all),direction="forward",trace = 0)
forward$anova
forward$coefficients



#splitting the data to train and validation sets
data_split = sample(seq(1,2),size = nrow(data_mod),replace = TRUE,prob = c(0.7,0.3))

train = data_mod[data_split==1,]
valid = data_mod[data_split==2,]

#logistic regression
model = glm(satisfaction~., data=train, family = binomial(link = "logit"))
summary(model)

#few variables are insignificant. So, adding dummies only to the significant ones.
#creating dummies for all categorical variables
columns_names = colnames(data_mod)
columns = columns_names[c(1:2,4:5,7:20)]
data_mod = fastDummies::dummy_cols(data_mod,select_columns = columns)
head(data_mod)

colnames(data_mod)
colnames(data_mod)[25] = "Customer.Type_disloyal_Customer"
colnames(data_mod)[26] = "Customer.Type_Loyal_Customer"
colnames(data_mod)[27] = "Type.of.Travel_Business_travel"
colnames(data_mod)[28] = "Type.of.Travel_Personal_Travel"
colnames(data_mod)
sapply(data_mod,class)

train = data_mod[data_split==1,]
valid = data_mod[data_split==2,]

model = glm(satisfaction~Gender_Female+Customer.Type+Age+Type.of.Travel+Class+
              Inflight.wifi.service_1+Inflight.wifi.service_3+Inflight.wifi.service_4+Inflight.wifi.service_5+
              Departure..Arrival.time.convenient+Ease.of.Online.booking_1+Ease.of.Online.booking_2+
              Ease.of.Online.booking_3+Ease.of.Online.booking_4+Gate.location_1+Gate.location_3+Gate.location_4+
              Gate.location_5+Food.and.drink_1+Food.and.drink_2+Food.and.drink_4+Online.boarding+Seat.comfort+
              Inflight.entertainment+On.board.service_1+On.board.service_3+On.board.service_4+On.board.service_5+
              Leg.room.service+Baggage.handling+Checkin.service+Inflight.service+Cleanliness_1+
              Cleanliness_3+Cleanliness_4+Cleanliness_5+Departure.Delay.in.Minutes,
            data=train, family = binomial(link = "logit"))
summary(model)

model = glm(satisfaction~Customer.Type+Age+Type.of.Travel+Class+Inflight.wifi.service_3+Inflight.wifi.service_4+
              Inflight.wifi.service_5+Departure..Arrival.time.convenient+Ease.of.Online.booking_2+
              Ease.of.Online.booking_3+Ease.of.Online.booking_4+Gate.location_3+Gate.location_4+Gate.location_5+
              Food.and.drink_2+Food.and.drink_4+Online.boarding+Seat.comfort+Inflight.entertainment+On.board.service_3+
              On.board.service_4+On.board.service_5+Leg.room.service+Baggage.handling+Checkin.service+Inflight.service+
              Cleanliness_3+Cleanliness_4+Cleanliness_5+Departure.Delay.in.Minutes,
            data=train, family = binomial(link = "logit"))
summary(model)

pred = round(predict(model, valid,type="response"))
matrix = as.matrix(table(pred,valid$satisfaction))
accuracy = (matrix[1,1]+matrix[2,2])/sum(matrix)
accuracy
print('fini')
