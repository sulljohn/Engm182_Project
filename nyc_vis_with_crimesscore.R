library(dplyr)
library(tidyverse)
library(shiny)
library(leaflet)
library(jsonlite)
library(sf)

load(file = "Data_Score_by_Time_and_Rating.rda")

# Remove NAs and outliers
score_by_time_and_rating = score_by_time_and_rating %>%
    filter(!is.na(weight)) %>%
    filter(month > "2006-12-31") %>% # Data reported differntly before 2007 it seems
    filter(!(zip_code == "11430" & month < "2009-01-01")) %>% # Very unusally high scores in this code before this time
    filter(zip_code != "11251") %>% # Super highly variable variable scores in this code
    filter(!(zip_code == "10307" & (month > "2007-07-01" & month  < "2007-10-01"))) # Spike at this time in this code
    

score_by_time_and_rating$weight_normalized = score_by_time_and_rating$weight/max(score_by_time_and_rating$weight)

unique_census = score_by_time_and_rating %>%
    group_by(zip_code) %>%
    summarize(PerCapitaIncome = PerCapitaIncome[1], Unemployed = Unemployed[1], TotalPop = TotalPop[1])
    

neighborhoods = read_csv("neighborhoods.csv") %>%
    mutate(zips = sapply(zips, function(x) as.list(strsplit(x," ")))) %>%
    unnest(zips) %>%
    add_row(zips = "00083", neighborhood = "Central Park")

zip_sf = st_read("nyc_zip_code_tabulation_areas_polygons.geojson", stringsAsFactors = FALSE)
zip_sf = merge(zip_sf, unique_census, by.x="postalcode", by.y="zip_code", all.x=TRUE)
zip_sf = merge(zip_sf, neighborhoods, by.x="postalcode", by.y="zips", all.x=TRUE)

crime_scores = score_by_time_and_rating %>%
    mutate(month_char = format(as.Date(month), "%Y-%m"))%>%
    filter(month > "2002-12-31") %>%
    data.frame() %>%
    select(-c("weight","sum_weight","Men", "Women", "Hispanic", "White", "Black", "Native", "Asian", "TotalPop", "PerCapitaIncome", "Unemployed"))

save(crime_scores, file = "crime_scores.rda")


zip_sf = rmapshaper::ms_simplify(zip_sf, keep_shapes=TRUE)

save(zip_sf, file="zip_polygons.rda")


rm(list = ls())




