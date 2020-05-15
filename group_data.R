# Group data by month and zip code and create variables

library(tidyverse)

load("cleaned_housing.rda")

grouped_data = cleaned_df_housing %>%
    mutate(sale_month = format(as.Date(sale_date), "%Y-%m")) %>%
    group_by(zip_code, sale_month) %>%
    summarize(
        zip = zip_code[1],
        month = sale_month[1],
        avg_price_per_sqft = mean(sale_price/gross_square_feet),
        num_sales = n(),
        total_proceeds = sum(sale_price)
    )

save(grouped_data, file="grouped_data.rda")
