# Group data by month and zip code and create variables

library(tidyverse)

load("cleaned_housing.rda")

grouped_housing = cleaned_df_housing %>%
    mutate(sale_month = format(as.Date(sale_date), "%Y-%m")) %>%
    group_by(zip_code, sale_month) %>%
    summarize(
        avg_price_per_sqft = mean(price_per_sqft),
        num_sales = n(),
        total_proceeds = sum(sale_price)
    ) %>%
    filter(total_proceeds < 200000000)
    
save(grouped_housing, file="grouped_housing.rda")
