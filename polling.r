library("caret")
library("e1071")
library("caretEnsemble")

labels_train = read.csv(file='~/MLSP/Train/train_labels.csv')
labels_train$Class = factor(labels_train$Class,labels=c('HC','SCZ'))

submission_example <- read.csv("~/MLSP/submission_example.csv")

SBM_train = read.csv(file='~/MLSP/Train/train_SBM.csv')
FNC_train = read.csv(file='~/MLSP/Train/train_FNC.csv')
both_train = merge(FNC_train, SBM_train, by="Id")

FNC_test = read.csv(file='~/MLSP/Test/test_both.csv',head=TRUE,sep=",")[,1:379]
SBM_test = read.csv(file='~/MLSP/Test/test_SBM.csv',head=TRUE,sep=",")
both_test = merge(FNC_test, SBM_test, by="Id")

rm(FNC_test, SBM_test, FNC_train, SBM_train)
gc()

trControl <- trainControl(
  method="cv",
  number=23,
  savePredictions="final",
  classProbs=TRUE,
  verboseIter = TRUE,
  index=createResample(labels_train$Class, 23),
  summaryFunction=twoClassSummary
)

trControl_dwd <- trainControl(
  method="cv",
  classProbs=TRUE,
  verboseIter = TRUE,
  number = 10
)

model_list <- caretList(
  labels_train$Class~., data=both_train[,2:411],
  trControl=trControl,
  methodList=c("gpls", "nb")
)

caret_ensemble <- caretEnsemble(
  model_list, 
  metric="ROC",
  trControl=trainControl(
    number=23,
    summaryFunction=twoClassSummary,
    classProbs=TRUE
  ))

gc()

model_lda = train(labels_train$Class ~ ., data = both_train[,2:411], 
                  method = 'lda', 
                  trControl = trControl)

model_dwdPoly = train(labels_train$Class ~ ., data = both_train[,2:411], 
                      method = 'dwdPoly', 
                      trControl = trControl_dwd)

gc()

model_wsrf = train(labels_train$Class ~ ., data = both_train[,2:411], 
                   method = 'wsrf', 
                   trControl = trControl)

model_nnet = train(labels_train$Class ~ ., data = both_train[,2:411], 
                   method = 'nnet', 
                   trControl = trControl)

gc()

i = 1
k = 1
#model_all = c(model_nnet, model_wsrf, model_dwdPoly, model_lda)
while(i <= 119748){
  if(i %% 120 == 0){
    print(k)
    k = k + 1
  }
  
  HC_total = 0
  HC_count = 0
  SZ_total = 0
  SZ_count = 0
  p <- predict(caret_ensemble, newdata=both_test[i,2:411], type="prob")
  if(p < 0.5){
    HC_count = HC_count + 1
    HC_total = HC_total + p
  }else{
    SZ_count = SZ_count + 1
    SZ_total = SZ_total + p
  }
  p <- predict(model_lda, newdata=both_test[i,2:411], type="prob")
  if(p$SCZ < 0.5){
    HC_count = HC_count + 1
    HC_total = HC_total + p$SCZ
  }else{
    SZ_count = SZ_count + 1
    SZ_total = SZ_total + p$SCZ
  }
  p <- predict(model_nnet, newdata=both_test[i,2:411], type="prob")
  if(p$SCZ < 0.5){
    HC_count = HC_count + 1
    HC_total = HC_total + p$SCZ
  }else{
    SZ_count = SZ_count + 1
    SZ_total = SZ_total + p$SCZ
  }
  p <- predict(model_wsrf, newdata=both_test[i,2:411], type="prob")
  if(p$SCZ < 0.5){
    HC_count = HC_count + 1
    HC_total = HC_total + p$SCZ
  }else{
    SZ_count = SZ_count + 1
    SZ_total = SZ_total + p$SCZ
  }
  p <- predict(model_dwdPoly, newdata=both_test[i,2:411], type="prob")
  if(p$SCZ < 0.5){
    HC_count = HC_count + 1
    HC_total = HC_total + p$SCZ
  }else{
    SZ_count = SZ_count + 1
    SZ_total = SZ_total + p$SCZ
  }
  if(as.numeric(HC_count) < as.numeric(SZ_count)){
    submission_example$Probability[i] = as.numeric( SZ_total / SZ_count)
  }else{
    submission_example$Probability[i] = as.numeric(HC_total / HC_count) 
  }
  i = i + 1
}

write.csv(submission_example, file = '~/MLSP/results/polling.csv', row.names = FALSE)
