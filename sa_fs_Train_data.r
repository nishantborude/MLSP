library(caret)
library(e1071)

labels_train = read.csv(file='~/MLSP/Train/train_labels.csv')
labels_train$Class = factor(labels_train$Class,labels=c('HC','SCZ'))

FNC_train = read.csv(file='~/MLSP/Train/train_FNC.csv')
SBM_train = read.csv(file='~/MLSP/Train/train_SBM.csv')

train_both = merge(FNC_train, SBM_train, by = 'Id')

ctrl <- safsControl(functions = caretSA, method = "cv", number = 10, verbose = TRUE)
obj <- safs(x = train_both[,2:411],
            y = labels_train$Class,
            iters = 100,
            safsControl = ctrl,
            ## Now pass options to `train`
            method = "gpls")

temp = obj$optVariables




data = data.frame(Id = train_both$Id)
i = 1
while(i <= length(temp)){
  data = cbind(data, train_both[temp[i]])
  i = i + 1
}

feature_list = data.frame(temp)
names(feature_list) = c("Features")

write.csv(data,"~/MLSP/Train/sa_fs_Train.csv", row.names = FALSE)
