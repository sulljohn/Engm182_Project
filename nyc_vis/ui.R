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

# Define UI for application that draws a histogram
shinyUI(fluidPage(
    HTML(html_fix),
    titlePanel("NYC Housing and Crime"),
    sidebarLayout(
        sidebarPanel(
            sliderTextInput(
                inputId = "date_select",
                label="Month",
                choices = sort(unique(merged_housing_crime$month_char)),
                animate=TRUE,
                selected="2003-01"
            ),
            radioButtons(
                inputId = "data_select",
                label = "Mapped Data",
                radioButtonOptions # set up in global.R
            ),
            numericInput("year", "Enter year built", 2000, min =1950, max = 2020),
            numericInput("area", "Enter area of property", 1000, min =0, max = 10000),
            actionButton(inputId = "button1", label = "Calculate"),
            
         
            h5("The predicted crime score is:"),
            textOutput("crimescore"),
            h5("The predicted property price is:"),
            textOutput("price")
            
            
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
    
