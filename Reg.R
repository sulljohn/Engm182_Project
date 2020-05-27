# Load packages
library(dplyr)
library(RcppArmadillo)
library(lubridate)

#Regress sale price with sale year, land area, gross area, tax class, building class, year built
load(file = "Data_sale_census_crime.rda")

summary(df_sale_census_crime)

# Remove large house sale prices before regressions; source: https://stackoverflow.com/questions/25764810/delete-rows-based-on-range-of-values-in-column
# TODO: maybe dodn't need this? maybe put in other ranges?
# df_sale_census_crime$sale_price <- as.numeric(df_sale_census_crime$sale_price)
# df_sale_census_crime <- df_sale_census_crime[with(df_sale_census_crime, sale_price <= 1000000), ]

# Run some regressions and see what variables help the most (does crime help?)
# You may have to do this before running the regressions:
# https://stackoverflow.com/questions/51295402/r-on-macos-error-vector-memory-exhausted-limit-reached

#Regression 1
x <- df_sale_census_crime %>% select("land_square_feet", "PerCapitaIncome", "Unemployed", "TotalPop.x", "Men", "Women")
x$land_square_feet <- as.numeric(x[[1]])
x$PerCapitaIncome <- as.numeric(x[[2]])
x$Unemployed <- as.numeric(x[[3]])
x$TotalPop.x <- as.numeric(x[[4]])
x$Men <- as.numeric(x[[5]])
x$Women <- as.numeric(x[[6]])

# Setting up factor variable
df_sale_census_crime$sale_year <- as.character(df_sale_census_crime$sale_year)
df_sale_census_crime$year_built <- as.character(df_sale_census_crime$year_built)

building_class <- model.matrix( ~ building_class_at_time_of_sale - 1, data=df_sale_census_crime )
sale_year <- model.matrix( ~ sale_year - 1, data=df_sale_census_crime )
year_built <- model.matrix( ~ year_built - 1, data=df_sale_census_crime )

# Binding factor variables
x<-cbind(x, building_class)
x<-cbind(x, sale_year)
x<-cbind(x, year_built)

# Add intercept column and renaming
x<-cbind(x, 1)
colnames(x)[dim(x)[2]] <- "Intercept" # Source: https://www.dummies.com/programming/r/how-to-name-matrix-rows-and-columns-in-r/

# Setup the y output variable
y <- df_sale_census_crime %>% select("sale_price")
y <- as.numeric(y[[1]])

# ----- Split data into training and validation sets ----- 
# create a list of 80% of the rows in the original dataset we can use for training
validation_index <- sort(sample(nrow(x), nrow(x)*.8))
# select 20% of the data for validation
x_test <- x[-validation_index,]
y_test <- y[-validation_index]
# use the remaining 80% of data to training and testing the models
x_train <- x[validation_index,]
y_train <- y[validation_index]

# Display the classes if you want
# sapply(x, class)
# sapply(y, class)

# Run regression
fit1 <- fastLm(x_train, y_train)
summary(fit1)
#R-squared value is 25.63%

# Perform predictions on test set
reg_pred1 <- predict(fit1, as.matrix(x_test))

# See the comparison
results <- data.frame(cbind(y_test, reg_pred1))
results$diff <- results$reg_pred1 - results$y_test
results$diff_squared <- '^' (results$diff, 2)
rms <- sqrt(mean(results$diff_squared))
rms_error <- rms/mean(results$y_test)
#RMS error is 43.73%
# TODO: run regressions using different x variables

#Regression 2
x2 <- df_sale_census_crime %>% select("land_square_feet", "gross_square_feet", "PerCapitaIncome", "Unemployed")
x2$land_square_feet <- as.numeric(x2[[1]])
x2$gross_square_feet <- as.numeric(x2[[2]])
x2$PerCapitaIncome <- as.numeric(x2[[3]])
x2$Unemployed <- as.numeric(x2[[4]])

#Setting up factor variable for tax class
df_sale_census_crime$tax_class_at_time_of_sale <- as.character(df_sale_census_crime$tax_class_at_time_of_sale)
tax_class <- model.matrix( ~ tax_class_at_time_of_sale - 1, data=df_sale_census_crime )

#Binding factor variables
x2<-cbind(x2, building_class)
x2<-cbind(x2, sale_year)
x2<-cbind(x2, year_built)
x2<-cbind(x2, tax_class)

# Add intercept column and renaming
x2<-cbind(x2, 1)
colnames(x2)[dim(x2)[2]] <- "Intercept" # Source: https://www.dummies.com/programming/r/how-to-name-matrix-rows-and-columns-in-r/

#x2 <- x2[!is.na(df$sale_price), ]
# ----- Split data into training and validation sets ----- 
# create a list of 80% of the rows in the original dataset we can use for training
validation_index <- sort(sample(nrow(x2), nrow(x2)*.8))
x2_test <- x2[-validation_index,]
y2_test <- y[-validation_index]
x2_train <- x2[validation_index,]
y2_train <- y[validation_index]

# Run regression
fit2 <- fastLm(x_train, y2_train)
summary(fit2)
#R-squared value is 14.19%

# Perform predictions on test set
reg_pred2 <- predict(fit2, as.matrix(x2_test))

# See the comparison
results2 <- data.frame(cbind(y2_test, reg_pred2))
results2$diff <- results2$reg_pred2 - results2$y_test
results$diff_squared <- '^' (results$diff, 2)
rms <- sqrt(mean(results$diff_squared))
rms_error <- rms/mean(results$y_test)
#RMS error is 43.73%
