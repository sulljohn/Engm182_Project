library(tidyverse)
library(readxl)
library(data.table)
library(janitor)

# Get list of all excel file names for 2003-2015 and 2019-2020 data
all_files = c(
  list.files(path="../Data/RE_2003-2015", pattern="*.xls", full.names=TRUE, recursive=FALSE),
  list.files(path="../Data/RE_Apr2019-Mar2020", pattern="*.xls", full.names=TRUE, recursive=FALSE)
)

# Import data from all files into a list of datarames
dfs_list = lapply(all_files, function(filename) {
  
  # Reference: https://stackoverflow.com/questions/43242467/reading-excel-in-r-how-to-find-the-start-cell-in-messy-spreadsheets?rq=1
  temp_read = suppressMessages(read_excel(filename))
  desired_sheet = 1
  skip_rows = NULL
  col_skip = 0
  search_string = "BOROUGH"
  max_cols_to_search = 10
  max_rows_to_search = 10
  
  # Note, for the - 0, you may need to add/subtract a row if you end up skipping too far later.
  while (length(skip_rows) == 0) {
    col_skip = col_skip + 1
    if (col_skip == max_cols_to_search) break
    skip_rows = which(stringr::str_detect(temp_read[1:max_rows_to_search,col_skip][[1]],search_string)) - 0
  }
  
  df = suppressMessages(read_excel(
    filename,
    sheet = desired_sheet,
    skip = skip_rows,
    .name_repair="universal"
  ) ) %>% clean_names()
  
  return(df)
})

# Append 2016-2017 data from csv file to list of data frames
dfs_list = append(dfs_list, list(read_csv("../Data/RE_2016-2017/nyc-rolling-sales.csv")[,-(1)] %>% clean_names()))

# Combine list of data frames into a single data frame
df_housing = rbindlist(dfs_list)

# Clear all other variables from workspace
rm(list=setdiff(ls(), "df_housing"))

