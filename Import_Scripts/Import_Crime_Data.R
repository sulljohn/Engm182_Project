# Loading packages
library(tidyverse)

# Reading data; using read.csv instead of read_csv
# to get a data.frame instead of tibble, which is
# more useful whend oing anallysis in other programs
df_crime <- read_csv("../Data/Crimes_2006-2017/NYPD_Complaint_Data_Historic.csv")

