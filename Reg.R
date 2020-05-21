# Load packages
library(dplyr)
library(RcppArmadillo)

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

X <- df %>% select("land_square_feet")
X <- as.numeric(X[[1]])
y <- df %>% select("sale_price")
y <- as.numeric(y[[1]])

# Trying it as a matrix, works better ...
X2 <- data.matrix(X)

# Examine datatype for each column
sapply(X, class)
sapply(y, class)


# Reorganizing crime data


## Want type of crime by year and zip code



# Join the crime information with the year the house data sold price





# Join census data as a control series



# Run some regressions and see what variables help the most (does crime help?)
# You may have to do this before running the regressions:
# https://stackoverflow.com/questions/51295402/r-on-macos-error-vector-memory-exhausted-limit-reached

fit <- fastLm(X2, y)
summary(fit)

# Include in report table of findings for the different regressions and the p-values


# Use regression results to make score for each area / zip code over time
# (maybe based this score on the regression coefficients for the regions)



# Plot these on the Shiny map that the othter pair is working on

