# Load the Data_NYC_Tracts first

# Source for the zipcode-tract data: https://www.huduser.gov/portal/datasets/usps_crosswalk.html

library(readxl)
library(dplyr)
library(plyr)

tract_zips <- my_data <- read_excel("TRACT_ZIP_032020.xlsx")

names(tract_zips)[names(tract_zips) == 'ZIP'] <- 'zip_code'
names(tract_zips)[names(tract_zips) == 'TRACT'] <- 'CensusTract'
tract_zips$CensusTract <- as.numeric(tract_zips$CensusTract)

nyc_tracts <- left_join(nyc_tracts, tract_zips, by="CensusTract")

# Save updated nyc_tracs
save(nyc_tracts, file='Data_NYC_Tracts.rda')

#Adding all the parameters required for regression in zip_population file
zip_population <- subset(nyc_tracts, select = c(CensusTract,zip_code,TotalPop, Men, Women, Hispanic, White, Black, Native, Asian, IncomePerCap, Unemployment))

#Converting the demographic and unemployment percentages to numbers and income per capita to income
zip_population$Hispanic.number <- zip_population$Hispanic*zip_population$TotalPop/100
zip_population$White.number <- zip_population$White*zip_population$TotalPop/100
zip_population$Black.number <- zip_population$Black*zip_population$TotalPop/100
zip_population$Native.number <- zip_population$Native*zip_population$TotalPop/100
zip_population$Asian.number <- zip_population$Asian*zip_population$TotalPop/100
zip_population$IncomeTot <- zip_population$IncomePerCap*zip_population$TotalPop
#Percentage of people in the age group of 18-65 in NY is 65% source: https://www.census.gov/quickfacts/newyorkcitynewyork
zip_population$Unemployment.number <- zip_population$Unemployment*0.65*zip_population$TotalPop/100

#Aggregating the various census tract data into 1 zip code
zip_population <- subset(zip_population, select = c(zip_code,TotalPop, Men, Women, Hispanic.number, White.number, Black.number, Native.number, Asian.number, IncomeTot, Unemployment.number))
zip_population <- aggregate(.~zip_code, data = zip_population, FUN = sum)

#Convert back the demographics and unemployment to % and IncomeTot to per capita income
zip_population$Hispanic.number <- zip_population$Hispanic.number*100/zip_population$TotalPop
zip_population$White.number <- zip_population$White.number*100/zip_population$TotalPop
zip_population$Black.number <- zip_population$Black.number*100/zip_population$TotalPop
zip_population$Native.number <- zip_population$Native.number*100/zip_population$TotalPop
zip_population$Asian.number <- zip_population$Asian.number*100/zip_population$TotalPop
zip_population$IncomeTot <- zip_population$IncomeTot/zip_population$TotalPop
zip_population$Unemployment.number <- zip_population$Unemployment.number*100/(0.65*zip_population$TotalPop)

#Renaming the column headers
colnames(zip_population) <- c("zip_code", "TotalPop", "Men", "Women", "Hispanic", "White", "Black", "Native", "Asian", "PerCapitaIncome", "Unemployed")

save(zip_population, file = "Data_Zip_Population.rda")

