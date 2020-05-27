load(file="Data_Housing.rda")
load(file="Data_Zip_Population.rda")

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

#Remove values of 0
#source: https://stackoverflow.com/questions/9977686/how-to-remove-rows-with-any-zero-value
zero_rows = apply(df_sale_census_crime, 1, function(row) all(row != 0))
df_sale_census_crime <- df_sale_census_crime[zero_rows, ]

save(df_sale_census_crime, file = "Data_sale_census_crime.rda")