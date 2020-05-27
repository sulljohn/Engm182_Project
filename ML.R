# NOTE: this file is not complete

# Machine Learning with R
# This script was adapted in part from https://machinelearningmastery.com/machine-learning-in-r-step-by-step/
# Original Author: [Jason Brownlee](https://machinelearningmastery.com/)

#Attach packages
library(caret)
library(dplyr)
library(lubridate)

# CONTINUED FROM HALFWAY THROUGH THE REG.R FILE

#Regress sale price with sale year, land area, gross area, tax class, building class, year built
load(file = "Data_sale_census_crime.rda")

#Remove values of 0
#source: https://stackoverflow.com/questions/9977686/how-to-remove-rows-with-any-zero-value
zero_rows = apply(df_sale_census_crime, 1, function(row) all(row != 0))
df_sale_census_crime <- df_sale_census_crime[zero_rows, ]

# Remove large house sale prices; source: https://stackoverflow.com/questions/25764810/delete-rows-based-on-range-of-values-in-column
# TODO: maybe dodn't need this? maybe put in other ranges?
df_sale_census_crime$sale_price <- as.numeric(df_sale_census_crime$sale_price)

# Run some regressions and see what variables help the most (does crime help?)
# You may have to do this before running the regressions:
# https://stackoverflow.com/questions/51295402/r-on-macos-error-vector-memory-exhausted-limit-reached

### RUNNING REGRESSIONS HERE

#Remove values of 0
#source: https://stackoverflow.com/questions/9977686/how-to-remove-rows-with-any-zero-value
zero_rows = apply(df_sale_census_crime, 1, function(row) all(row != 0))
df_sale_census_crime <- df_sale_census_crime[zero_rows, ]

# Remove large house sale prices; source: https://stackoverflow.com/questions/25764810/delete-rows-based-on-range-of-values-in-column
# TODO: maybe dodn't need this? maybe put in other ranges?
df_sale_census_crime$sale_price <- as.numeric(df_sale_census_crime$sale_price)

# Run some regressions and see what variables help the most (does crime help?)
# You may have to do this before running the regressions:
# https://stackoverflow.com/questions/51295402/r-on-macos-error-vector-memory-exhausted-limit-reached

# Data setup
x <- df_sale_census_crime %>% select("land_square_feet", "PerCapitaIncome", "Unemployed", "TotalPop.x", "Men", "Women")
x$land_square_feet <- as.numeric(x[[1]])
x$PerCapitaIncome <- as.numeric(x[[2]])
x$Unemployed <- as.numeric(x[[3]])
x$TotalPop.x <- as.numeric(x[[4]])
x$Men <- as.numeric(x[[5]])
x$Women <- as.numeric(x[[6]])

# Setup the y output variable
y <- df_sale_census_crime %>% select("sale_price")
y <- as.numeric(y[[1]]) # Making sure it's numeric

# ----- Split data into training and validation sets ----- 
# create a list of 80% of the rows in the original dataset we can use for training
validation_index <- sort(sample(nrow(x), nrow(x)*.01))
# select 20% of the data for validation
x_test <- x[-validation_index,]
y_test <- y[-validation_index]
# use the remaining 80% of data to training and testing the models
x_train <- x[validation_index,]
y_train <- y[validation_index]

# See models: https://topepo.github.io/caret/available-models.html

# Run algorithms using 5-fold cross validation
control <- trainControl(method="cv", number=5)
metric <- "RMSE"

set.seed(7)
fit.nnet <- train(x_train, y_train, method="nnet", metric=metric, trControl=control, linout=TRUE) # Need linout TRUE: https://stackoverflow.com/questions/21622975/how-to-model-a-neural-network-through-the-use-of-caret-r
# Random Forest
set.seed(7)
fit.rf <- train(x_train, y_train, method="rf", metric=metric, trControl=control)

# summarize RMSE of models
results <- resamples(list(nnet=fit.nnet, rf=fit.rf))
summary(results)

# compare RMSE of models
dotplot(results)

# summarize accuracy of models
results2 <- resamples(list(fit.nnet, fit.rf))
summary(results2)

# compare accuracy of models
dotplot(results2)

# summarize Best Model
print(fit.rf)

# compare the predictions
rf_pred <- predict(fit.rf, x_test)
nnet_pred <- predict(fit.nnet, x_test) 

results3 <- data.frame(cbind(y_test, rf_pred, nnet_pred))
