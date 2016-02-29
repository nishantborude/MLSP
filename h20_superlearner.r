library(h2oEnsemble)  # This will load the `h2o` R package as well
h2o.init(nthreads = -1)  # Start an H2O cluster with nthreads = num cores on your machine
h2o.removeAll() # Clean slate - just in case the cluster was already running

labels_train = read.csv(file='~/MLSP/Train/train_labels.csv')
labels_train$Class = factor(labels_train$Class,labels=c('HC','SCZ'))

class = h2o.importFile(path = normalizePath("~/MLSP/Train/train_labels.csv"))
  
submission_example <- read.csv("~/MLSP/submission_example.csv")

SBM_train <- h2o.importFile(path = normalizePath("~/MLSP/Train/train_SBM.csv"))
FNC_train <- h2o.importFile(path = normalizePath("~/MLSP/Train/train_FNC.csv"))
both_train1 = h2o.merge(FNC_train, SBM_train)
both_train = h2o.merge(class, both_train1)

SBM_test <- h2o.importFile(path = normalizePath("~/MLSP/Test/test_SBM.csv"))
FNC_test <- h2o.importFile(path = normalizePath("~/MLSP/Test/test_both.csv"))
both_test = h2o.merge(FNC_test[,1:379], SBM_test)

rm(SBM_test, FNC_test, SBM_train, FNC_train, both_train1)
gc()

y <- c("Id", "Class")
x <- setdiff(names(both_train), y)

 learner <- c("h2o.glm.wrapper", "h2o.randomForest.wrapper",
              "h2o.gbm.wrapper", "h2o.deeplearning.wrapper")
metalearner <- "h2o.glm.wrapper"

fit <- h2o.ensemble(x = x, y = "Class", 
                    training_frame = both_train[,2:412], 
                    family = "gaussian", 
                    learner = learner, 
                    metalearner = metalearner,
                    cvControl = list(V = 5))

pred <- predict(fit, both_test[,2:411])
p = as.data.frame(pred$pred)
submission_example$Probability = p$predict
write.csv(submission_example, file = '~/MLSP/results/super_learn_mod.csv', row.names = FALSE)
