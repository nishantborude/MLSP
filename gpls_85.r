library("caret")
library("e1071")


labels_train = read.csv(file='~/MLSP/Train/train_labels.csv')
labels_train$Class = factor(labels_train$Class,labels=c('HC','SCZ'))

submission_example <- read.csv("~/MLSP/submission_example.csv")

FNC_train = read.csv(file='~/MLSP/Train/train_FNC.csv')
trC = trainControl(classProbs = TRUE, method = "cv", number = 10)


model = train(labels_train$Class ~ ., data = FNC_train[,2:86], 
              method = "gpls", 
              trControl = trC, tuneLength = 1)

#print(model$results)

j = 1
start = 1
last = 10000

#reading and predicting 12 seperated files of test data in bunch of 10000 rows
while(j <= 12){
  print(paste('File : ',j))
  if(last > 119748)
    last = 119748
  test_data = read.csv(file=paste('~/MLSP/Test/FNC_Test_',j,'.csv',sep = ""))
  p = predict(model, newdata = test_data[,2:86], type = "prob")
  
  submission_example$Probability[start:last] = p$SCZ
  j = j + 1
  start = last + 1
  last = last + 10000
}


write.csv(submission_example, file = '~/MLSP/results/gpls_85.csv', row.names = FALSE)
