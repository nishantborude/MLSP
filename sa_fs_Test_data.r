library(caret)
library(e1071)

labels_train = read.csv(file='~/MLSP/Train/train_labels.csv')
labels_train$Class = factor(labels_train$Class,labels=c('HC','SCZ'))

train_data = read.csv(file='~/MLSP/Train/sa_fs_train.csv')

data_both = read.csv(file='~/MLSP/Test/test_both.csv')
data_SBM = read.csv(file='~/MLSP/Test/test_SBM.csv')

cols = read.csv('~/MLSP/sa_fs_list.csv')

data = data.frame(Id = data_both$Id)

limit = dim(cols)[1]
i = 1
while(i <= limit - 5){
  data = cbind(data, data_both[temp[i]])
  i = i + 1
}
i = limit - 4
while(i <= limit){
  data = cbind(data, data_SBM[temp[i]])
  i = i + 1
}
write.csv(data,"~/MLSP/Test/sa_fs_Test.csv", row.names = FALSE)
