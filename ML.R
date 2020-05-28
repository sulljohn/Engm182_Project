# Original script from class: Machine Learning with R
# This script was adapted in part from https://machinelearningmastery.com/machine-learning-in-r-step-by-step/
# Original Author: [Jason Brownlee](https://machinelearningmastery.com/)

#Attach packages
library(caret)
library(dplyr)
library(lubridate)
library(deepnet)

# CONTINUED FROM HALFWAY THROUGH THE REG.R FILE

#Regress sale price with sale year, land area, gross area, tax class, building class, year built
load(file = "Data_sale_census_crime.rda")

#Remove values of 0
#source: https://stackoverflow.com/questions/9977686/how-to-remove-rows-with-any-zero-value
zero_rows = apply(df_sale_census_crime, 1, function(row) all(row != 0))
df_sale_census_crime <- df_sale_census_crime[zero_rows, ]

# Make sure sale prices are numeric
df_sale_census_crime$sale_price <- as.numeric(df_sale_census_crime$sale_price)

# Remove large house sale prices; source: https://stackoverflow.com/questions/25764810/delete-rows-based-on-range-of-values-in-column
df_sale_census_crime <- df_sale_census_crime[with(df_sale_census_crime, sale_price <= 5000000), ]


# Run some regressions and see what variables help the most (does crime help?)
# You may have to do this before running the regressions:
# https://stackoverflow.com/questions/51295402/r-on-macos-error-vector-memory-exhausted-limit-reached



#Adding a column about age of building 
df_sale_census_crime$age <- df_sale_census_crime$sale_year - df_sale_census_crime$year_built
#Remove negative age values
df_sale_census_crime <- df_sale_census_crime[age>0, ]


#Remove values of 0
#source: https://stackoverflow.com/questions/9977686/how-to-remove-rows-with-any-zero-value
zero_rows = apply(df_sale_census_crime, 1, function(row) all(row != 0))
df_sale_census_crime <- df_sale_census_crime[zero_rows, ]

# Remove large house sale prices; source: https://stackoverflow.com/questions/25764810/delete-rows-based-on-range-of-values-in-column
# TODO: maybe dodn't need this? maybe put in other ranges?


# Make sure salel price is numeric
df_sale_census_crime$sale_price <- as.numeric(df_sale_census_crime$sale_price)

# Run some regressions and see what variables help the most (does crime help?)
# You may have to do this before running the regressions:
# https://stackoverflow.com/questions/51295402/r-on-macos-error-vector-memory-exhausted-limit-reached

#For now just using 1% of the data
setup_stage <- sort(sample(nrow(df_sale_census_crime), nrow(df_sale_census_crime)*.01))
setup_stage2 <- sort(sample(nrow(df_sale_census_crime), nrow(df_sale_census_crime)))
df_sale_census_crime <- df_sale_census_crime[setup_stage] #Use either setup_stage or setup_stage2 accordingly
#Doing this here as when done after splitting, number of values in x and y become different
df_sale_census_crime$gross_square_feet <- as.numeric(df_sale_census_crime$gross_square_feet)
sapply(df_sale_census_crime, class)
df_sale_census_crime <- na.omit(df_sale_census_crime)
any(is.na(df_sale_census_crime))

# ----- Split data into training and validation sets ----- 
summary(df_sale_census_crime)
# select sales from 2003 to 2013 for validation and >2013 for testing
df_sale_census_crime_test <- df_sale_census_crime[sale_year > 2013,]
# use data from 2003 to 2013 as training data
df_sale_census_crime_train <- df_sale_census_crime[sale_year <= 2013,]

# Data setup

# Setup the y output variable
y <- df_sale_census_crime_train %>% select("sale_price")
y <- as.numeric(y[[1]]) # Making sure it's numeric
y_test <- df_sale_census_crime_test %>% select("sale_price")

# Setup the input variable
x <- df_sale_census_crime_train %>% select("gross_square_feet","PerCapitaIncome", "Unemployed", "TotalPop.x", "Hispanic", "White", "Black", "Native", "Asian", "age", "weight", "sale_year")
x_test <- df_sale_census_crime_test %>% select("gross_square_feet","PerCapitaIncome", "Unemployed", "TotalPop.x", "Hispanic", "White", "Black", "Native", "Asian", "age", "weight", "sale_year")
# NEED to make sure each column is the right format (numeric / factor as appropriate)

# BEFORE
sapply(x, class)

x$gross_square_feet <- as.numeric(x$gross_square_feet)
x$sale_year <- as.numeric(x$sale_year)

# AFTER (CHECK that these all make sense)
sapply(x, class)

#Same for x_test
sapply(x_test, class)
x_test$sale_year <- as.numeric(x_test$sale_year)
any(is.na(x_test))

# If want to select all but one
#  <- select(df_sale_census_crime, -one_of("sale_price"))

# If want to do PCA separate from doing it in the models (take PCA out of models if do this:
# Principle component analysis (PCA)
# preProcValues <- preProcess(x_train1, method = "pca",pcaComp=2)

# x_train <- predict(preProcValues, x_train1)
# x_test <- predict(preProcValues, x_test1)



# See models that are possible to use: https://topepo.github.io/caret/available-models.html

# Run algorithms using 5-fold cross validation
# We do this becuase the following article says that 5 is a good value to use from empirical evidence:
# Source: https://machinelearningmastery.com/k-fold-cross-validation/
control <- trainControl(method="cv", number=10)
metric <- "RMSE"

# PCA does PCA preprocessing before running the models; helps it go faster
set.seed(7)
fit.nnet <- train(x, y, method="nnet", metric=metric, trControl=control, linout=TRUE, preProcess="pca") # Need linout TRUE: https://stackoverflow.com/questions/21622975/how-to-model-a-neural-network-through-the-use-of-caret-r

# Deep Neural Net
set.seed(7)
fit.dnn <- train(x, y, output="linear", metric=metric, trControl=control, linout=TRUE, preProcess="pca") # Need linout TRUE: https://stackoverflow.com/questions/21622975/how-to-model-a-neural-network-through-the-use-of-caret-r

# Random Forest
set.seed(7)
fit.rf <- train(x, y, method="rf", metric=metric, trControl=control, preProcess="pca")

#Trees using genetic algorithm- This is taking extremely long amounts of time so aborting this model
#set.seed(7)   
#fit.ga <- train(x, y, method="evtree", metric=metric, trControl=control, preProcess="pca")

#Adaptive- Network based fuzzy inference system-This is taking extremely long amounts of time so aborting this model
#install.packages("frbs")
#library(frbs)
#set.seed(7)   
#fit.anfis <- train(x, y, method="ANFIS", metric=metric, trControl=control, preProcess="pca")

#Bagged CART
set.seed(7)   
fit.bgcrt <- train(x, y, method="treebag", metric=metric, trControl=control, preProcess="pca")

#KNN
set.seed(7)   
fit.knn <- train(x, y, method="knn", metric=metric, trControl=control, preProcess="pca")

# summarize RMSE of models
results <- resamples(list(nnet=fit.nnet, dnn=fit.dnn, rf=fit.rf, cart=fit.bgcrt, knn=fit.knn))
summary(results)

# compare RMSE of models
dotplot(results)

# Summarize the BEST Model
print(fit.rf)

# compare the predictions
nnet_pred <- predict(fit.nnet, x_test) 
dnn_pred <- predict(fit.dnn, x_test)
rf_pred <- predict(fit.rf, x_test)
bgcrt_pred <- predict(fit.bgcrt, x_test)
knn_pred <- predict(fit.knn, x_test)

results3 <- data.frame(cbind(y_test, nnet_pred, dnn_pred, rf_pred, bgcrt_pred, knn_pred))
#RMSE on test data for each model
#Calculating diff from actual values
results3$diff_nnet <- abs(results3$sale_price - results3$nnet_pred)
results3$diff_dnn <- abs(results3$sale_price - results3$dnn_pred)
results3$diff_rf <- abs(results3$sale_price - results3$rf_pred)
results3$diff_bgcrt <- abs(results3$sale_price - results3$bgcrt_pred)
results3$diff_knn <- abs(results3$sale_price - results3$knn_pred)

#Calculating RMSE
RMSE_nnet <- sqrt(mean('^'(results3$diff_nnet,2))) #705,330
RMSE_dnn <- sqrt(mean('^'(results3$diff_dnn,2))) #697,094
RMSE_rf <- sqrt(mean('^'(results3$diff_rf,2))) #689,789
RMSE_bgcrt <- sqrt(mean('^'(results3$diff_bgcrt,2))) #634,809
RMSE_knn <- sqrt(mean('^'(results3$diff_knn,2))) #641,702

#Calculating MAE
MAE_nnet <- mean(results3$diff_nnet) #401,590
MAE_dnn <- mean(results3$diff_dnn) #466,828
MAE_rf <- mean(results3$diff_rf) #462,907
MAE_bgcrt <- mean(results3$diff_bgcrt) #401,397
MAE_knn <- mean(results3$diff_knn) #363,609

mean(results3$sale_price)

#Calculating %error (RMSE/Average price)
error_nnet <- RMSE_nnet/mean(results3$sale_price) 
error_dnn <- RMSE_dnn/mean(results3$sale_price) 
error_rf <- RMSE_rf/mean(results3$sale_price) 
error_bgcrt <- RMSE_bgcrt/mean(results3$sale_price) 
error_knn <- RMSE_knn/mean(results3$sale_price) 

#Calculating %error (MAE/Average price)
error2_nnet <- MAE_nnet/mean(results3$sale_price) 
error2_dnn <- MAE_dnn/mean(results3$sale_price) 
error2_rf <- MAE_rf/mean(results3$sale_price) 
error2_bgcrt <- MAE_bgcrt/mean(results3$sale_price) 
error2_knn <- MAE_knn/mean(results3$sale_price) 

#Saving random forest model
save(fit.rf, file = "random_forest.rda")








