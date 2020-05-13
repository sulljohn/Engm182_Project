# Clean data from rda files here

library(tidyverse)
library(geoclient)

load("Data_Housing.rda")

# Convert chr variables to numerics
df_housing$borough = as.numeric(df_housing$borough)
df_housing$sale_price = as.numeric(df_housing$sale_price)
df_housing$gross_square_feet = as.numeric(df_housing$gross_square_feet)

# Get only data with valid sale prices, square footages, build borough-block-lot (BBL) ID for geocoding
clean_df_housing = df_housing %>%
  filter(sale_price > 100) %>%
  filter(gross_square_feet > 1) %>%
  mutate(bbl = borough * 1e9 + block * 1e4 + lot)

# Get BBL data (including lat and long) from NYC Geoclient API -- THIS WILL TAKE 7 HRS TO RUN! Ask Carter for the the file if you don't want to wait.
bbl_df = geo_bbl(clean_df_housing$bbl, id="a86acdae", key="029728ea05cb18e7aba7cf2bafcb9c1a")

# Join the housing data with BBL data
clean_df_housing = bind_cols(clean_df_housing, bbl_df)

# Save data as rda file
save(clean_df_housing, file="clean_housing.rda")
