library(dplyr)

load(file = "Data_Score_by_Time_and_Rating.rda")

# head(score_by_time_and_rating)

load("grouped_housing.rda")
#head(grouped_housing)


summary(score_by_time_and_rating$weight)

score_by_time_and_rating$weight_1000 = (score_by_time_and_rating$weight)*1000

summary(score_by_time_and_rating$weight_1000)

score_by_time_and_rating$weight_log = -1*log((score_by_time_and_rating$weight), 10)

summary(score_by_time_and_rating$weight_log)

hist(score_by_time_and_rating$weight_log, 50)


# library(Amelia)
# library(pROC)
# library("e1071")
# library(stringi)
# library(lubridate)
# library(caret)
# 
# missmap(grouped_housing)
# missmap(score_by_time_and_rating)


new_housing <- grouped_housing %>% 
    rename(
         month = sale_month,
    )

head(new_housing)
head(score_by_time_and_rating)

class(score_by_time_and_rating$month)
class(new_housing$month)

class(new_housing$month)

# df$ddate <- format(as.Date(df$ddate), "%d/%m/%Y")
# as.Date(strDates, "%m/%d/%Y")

# merged_housing_crime <- merge(new_housing, score_by_time_and_rating, 
#                             c("month", "zip_code") )
# 
# # merge(observations, animals, c("size","type"))
# 
# summary(merged_housing_crime)



















