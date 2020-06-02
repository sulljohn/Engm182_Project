# Group data by month and zip code and create variables

library(tidyverse)

load("cleaned_housing.rda")

grouped_housing_all = grouped_housing = cleaned_df_housing %>%
    mutate(month_char = format(as.Date(sale_date), "%Y-%m")) %>%
    group_by(zip_code, month_char) %>%
    summarize(
        category = "All",
        avg_price_per_sqft = mean(price_per_sqft),
        num_sales = n(),
        total_proceeds = sum(sale_price)
    )

grouped_housing = cleaned_df_housing %>%
    mutate(month_char = format(as.Date(sale_date), "%Y-%m")) %>%
    group_by(zip_code, month_char, category) %>%
    summarize(
        avg_price_per_sqft = mean(price_per_sqft),
        num_sales = n(),
        total_proceeds = sum(sale_price)
    ) %>%
    bind_rows(grouped_housing_all) %>%
    filter(total_proceeds < 200000000) %>%
    data.frame()
    

save(grouped_housing, file="grouped_housing.rda")

rm(list = ls())
