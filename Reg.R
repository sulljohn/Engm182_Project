#Start the code from line 46
# Load packages
library(dplyr)
library(RcppArmadillo)
library(lubridate) 

# Only sales prices > 0 for housing data

# Only take > 0; source: https://stackoverflow.com/questions/33535006/remove-rows-if-it-is-negative-number
df <- df_housing[df_housing$land_square_feet > 0, ]
df <- df[df$sale_price > 0, ]

# Get rid of NA values; source: https://stackoverflow.com/questions/48658832/how-to-remove-row-if-it-has-a-na-value-in-one-certain-column/48659101
df <- df[!is.na(df$sale_price), ]
df <- df[!is.na(df$land_square_feet), ]


#Identify the input variables for sales price prediction
#Zipcode (will be used to join census and crime data), land_square_feet, gross_square_feet, year built, tax_class_at_time_of_sale, building_class_at_time_of_sale, sale_date (will be used to link crime rating for that year)
#Subset new dataframe with relevant variables
df_sale <- subset(df, select = c(zip_code,land_square_feet, gross_square_feet, year_built, tax_class_at_time_of_sale, building_class_at_time_of_sale, sale_date, sale_price))
df_sale$sale_year <- year(df_sale$sale_date) 
df_sale$sale_month <- month(df_sale$sale_date)
#If sale is in months 1, 2, 3 then crime score will be taken from previous year else crime score of that year
df_sale$crime_score_year <- ifelse(df_sale$sale_month == 1 | df_sale$sale_month == 2 | df_sale$sale_month == 3, df_sale$sale_year-1, df_sale$sale_year)

#Adding the census data by linking through zipcode
#Taking a subset of df_sale for only the zip codes for which we have census data
zip_codes_inhousing <- unique(df_sale$zip_code)
zip_codes_incensus <- unique(zip_population$zip_code)
zip_codes_inhousing_incensus <- intersect(zip_codes_inhousing, zip_codes_incensus)

#Merging the sales and census data into one dataframe
df_sale$zip_code <- as.character(df_sale$zip_code)
df_sale_census <- merge(df_sale[df_sale$zip_code %in% zip_codes_inhousing_incensus, ], zip_population[zip_population$zip_code %in% zip_codes_inhousing_incensus, ], by = "zip_code")

load(file = "Data_Score_by_year_and_zipcode.rda")
#Adding the crime score data for each year
zip_codes_inhousing_incensus_incrime <- intersect(unique(df_sale_census$zip_code), unique(score_by_zip_and_year$zip_code))
colnames(score_by_zip_and_year) <- c("zip_code", "crime_score_year", "sum_weight", "weight", "TotalPop")
df_sale_census_crime <- merge(df_sale_census[df_sale_census$zip_code %in% zip_codes_inhousing_incensus_incrime, ], score_by_zip_and_year[score_by_zip_and_year$zip_code %in% zip_codes_inhousing_incensus_incrime, ], by = c("zip_code", "crime_score_year"))
df_sale_census_crime <- na.omit(df_sale_census_crime)
#any(is.na(df_sale_census_crime))
save(df_sale_census_crime, file = "Data_sale_census_crime.rda")

#Regress sale price with sale year, land area, gross area, tax class, building class, year built
load(file = "Data_sale_census_crime.rda")

### RUNNING REGRESSIONS HERE

summary(df_sale_census_crime)

#Remove values of 0
#source: https://stackoverflow.com/questions/9977686/how-to-remove-rows-with-any-zero-value
zero_rows = apply(df_sale_census_crime, 1, function(row) all(row != 0))
df_sale_census_crime <- df_sale_census_crime[zero_rows, ]

# Run some regressions and see what variables help the most (does crime help?)
# You may have to do this before running the regressions:
# https://stackoverflow.com/questions/51295402/r-on-macos-error-vector-memory-exhausted-limit-reached

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

# Perform predictions on test set
reg_pred1 <- predict(fit1, as.matrix(x_test))

# See the comparison
results <- data.frame(cbind(y_test, reg_pred1))
results$diff <- results$reg_pred1 - results$y_test

# TODO: run regressions using different x variables
