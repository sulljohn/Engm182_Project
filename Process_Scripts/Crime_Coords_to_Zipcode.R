# Load df_crime first (after running thte crime_rating file)

# Code source: https://stackoverflow.com/questions/46267287/reverse-geocoding-speed
# Data source: https://jsspina.carto.com/tables/nyc_zip_code_tabulation_areas_polygons/public/map

library(sf)
library(purrr)
library(lubridate)
library(dplyr)

# Test source
# sf <- sf::st_read("https://raw.githubusercontent.com/blackmad/neighborhoods/master/new-york-city-boroughs.geojson")

# Real source
sf <- sf::st_read("nyc_zip_code_tabulation_areas_polygons.geojson")

# Test data
# latitude <- c(40.84935,40.76306,40.81423,40.63464,40.71054)
# longitude <- c(-73.87119,-73.90235,-73.93443,-73.88090,-73.83765)
# x = data.frame(longitude, latitude)

# sf_x <- sf::st_as_sf(x, coords = c("longitude", "latitude"))

# Real data
CMPLNT_NUM <- c(df_crime$CMPLNT_NUM)
latitude <- c(df_crime$Latitude)
longitude <- c(df_crime$Longitude)

x = data.frame(CMPLNT_NUM, longitude, latitude)
x <- na.omit(x)

sf_x <- sf::st_as_sf(x, coords = c("longitude", "latitude"))

## set the cooridnate reference system to be the same
st_crs(sf_x) <- st_crs(sf)

res <- st_within(sf_x, sf)  ## return the indexes of sf that sf_x are within

## view the results
out <- sapply(res, function(x) as.character(sf$postalcode[x]))

# Converting to factor
out2 <- map(out, 1) # Take first element from each list
out3 <- lapply(out, function(x) ifelse(length(x) == 1, x[1], NA)) # Handle NAs
out4 <- vapply(out3, paste, collapse = ", ", character(1L)) # Flattten listst; source: https://stackoverflow.com/questions/24829027/unimplemented-type-list-when-trying-to-write-table

sf_x$zipcode <- out4

# Putting it back with the sf_data
df_crime <- left_join(df_crime, sf_x, by = "CMPLNT_NUM")

# Format column as dates
df_crime$CMPLNT_FR_DT <- as.Date(df_crime$CMPLNT_FR_DT, format = "%m/%d/%Y")

# This column NEEDS to be removed because it causes errors
df_crime$geometry<-NULL

# Saving the data with thet important information
save(df_crime, file='Data_Crime_w_Zipcodes.rda')