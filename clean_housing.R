#Trim and clean geocoded housing data

library(tidyverse)
library(stringr)
library(postmastr)

load("geocoded_housing.rda")

clean_address = function(address) {
  address = str_to_title(str_replace_all(str_trim(address), "\\s+", " "))
  #cap_grps = str_match(address, "(Drive|Parkway|Street|Turnpike|Place|Road|Avenue|Alley|Highway|Lane|Route)[\\s,](.*)")
  #cap_grps = str_match_all(address, )
  return(address)
}

cleaned_df_housing = geocoded_df_housing %>%
  select(
    # borough,
    # neighborhood,
    # building_class_category,
    # tax_class_at_present,
    # block,
    # lot,
    # building_class_at_present,
    # address,
    # apartment_number,
    zip_code,
    # residential_units,
    # commercial_units,
    # total_units,
    # land_square_feet,
    gross_square_feet,
    # year_built,
    # tax_class_at_time_of_sale,
    # building_class_at_time_of_sale,
    sale_price,
    sale_date,
    # bbl,
    # buildingIdentificationNumber,
    # cooperativeIdNumber,
    # gi5DigitStreetCode1,
    # giHighHouseNumber1,
    # giLowHouseNumber1,
    # giStreetName1,
    latitudeInternalLabel,
    longitudeInternalLabel
  ) %>%
  rename(lat = latitudeInternalLabel) %>%
  rename(lng = longitudeInternalLabel) %>%
  # mutate(address = sapply(address, clean_address)) %>%
  filter(!(is.na(lat) | is.na(lng))) %>%
  filter(!(is.na(zip_code) | zip_code == 0)) %>%
  filter(!(is.na(sale_price))) %>%
  filter(!(is.na(gross_square_feet) | gross_square_feet <= 0)) %>%
  mutate(price_per_sqft = sale_price/gross_square_feet) %>%
  filter(price_per_sqft <= 2500) %>%
  filter(price_per_sqft > 20) %>%
  mutate(zip_code = sapply(zip_code, as.character))

save(cleaned_df_housing, file="cleaned_housing.rda")

