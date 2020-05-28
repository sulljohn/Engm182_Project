### Parsing the month and rating data

library(lubridate)
library(dplyr)
#remove(list = ls())
load(file = "Data_Crime_w_Zipcodes.rda")
load(file = "Data_Zip_Population.rda")

# Group by month and rating; source: https://stackoverflow.com/questions/33221425/how-do-i-group-my-date-variable-into-month-year-in-r
score_by_time_and_rating <- df_crime %>% group_by(month=floor_date(CMPLNT_FR_DT, "month"), zip_code)  %>% summarize(summary_variable=sum(weight))

# Summing the scores
names(score_by_time_and_rating)[names(score_by_time_and_rating) == 'summary_variable'] <- 'sum_weight'

# Joining the zipcodes
score_by_time_and_rating <- left_join(score_by_time_and_rating, zip_population, by="zip_code")

# Dividing sum by the total population (at 2015 census levels)
score_by_time_and_rating$weight <- score_by_time_and_rating$sum_weight / score_by_time_and_rating$TotalPop

# Dipslaying the head
head(score_by_time_and_rating)

save(score_by_time_and_rating, file = "Data_Score_by_Time_and_Rating.rda")

#Group by year and rating (This is for the regression model for house sales)
score_by_zip_and_year <- df_crime %>% group_by(year=floor_date(CMPLNT_FR_DT, "year"), zip_code)  %>% summarize(summary_variable=sum(weight))

#Summing the scores
names(score_by_zip_and_year)[names(score_by_zip_and_year) == 'summary_variable'] <- 'sum_weight'

#Extracting the year
score_by_zip_and_year$year <- year(score_by_zip_and_year$year)
score_by_zip_and_year <- subset(score_by_zip_and_year, select = c(year,zip_code,sum_weight))

# Joining the zipcodes with populations
score_by_zip_and_year <- left_join(score_by_zip_and_year, zip_population, by="zip_code")
score_by_zip_and_year <- subset(score_by_zip_and_year, select = c(year,zip_code,sum_weight, TotalPop))

# Dividing sum by the total population (at 2015 census levels)
score_by_zip_and_year$weight <- score_by_zip_and_year$sum_weight / score_by_zip_and_year$TotalPop

#Taking data only for years 2001 and above 
score_by_zip_and_year <- subset(score_by_zip_and_year, year > 2000)
score_by_zip_and_year <- subset(score_by_zip_and_year, select = c(zip_code, year, sum_weight, weight, TotalPop))

save(score_by_zip_and_year, file = "Data_Score_by_year_and_zipcode.rda")