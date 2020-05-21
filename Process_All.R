# Setting working directory to the current directory
# Source: https://stackoverflow.com/questions/13672720/r-command-for-setting-working-directory-to-source-file-location-in-rstudio
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# Run separate processing scripts ...

# 1. Import df_crime and nyc_tracts [BOTH should be fresh versions (just after import_all run)]
load(file = "Data_Crime.rda")
load(file = "Data_NYC_Tracts.rda")

# 2. Crime_Rating
source("Process_Scripts/Crime_Rating.R", echo = TRUE)

# 3. Census_Coords_to_Zipcode
source("Process_Scripts/Census_Coords_to_Zipcode.R", echo = TRUE)

# 4. Crime_Coords_to_Zipcode
source("Process_Scripts/Crime_Coords_to_Zipcode.R", echo = TRUE)


### Parsing the month and rating data

# * The data needs to be reloaded in this way or some weird errors occur
# Restart R if you get any errors wih this last part and just run this code
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

# Dividing sum by the total population
score_by_time_and_rating$weight <- score_by_time_and_rating$sum_weight / score_by_time_and_rating$TotalPop

# Dipslaying the head
head(score_by_time_and_rating)

save(score_by_time_and_rating, file = "Data_Score_by_Time_and_Rating.rda")
