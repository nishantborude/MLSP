library("caret")
library("e1071")

model_info = data.frame(model = character(10), data = character(10), method = character(10))
model_info$model = c('glm','lda','LMT','gpls','wsrf','gbm','dwdPoly','nnet','rf','nb')
model_info$data = c('SBM','both','SBM','both','both','both','both','both','both','both')
model_info$method = c('cv','cv','cv','cv','boot','cv','cv','boot','cv','boot')

labels_train = read.csv(file='~/MLSP/Train/train_labels.csv')
labels_train$Class = factor(labels_train$Class,labels=c('HC','SCZ'))

submission_example <- read.csv("~/MLSP/submission_example.csv")

i = 1
while(i <= 10){
  print(paste('model : ',i))
  SBM_train = read.csv(file='~/MLSP/Train/train_SBM.csv')
  trC = trainControl(classProbs = TRUE, method = model_info$method[i])

  if(model_info$data[i] == 'SBM'){
    model = train(labels_train$Class ~ ., data = SBM_train[,2:33], 
          method = model_info$model[i], 
          trControl = trC, tuneLength = 1)
    j = 1
    start = 1
    last = 10000
    while(j <= 12){
      print(paste('File : ',j))
      if(last > 119748)
        last = 119748
      test_data = read.csv(file=paste('~/MLSP/Test/SBM_Test_',j,'.csv',sep = ""))
      p = predict(model, newdata = test_data[,2:33], type = "prob")
      submission_example$Probability[start:last] = p$SCZ
      j = j + 1
      start = last + 1
      last = last + 10000
    }
  }else{
    FNC_train = read.csv(file='~/MLSP/Train/train_FNC.csv')
    both_train = merge(FNC_train, SBM_train, by="Id")
    model = train(labels_train$Class ~ ., data = both_train[,2:411], 
                  method = model_info$model[i], 
                  trControl = trC, tuneLength = 1)
    j = 1
    start = 1
    last = 10000
    while(j <= 12){
      print(paste('File : ',j))
      if(last > 119748)
        last = 119748
      SBM_data = read.csv(file=paste('~/MLSP/Test/SBM_Test_',j,'.csv',sep = ""))
      FNC_data = read.csv(file=paste('~/MLSP/Test/FNC_Test_',j,'.csv',sep = ""))
      test_data = merge(FNC_data, SBM_data, by = "Id")
      
      p = predict(model, newdata = test_data[,2:411], type = "prob")
      submission_example$Probability[start:last] = p$SCZ
      start = last + 1
      last = last + 10000
      j = j + 1
    }
  }
  write.csv(submission_example, file = paste('~/MLSP/results/',model_info$model[i],'.csv',sep = ""), row.names = FALSE)
  i = i + 1
}
