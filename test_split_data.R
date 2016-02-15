library(caret)

FNC_test = read.csv(file='~/MLSP/Test/test_FNC.csv',head=TRUE,sep=",")
SBM_test = read.csv(file='~/MLSP/Test/test_SBM.csv',head=TRUE,sep=",")

stest = 1
etest = 10000
i = 1

while(stest <= 119748) {
  if(etest > 119748){
    etest = 119748
  }
  write.csv(SBM_test[stest:etest,], file = paste('~/MLSP/Test/SBM_test_',i,'.csv', sep = ""))
  write.csv(FNC_test[stest:etest,], file = paste('~/MLSP/Test/FNC_test_',i,'.csv', sep = ""))
  i = i + 1
  stest = etest + 1
  etest = etest + 10000
}
