# Run separate import scripts ...

# Housing is imported first because it clears other variables
source("Import_Housing_Data.R")

# Importing crime data
source("Import_Crime_Data.R")

# EXPORTING DATA TO RDA FILES
# Once these have been made fresh, they should be used for analysis

# Saving crime data (must save dataframe, so no extra classes for Tableau)
# Source: https://discuss.analyticsvidhya.com/t/how-to-drop-a-variable-in-r/7324
tmp_crime <- as.data.frame(df_crime)
save(tmp_crime, file='Data_Crime.rda')
rm(tmp_crime)

# Saving housing data
save(df_housing, file='Data_Housing.rda')
