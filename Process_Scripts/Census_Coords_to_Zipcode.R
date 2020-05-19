# Load the Data_NYC_Tracts first

# Source for the zipcode-tract data: https://www.huduser.gov/portal/datasets/usps_crosswalk.html

library(readxl)
library(dplyr)
library(plyr)

tract_zips <- my_data <- read_excel("TRACT_ZIP_032020.xlsx")

names(tract_zips)[names(tract_zips) == 'ZIP'] <- 'zipcode'
names(tract_zips)[names(tract_zips) == 'TRACT'] <- 'CensusTract'
tract_zips$CensusTract <- as.numeric(tract_zips$CensusTract)

nyc_tracts <- left_join(nyc_tracts, tract_zips, by="CensusTract")

# Save updated nyc_tracs
# save(nyc_tracts, file='Data_NYC_Tracts.rda')

zip_population <- subset(nyc_tracts, select = c(CensusTract,zipcode,TotalPop))

save(zip_population, file = "Data_Zip_Population.rda")

#Getting population of each zip code
zip_population2 <- aggregate(zip_population$TotalPop, by = list(zip = zip_population$zipcode), FUN = sum)
