# Setting working directory to the current directory
# Source: https://stackoverflow.com/questions/13672720/r-command-for-setting-working-directory-to-source-file-location-in-rstudio
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# Run separate import scripts ...

# Housing is imported first because it clears other variables
source("Import_Scripts/Import_Housing_Data.R")

# Importing crime data
source("Import_Scripts/Import_Crime_Data.R")

# Saving the workspace (it will be gitignored)
# Once this has been made fresh,
# it should be used for analysis
save.image(file='Data_ALL.RData')