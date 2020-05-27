
load("../merged_housing_crime.rda")

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
