#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#


library(shiny)
library(leaflet)
library(shinyWidgets)

load("../grouped_housing.rda")

# Define UI for application that draws a histogram
shinyUI(fluidPage(
    titlePanel("NYC Housing and Crime"),
    sidebarLayout(
        sidebarPanel(
            sliderTextInput(
                inputId = "date_select",
                label="Month",
                choices = sort(unique(grouped_data$month)),
                animate=TRUE,
                selected="2020-01"
            ),
            radioButtons(
                inputId = "data_select",
                label = "Mapped Data",
                choiceValues = colnames(grouped_housing)[-c(1:2)],
                choiceNames = c(
                    "Average price per sq. ft.",
                    "Number of sales",
                    "Total proceeds from sales"
                )
            )
        ),
        mainPanel(
            leafletOutput(
                "map",
                width="100%",
                height="90vh"
            )
        ),
        position="left"
    )
))
    
