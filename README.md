# MLSP

Start by dividing test data into 12 files, each containing 10,000 rows. Run test_split_data.r by changing the path for reading and writing Test files accordingly. For the given code to run, add MLSP folder to current path i.e. home directory of RStudio. Create a Test folder and paste test_FNC.csv and test_SBM into it. Split files will be created in the Test folder.

kaggle_script.r contains recursive train and test for boot and cv methods for 10 machine learning models.

gpls_85.r contains train and test of dataset using top 85 features for gpls algorithm obtained from varImp for glm method. This method uses first 85 FNC features.

For using Simulated annealing, run sa_fs_Train.r to get list of selected features. And similarly run sa_fs_Test.r for getting the selected features for Test data. sa_fs_gpls.r contains training and testing of data for gpls using features selectes from Simulated Annealing feature selection method. Please find sa_fs_Train.csv in this repository and paste it in the appropriate path. This file contains list of selected features 

For 3rd solution, run fit_dwd_3_pos.r

For 2nd solution, run Kaggle_2_Sub.r. (2nd solution uses doMC which runs exclusively on Linux). To run it on Windows, comment doMC library and comment registerDoMC(cores=3) line from the code.

ensemble_gpls_nb.r uses caretEnsemble package. Run the code by managing the appropriate paths.

We have used caretStack for gpls and nb models using glm method and got same accuracy as caretEnsemble for gpls and nb. To run the file stack_gpls_nb.r, you need to have the test files split initially. Run the code on the split 12 files.

h2o_superlearner.r includes the code for glm, rf, deeplearning and gbm. However, the accuracy reduced using superlearner as it doesn't provide the packages we need like gpls and nb.

We used different approach for solving this problem. We trained different models using ensemble gpls-nb, dwdPoly, nnet, wsrf and lda. We took each test case individually to take the probability separately and then compared probability for every model. We took the count of how many of the probabilities were Healthy_Control and how many were Schizophrenic. Out of 5 predictions, the one which has maximum count, we take an average of it and add this score to the submission_example.csv file.
