# Loading packages
library(tidyverse)

# Setting working directory to the current directory
# Source: https://stackoverflow.com/questions/13672720/r-command-for-setting-working-directory-to-source-file-location-in-rstudio
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# Reading data
df <- read_csv("../Data/Crimes_2006-2017/NYPD_Complaint_Data_Historic.csv")

