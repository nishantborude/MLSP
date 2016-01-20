library("caret")
library("e1071")


labels_train = read.csv(file='~/MLSP/Train/train_labels.csv')
labels_train$Class = factor(labels_train$Class,labels=c('HC','SCZ'))

submission_example <- read.csv("~/MLSP/submission_example.csv")

train_data = read.csv(file='~/MLSP/Train/sa_fs_Train.csv')

trC = trainControl(classProbs = TRUE, method = "cv")

model = train(labels_train$Class ~ ., data = train_data[,2:113], 
              method = "gpls", 
              trControl = trC, tuneLength = 1)

#print(model$results)

#file sa_fs_Test contains 112 feature selected using 'Simulated Annealing' feature selection
test_data = read.csv(file="~/MLSP/Test/sa_fs_Test.csv")

j = 1
start = 1
last = 10000
while(j <= 12){
  print(paste('File : ',j))
  if(last > 119748)
    last = 119748
  p = predict(model, newdata = test_data[start:last,2:113], type = "prob")
  submission_example$Probability[start:last] = p$SCZ
  j = j + 1
  start = last + 1
  last = last + 10000
}

write.csv(submission_example, file ='~/MLSP/results/sa_fs_gpls.csv', row.names = FALSE)
