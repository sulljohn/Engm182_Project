# Load packages
library(dplyr)
library(RcppArmadillo)
library(lubridate)

#Regress sale price with sale year, land area, gross area, tax class, building class, year built
load(file = "Data_sale_census_crime.rda")

summary(df_sale_census_crime)

# Make sure sale prices are numeric
df_sale_census_crime$sale_price <- as.numeric(df_sale_census_crime$sale_price)

# Remove large house sale prices; source: https://stackoverflow.com/questions/25764810/delete-rows-based-on-range-of-values-in-column
df_sale_census_crime <- df_sale_census_crime[with(df_sale_census_crime, sale_price <= 1000000), ]

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
# RMS = 
rms = sqrt(mean(results$diff_squared))
rms

# RMS Error = 
rms_error = rms/mean(results$y_test)
rms_error