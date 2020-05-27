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






# Data setup

# Setup the y output variable
y <- df_sale_census_crime %>% select("sale_price")
y <- as.numeric(y[[1]]) # Making sure it's numeric

# Setup the input variable
x <- df_sale_census_crime %>% select("land_square_feet", "PerCapitaIncome", "Unemployed", "TotalPop.x", "Men", "Women")

# NEED to make sure each column is the right format (numeric / factor as appropriate)

# BEFORE
sapply(x, class)

x$land_square_feet <- as.numeric(x$land_square_feet)

# AFTER (CHECK that these all make sense)
sapply(x, class)

# If want to select all but one
#  <- select(df_sale_census_crime, -one_of("sale_price"))

# ----- Split data into training and validation sets ----- 
# create a list of 80% of the rows in the original dataset we can use for training
validation_index <- sort(sample(nrow(x), nrow(x)*.01))
# select 20% of the data for validation
x_test <- x[-validation_index,]
y_test <- y[-validation_index]
# use the remaining 80% of data to training and testing the models
x_train <- x[validation_index,]
y_train <- y[validation_index]



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
fit.nnet <- train(x_train, y_train, method="nnet", metric=metric, trControl=control, linout=TRUE, preProcess="pca") # Need linout TRUE: https://stackoverflow.com/questions/21622975/how-to-model-a-neural-network-through-the-use-of-caret-r

# Deep Neural Net
set.seed(7)
fit.dnn <- train(x_train, y_train, output="linear", metric=metric, trControl=control, linout=TRUE, preProcess="pca") # Need linout TRUE: https://stackoverflow.com/questions/21622975/how-to-model-a-neural-network-through-the-use-of-caret-r

# Random Forest
set.seed(7)
fit.rf <- train(x_train, y_train, method="rf", metric=metric, trControl=control, preProcess="pca")

# summarize RMSE of models
results <- resamples(list(nnet=fit.nnet, dnn=fit.dnn, rf=fit.rf))
summary(results)

# compare RMSE of models
dotplot(results)

# summarize accuracy of models
results2 <- resamples(list(fit.nnet, dnn=fit.dnn, fit.rf))
summary(results2)

# compare accuracy of models
dotplot(results2)

# Summarize the BEST Model
print(fit.rf)

# compare the predictions
nnet_pred <- predict(fit.nnet, x_test) 
dnn_pred <- predict(fit.dnn, x_test)
rf_pred <- predict(fit.rf, x_test)

results3 <- data.frame(cbind(y_test, nnet_pred, dnn_pred, rf_pred))
