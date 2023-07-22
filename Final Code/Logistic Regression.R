if(basename(getwd())=="Team-6"){setwd("Final Code")}
source("preprocessor.R")
data = preprocess()
train = data$train
valid = data$validate
test = data$test
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

#running the model again after removing insignificant variables from the above model
model = glm(satisfaction~Customer.Type+Age+Type.of.Travel+Class+Inflight.wifi.service+Departure.Arrival.time.convenient_3+Departure.Arrival.time.convenient_4+
              Departure.Arrival.time.convenient_5+Ease.of.Online.booking+Gate.location+Food.and.drink_2+Online.boarding+
              Seat.comfort+Inflight.entertainment+On.board.service_3+On.board.service_4+On.board.service_5+Leg.room.service_4+Leg.room.service_5+
              Baggage.handling+Checkin.service+Inflight.service+Cleanliness_3+Cleanliness_4+Cleanliness_5+Departure.Delay.in.Minutes, 
              data=train, family = binomial(link = "logit"))
summary(model)

model = glm(satisfaction~Customer.Type+Age+Type.of.Travel+Class+Inflight.wifi.service+Departure.Arrival.time.convenient_3+Departure.Arrival.time.convenient_4+
              Departure.Arrival.time.convenient_5+Ease.of.Online.booking+Gate.location_3+Gate.location_4+Gate.location_5+Food.and.drink_2+Online.boarding+
              Seat.comfort+Inflight.entertainment+On.board.service_3+On.board.service_4+On.board.service_5+Leg.room.service_4+Leg.room.service_5+
              Baggage.handling+Checkin.service+Inflight.service+Cleanliness_3+Cleanliness_4+Cleanliness_5+
              Departure.Delay.in.Minutes, data=train, family = binomial(link = "logit"))
summary(model)

#function for accuracy
accuracy = function(data_acc){
  pred = round(predict(model, data_acc,type="response"))
  matrix = as.matrix(table(pred,data_acc$satisfaction))
  acc = (matrix[1,1]+matrix[2,2])/sum(matrix)
  return(acc)
}

#function for ROC curve
roc = function(data_roc,title){
  predictions <- prediction(as.numeric(predict(model, data_roc,type="response")), as.numeric(data_roc$satisfaction))
  roc <- performance(predictions,"tpr", "fpr")
  plot(roc, main=title)
  auc <- performance(predictions, measure = "auc")
  auc <- auc@y.values[[1]]
  return(auc)
}

#training accuracy
accuracy_train = accuracy(train)
cat("Training accuracy is",accuracy_train)

#roc curve for train set
library(ROCR)
auc_train = roc(train,"ROC curve of glm model for training set")
cat("Area under the Curve for training set is",auc_train)


#adding the dummy columns to validation set to check the model's accuracy
columns_names = colnames(valid)
columns = columns_names[c(1:2,4:5,7:20)]
valid = fastDummies::dummy_cols(valid,select_columns = columns)

#validation set accuracy
accuracy_valid = accuracy(valid)
cat("Validation accuracy is",accuracy_valid)

#roc curve for validation set
auc_valid = roc(valid,"ROC curve of glm model for validation set")
cat("Area under the Curve for validation set is",auc_valid)

#adding the dummy columns to test set to check the model's accuracy
columns_names = colnames(test)
columns = columns_names[c(1:2,4:5,7:20)]
test = fastDummies::dummy_cols(test,select_columns = columns)

#test set accuracy
accuracy_test = accuracy(test)
cat("test accuracy is",accuracy_test)

#roc curve for test set
auc_test = roc(test,"ROC curve of glm model for test set")
cat("Area under the Curve for test set is",auc_test)

stargazer::stargazer(model, type="html",out = "Visualizations/final_model.html", single.row = T, no.space=T, summary=F, style = "all2") %>% htmlTable::htmlTable()
library(car)
var.inflation <- vif(model)
stargazer::stargazer(var.inflation, type="html",out = "Visualizations/variance_inflation_factors.html", summary=F) %>% htmlTable::htmlTable()
