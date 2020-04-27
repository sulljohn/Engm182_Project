# Run separate import scripts ...

# Housing is imported first because it clears other variables
source("Import_Housing_Data.R")

# Importing crime data
source("Import_Crime_Data.R")

# Saving the workspace (it will be gitignored)
# Once this has been made fresh,
# it should be used for analysis
save(df_crime, file='Data_Crime.rda')
save(df_housing, file='Data_Housing.rda')
