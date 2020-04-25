# Loading packages
library(tidyverse)

# Setting working directory to the current directory
# Source: https://stackoverflow.com/questions/13672720/r-command-for-setting-working-directory-to-source-file-location-in-rstudio
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# Reading data
df <- read_csv("../Data/Crimes_2006-2017/NYPD_Complaint_Data_Historic.csv")

# Barplot of crimes by frequency
# Source: http://www.r-tutor.com/elementary-statistics/qualitative-data/bar-graph
crimetype = df$OFNS_DESC
crimetype.freq = table(crimetype)
barplot(crimetype.freq)

# Histogram of dates
# Source: https://stat.ethz.ch/R-manual/R-devel/library/graphics/html/hist.POSIXt.html
df$Date <- as.Date(df$CMPLNT_FR_DT, "%m/%d/%Y")
hist(df$Date, "years", freq = TRUE)
