# Clean data from rda files here

library(tidyverse)
library(tidygeocoder)
library(strinr)

load("Data_Housing.rda")

# Put boroughs in vector with correct ID (do not change the order of this vector!)

boroughs = c(
  "New York", # 1 (for manhatten addresses the city is given as 'New York')
  "Bronx", # 2
  "Brooklyn", # 3
  "Queens", # 4
  "Staten Island" # 5
)

get_cities = function(borough_ids, neighborhoods) {
  cities = ifelse(borough_ids == 4, neighborhoods, boroughs[borough_ids])
  return(cities)
}

df_housing$borough = as.numeric(df_housing$borough)
df_housing$sale_price = as.numeric(df_housing$sale_price)
df_housing$gross_square_feet = as.numeric(df_housing$gross_square_feet)

clean_df_housing = df_housing %>%
  filter(sale_price > 100) %>%
  filter(gross_square_feet > 1) %>%
  filter(borough %in% c(1:5))

clean_df_housing = within(clean_df_housing, {
  full_address = paste(
    address,
    ", ",
    get_cities(borough, neighborhood),
    ", NY",
    sep=""
  )
})


save(clean_df_housing, file="clean_housing.rda")
rm(clean_df_housing, df_housing, boroughs, get_cities)