library(dplyr)
library(tidyverse)
library(shiny)
library(leaflet)
library(jsonlite)
library(sf)
library(rmapshaper)
library(RColorBrewer)
library(zoo)
# install.packages("leafpop")
library(ggplot2)
library(scales)

load(file = "Data_Score_by_Time_and_Rating.rda")

# head(score_by_time_and_rating)

load("grouped_housing.rda")
#head(grouped_housing)

summary(score_by_time_and_rating$weight)

score_by_time_and_rating$weight_1000 = (score_by_time_and_rating$weight)*1000

summary(score_by_time_and_rating$weight_1000)

score_by_time_and_rating$weight_log = -1*log((score_by_time_and_rating$weight), 10)

score_by_time_and_rating = score_by_time_and_rating %>%
    filter(!is.na(weight_log))
    
score_by_time_and_rating$weight_normalized = max(score_by_time_and_rating$weight_log) - score_by_time_and_rating$weight_log
score_by_time_and_rating$weight_normalized = score_by_time_and_rating$weight_normalized/max(score_by_time_and_rating$weight_normalized)

new_housing <- grouped_housing %>% 
    rename(
        month_char = sale_month,
    )


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

new_crime_score = score_by_time_and_rating %>%
    mutate(month_char = format(as.Date(month), "%Y-%m"))%>%
    filter(month > "2002-12-31")

merged_housing_crime <- merge(new_housing, new_crime_score, c("month_char", "zip_code"), all = TRUE) %>%
    select(-c("month","weight", "weight_1000","sum_weight","Men", "Women", "Hispanic", "White", "Black", "Native", "Asian", "weight_log", "TotalPop", "PerCapitaIncome", "Unemployed"))
 

create_plot = function(df, y_ind, title, ylabel, curr = FALSE, type="point") {
    x = unlist(df$yearmon)
    y = unlist(df[,y_ind])
    trend = mean(y)
    if (curr == TRUE) {
        if (max(y, na.rm=TRUE) > 1e6) {
            label = label_number(prefix = "$", suffix = "M", scale = 1e-6)
        } else if (max(y, na.rm = TRUE) > 1e4) {
            label =  label_number(prefix = "$", suffix = "K", scale = 1e-3)
        } else {
            label = label_number(prefix = "$")
        }
    } else {
        label = label_number()
    }
    if (type == "bar") {
        gg_type = geom_col() + coord_flip()
    } else if (type == "line") {
        gg_type = geom_line()
    } else {
        gg_type = geom_point()
    }
    p = ggplot(data=NULL, aes(x, y)) +
        gg_type +
        geom_smooth() +
        labs(title = title, y = ylabel, x = "Month")  + 
        scale_y_continuous(label = label, expand = c(0,0), limits = c(0, max(y, na.rm=TRUE)+2)) +
        theme_classic() +
        theme(plot.title = element_text(size = 10, hjust = 0.5))
    return(p)
}

zip_data_plots = merged_housing_crime %>%
    mutate(yearmon = as.yearmon(month_char)) %>%
    select(-month_char) %>%
    group_nest(zip_code) %>%
    mutate(
        total_proceeds_plot = lapply(data, create_plot, y_ind = 3, title = "Total Monthly Proceeds from Sales over Time", ylabel = "Total Proceeds", curr = TRUE, type="line"),
        avg_price_per_sqft_plot = lapply(data, create_plot, y_ind = 1, title = "Price per Sq. Ft. over Time", ylabel = "Price per Sq. Ft.", curr = TRUE, type="line"),
        num_sales_plot = lapply(data, create_plot, y_ind = 2, title = "Monthly Sales over Time", ylabel = "Number of Sales", curr = FALSE, type = "line"),
        weight_normalized_plot = lapply(data, create_plot, y_ind = 4, title = "Crime Score over Time", ylabel = "Crime Score", curr = FALSE, type="line"),
    ) %>%
    select(-data)

zip_sf = rmapshaper::ms_simplify(zip_sf, keep_shapes=TRUE)
zip_sf = merge(zip_sf, zip_data_plots, by.x="postalcode", by.y = "zip_code", all.x = TRUE)

# save(zip_data_plots, file ="zip_data_plots.rda")

save(zip_sf, file="zip_polygons.rda")

save(merged_housing_crime, file = "merged_housing_crime.rda")

rm(list = ls())
# dim(merged_housing_crime)


# head(new_housing)
# head(score_by_time_and_rating)
# 
# 
# class(score_by_time_and_rating$month)
# class(new_housing$month)
# 
# score_by_time_and_rating$month1 = as.Date(score_by_time_and_rating$month, format = "%Y-%d-%m")
# 
# head(score_by_time_and_rating$month)
# 
# class(new_housing$month)
# 
# 
# 
# # df$ddate <- format(as.Date(df$ddate), "%d/%m/%Y")
# 
# # as.Date(strDates, "%m/%d/%Y")
# 
#  )
# # 
# # # merge(observations, animals, c("size","type"))
# # 
# # summary(merged_housing_crime)
# 


















