# Setting working directory to the current directory
# Source: https://stackoverflow.com/questions/13672720/r-command-for-setting-working-directory-to-source-file-location-in-rstudio
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# Run separate processing scripts ...

# 1. Import df_crime and nyc_tracts [BOTH should be fresh versions (just after Import.R run)]
load(file = "Data_Crime.rda")
load(file = "Data_NYC_Tracts.rda")

# 2. Crime rating
source("Process_Scripts/Crime_Rating.R", echo = TRUE)

# 3. Census coordinates to zipcodes
source("Process_Scripts/Census_Coords_to_Zipcode.R", echo = TRUE)

# 4. Crime coordinates to zipcode
source("Process_Scripts/Crime_Coords_to_Zipcode.R", echo = TRUE)

# * The data needs to be reloaded in this way or some weird errors occur
# Restart R if you get any errors wih the last steps and just run the following code

# 5. Parse month and create crime ratings
source("Process_Scripts/Crime_Months_Ratings.R", echo = TRUE)

# 6. Create Sale Census Crime Dataframe
source("Process_Scripts/Sale_Census_Crime_DF.R", echo = TRUE)
