# NOTE: this file is not complete

# Machine Learning with R
# This script was adapted in part from https://machinelearningmastery.com/machine-learning-in-r-step-by-step/
# Original Author: [Jason Brownlee](https://machinelearningmastery.com/)

#Attach packages
library(caret)

# ----- Split data into training and validation sets ----- 
# create a list of 80% of the rows in the original dataset we can use for training
validation_index <- sort(sample(nrow(df_housing), nrow(df_housing)*.8))
# select 20% of the data for validation
df_valid <- df_housing[-validation_index,]
# use the remaining 80% of data to training and testing the models
df <- df_housing[validation_index,]

# ----- Lets look at our data ----- 
print("Number of rows in our training dataset:")
dim(df)[1]
print("Number of features in our training dataset:")
dim(df)[2]-1

head(df)

# Examine datatype for each column
sapply(df, class)

# split features and labels
X <- df %>% select("borough", "neighborhood", "tax_class_at_present", "block", "lot", "building_class_at_present", "zip_code", "residential_units", "commercial_units", "total_units", "land_square_feet", "gross_square_feet", "year_built", "tax_class_at_time_of_sale", "building_class_at_time_of_sale")
y <- df %>% select("sale_price")
Xy <- df %>% select("borough", "neighborhood", "tax_class_at_present", "block", "lot", "building_class_at_present", "zip_code", "residential_units", "commercial_units", "total_units", "land_square_feet", "gross_square_feet", "year_built", "tax_class_at_time_of_sale", "building_class_at_time_of_sale", "sale_price")

# Run algorithms using 10-fold cross validation
control <- trainControl(method="cv", number=10)
metric <- "Accuracy"
# Homework 4 - tried adaboost AND AdaBoost.M1
# a) linear algorithms
#HW4
set.seed(7)
fit.neuralnet <- train(sale_price~., data=Xy, method="lda", metric=metric, trControl=control)
# b) nonlinear algorithms
# CART
set.seed(7)
fit.cart <- train(sale_price~., data=df, method="rpart", metric=metric, trControl=control)
# kNN
set.seed(7)
fit.knn <- train(sale_price~., data=df, method="knn", metric=metric, trControl=control)
# c) advanced algorithms
# SVM
set.seed(7)
fit.svm <- train(sale_price~., data=df, method="svmRadial", metric=metric, trControl=control)
# Random Forest
set.seed(7)
fit.rf <- train(sale_price~., data=df, method="rf", metric=metric, trControl=control, )
#HW4
# Adaboost
set.seed(7)
fit.AdaBoost.M1 <- train(sale_price~., data=df, method="knn", metric=metric, trControl=control)

# and its just that easy! 

# summarize accuracy of models
results <- resamples(list(adaboost=fit.adaboost, cart=fit.cart, knn=fit.knn, svm=fit.svm, rf=fit.rf))
summary(results)

# compare accuracy of models
dotplot(results)

# summarize accuracy of models
results2 <- resamples(list(fit.AdaBoost.M1, cart=fit.cart, knn=fit.knn, svm=fit.svm, rf=fit.rf))
summary(results2)

# compare accuracy of models
dotplot(results2)

# summarize Best Model
print(fit.adaboost)

# estimate skill of LDA on the validation dataset
predictions <- predict(fit.adaboost, df_valid) 
confusionMatrix(predictions, df_valid$Species)

#### How well did our model perform? 

#### How many flowers did it classify correctly? 

#### How many flowers did it classify incorrectly? 

#### Can you think of any other ways to improve this model to increase its performance? 
















