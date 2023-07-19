data = preprocess()
train = data$train
valid = data$validate

#forward selection to check the order of importance of variables
model_all = glm(satisfaction~.,data=train, family = binomial(link = "logit"))
model_intercept = glm(satisfaction~1,data=train, family = binomial(link = "logit"))

forward = step(model_intercept,scope = formula(model_all),direction="forward",trace = 0)
forward$anova
#Except flight distance, forward selection has chosen all the features. We decided to check the same with logistic regression and remove insignificant variables

model = glm(satisfaction~., data=subset(train,select = c(-Flight.Distance)), family = binomial(link = "logit"))
summary(model)

#few classes of factor variables are insignificant. So, adding dummy variables to the data so that the insignificant classes can be excluded from the model
columns_names = colnames(train)
columns = columns_names[c(1:2,4:5,7:20)]
train = fastDummies::dummy_cols(train,select_columns = columns)
head(train)

#running the model again after removing insignificant variables
model = glm(satisfaction~Gender_Female+Customer.Type+Age+Type.of.Travel+Class+Flight.Distance+Inflight.wifi.service+
              Departure.Arrival.time.convenient_1+Departure.Arrival.time.convenient_3+Departure.Arrival.time.convenient_4+Departure.Arrival.time.convenient_5+
              Ease.of.Online.booking+Gate.location+Food.and.drink_1+Food.and.drink_2+Online.boarding+Seat.comfort+Inflight.entertainment+On.board.service_1+
              On.board.service_3+On.board.service_4+On.board.service_5+Leg.room.service_1+Leg.room.service_4+Leg.room.service_5+Baggage.handling+
              Checkin.service+Inflight.service+Cleanliness_1+Cleanliness_3+Cleanliness_4+Cleanliness_5+Departure.Delay.in.Minutes, 
              data=train, family = binomial(link = "logit"))
summary(model)

#running the model again after removing insignificant variables from the above model
model = glm(satisfaction~Customer.Type+Age+Type.of.Travel+Class+Flight.Distance+Inflight.wifi.service+Departure.Arrival.time.convenient_3+
              Departure.Arrival.time.convenient_4+Departure.Arrival.time.convenient_5+Ease.of.Online.booking+Gate.location+Food.and.drink_2+Online.boarding+
              Seat.comfort+Inflight.entertainment+On.board.service_3+On.board.service_4+On.board.service_5+Leg.room.service_4+Leg.room.service_5+
              Baggage.handling+Checkin.service+Inflight.service+Cleanliness_3+Cleanliness_4+Cleanliness_5+Departure.Delay.in.Minutes, 
              data=train, family = binomial(link = "logit"))
summary(model)

model = glm(satisfaction~Customer.Type+Age+Type.of.Travel+Class+Flight.Distance+Inflight.wifi.service+Departure.Arrival.time.convenient_3+
              Departure.Arrival.time.convenient_4+Departure.Arrival.time.convenient_5+Ease.of.Online.booking+Gate.location_3+Gate.location_4+
              Gate.location_5+Food.and.drink_2+Online.boarding+Seat.comfort+Inflight.entertainment+On.board.service_3+On.board.service_4+On.board.service_5+
              Leg.room.service_4+Leg.room.service_5+Baggage.handling+Checkin.service+Inflight.service+Cleanliness_3+Cleanliness_4+Cleanliness_5+
              Departure.Delay.in.Minutes, data=train, family = binomial(link = "logit"))
summary(model)

#function for accuracy
accuracy = function(data_acc){
  pred = round(predict(model, data_acc,type="response"))
  matrix = as.matrix(table(pred,data_acc$satisfaction))
  acc = (matrix[1,1]+matrix[2,2])/sum(matrix)
  return(acc)
}

#training accuracy
accuracy_train = accuracy(train)
cat("Training accuracy is",accuracy_train)

#roc curve
library(ROCR)
predictions <- prediction(as.numeric(predict(model, train,type="response")), as.numeric(train$satisfaction))
roc <- performance(predictions,"tpr", "fpr")
plot(roc,main="ROC curve for GLM model")

#area under the curve
auc <- performance(predictions, measure = "auc")
auc <- auc@y.values[[1]]
cat("Area under the Curve is",auc)

#adding the dummy columns to validation set to check the model's accuracy
columns_names = colnames(valid)
columns = columns_names[c(1:2,4:5,7:20)]
valid = fastDummies::dummy_cols(valid,select_columns = columns)

#validation set accuracy
accuracy_valid = accuracy(valid)
cat("Validation accuracy is",accuracy_valid)
