library(caret)
library(e1071)
library("caretEnsemble")
#library(caTools)

labels_train = read.csv(file='train_labels_ori.csv')
labels_train$Class = factor(labels_train$Class,labels=c('HC','SCZ'))

FNC_train = read.csv(file='train_FNC_ori.csv')
SBM_train = read.csv(file='train_SBM_ori.csv')
both_train = merge(FNC_train, SBM_train, by="Id")

submission_example <- read.csv("submission_example.csv")

trC = trainControl(classProbs = TRUE, method = 'cv', number = 23, verboseIter = TRUE)

model_list <- caretList(
  labels_train$Class~., data=both_train[, 2:411],
  trControl=trC,
  methodList=c("gpls", "nb")
)

glm_ensemble <- caretStack(
  model_list,
  method="glm",
  metric="ROC",
  trControl=trainControl(
    method="boot",
    number=10,
    savePredictions="final",
    classProbs=TRUE,
    summaryFunction=twoClassSummary
  )
)

j = 1
start = 1
last = 10000
while(j <= 12){
  print(paste('File : ',j))
  if(last > 119748)
    last = 119748
  SBM_data = read.csv(file=paste('Kaggle/SBM_Test_',j,'.csv',sep = ""))
  FNC_data = read.csv(file=paste('Kaggle/FNC_Test_',j,'.csv',sep = ""))
  test_data = merge(FNC_data, SBM_data, by = "Id")
  
  # ntest <- test_data[ ,as.character(new_feat$featureName)]
  
  p = predict(glm_ensemble, newdata = test_data[,3:413], type = "prob")
  submission_example$Probability[start:last] = p
  start = last + 1
  last = last + 10000
  j = j + 1
}

# colAUC(glm_ensemble, submission_example$Probability)


write.csv(submission_example, file = 'stack_gpls_nb.csv', row.names = FALSE)
