
# Create temp folder for popup plots and rdas, set rda file location
folder <- tempfile()
dir.create(folder)
rda_loc = "../"

# These lines are for hosting the Shiny app on shinyapps.io
# Leave them commented out when you're running on your local machine
# library(rdrop2)
# drop_auth(rdstoken = "token.rds")
# dir_info = drop_dir("Rstudio_cloud/engm_182_project_data")
# mapply(drop_get,
#     path = dir_info$path_display,
#     local_file = paste(folder,dir_info$name,sep="/"),
#     overwrite = rep(TRUE, nrow(dir_info))
# )
# rda_loc = paste0(folder, "/")

# Load data gropued by month and zip code
load(paste0(rda_loc, "merged_housing_crime.rda"))

# Build list of radio button choice names and values
radioButtonOptions = setNames(
    as.list(colnames(merged_housing_crime)[-c(1:2)]), # values
    c( # choice names
        "Average price per sq. ft.",
        "Number of sales",
        "Total proceeds from sales",
        "Crime score"
    )
)


# Legend NA position fix
library(magrittr)
library(htmlwidgets)
css_fix <- "div.info.legend.leaflet-control br {clear: both;}"
html_fix <- as.character(htmltools::tags$style(type = "text/css", css_fix)) 
