library("caret")
library("e1071")
library("caretEnsemble")

labels_train = read.csv(file='~/MLSP/Train/train_labels.csv')
labels_train$Class = factor(labels_train$Class,labels=c('HC','SCZ'))

submission_example <- read.csv("~/MLSP/submission_example.csv")

SBM_train = read.csv(file='~/MLSP/Train/train_SBM.csv')
FNC_train = read.csv(file='~/MLSP/Train/train_FNC.csv')
both_train = merge(FNC_train, SBM_train, by="Id")

trControl <- trainControl(
  method="cv",
  number=23,
  savePredictions="final",
  classProbs=TRUE,
  verboseIter = TRUE,
  index=createResample(labels_train$Class, 23),
  summaryFunction=twoClassSummary
)

model_list <- caretList(
  labels_train$Class~., data=both_train[,2:411],
  trControl=trControl,
  methodList=c("gpls", "nb")
)

xyplot(resamples(model_list))

modelCor(resamples(model_list))

caret_ensemble <- caretEnsemble(
  model_list, 
  metric="ROC",
  trControl=trainControl(
    number=23,
    summaryFunction=twoClassSummary,
    classProbs=TRUE
  ))

summary(caret_ensemble)

FNC_test = read.csv(file='~/MLSP/Test/test_both.csv',head=TRUE,sep=",")[,1:379]
SBM_test = read.csv(file='~/MLSP/Test/test_SBM.csv',head=TRUE,sep=",")
both_test = merge(FNC_test, SBM_test, by="Id")

rm(FNC_test, SBM_test)
gc()


first = 1
last = 500
k = 1
while(first < 119748){
  print(k)
  if(last > 119748)
    last = 119748
  p <- predict(caret_ensemble, newdata=both_test[first:last,2:411], type="prob")
  submission_example$Probability[first:last] = p
  first = last + 1
  last = last + 500
  k = k + 1
}
#p <- predict(caret_ensemble, newdata=both_test[,2:411], type="prob")
#submission_example$Probability = p

write.csv(submission_example, file = '~/MLSP/results/ensemble_gpls_nb.csv', row.names = FALSE)
