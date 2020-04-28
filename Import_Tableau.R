# This separate script was created because read_csv was giving issues
# that read.csv did not give when importing crime data into Tableau

# Setting working directory to the current directory
# Source: https://stackoverflow.com/questions/13672720/r-command-for-setting-working-directory-to-source-file-location-in-rstudio
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# Run separate import scripts ...

# Housing is imported first because it clears other variables
source("Import_Scripts/Import_Housing_Data.R")

# Importing crime data
source("Import_Scripts/Import_Crime_Data_Tableau.R")

#Importing census data
source("Import_Scripts/Import_Census_Data.R")

# EXPORTING DATA TO RDA FILES
# Once these have been made fresh, they should be used for analysis

# Saving crime data
save(df_crime, file='Data_Crime.rda')

# Saving housing data
save(df_housing, file='Data_Housing.rda')

# Saving census data
save(block_loc, file='Data_NYC_Census.rda')
save(nyc_tracts, file='Data_NYC_Tracts.rda')
