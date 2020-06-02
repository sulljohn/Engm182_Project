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
    titlePanel("NYC Real Estate and Crime"),
    sidebarLayout(
        sidebarPanel(
            tabsetPanel(
                tabPanel(
                    
                    "Map Controls",
                    HTML("<br/>"),
                    sliderTextInput(
                        inputId = "date_select",
                        label="Month",
                        choices = sort(unique(c(unique(crime_scores$month_char),unique(grouped_housing$month_char)))),
                        animate=TRUE,
                        selected="2020-03"
                    ),
                    radioButtons(
                        inputId = "data_select",
                        label = "Mapped Data",
                        radioButtonOptions # set up in global.R
                    ),
                    conditionalPanel(
                        condition = "output.housing_data_select == true",
                        selectInput(
                            inputId = "prop_category",
                            label = "Property Category",
                            choices = sort(unique(grouped_housing$category))
                        )
                    )
                ),
                tabPanel(
                    "Price Predictor",
                    HTML("<br/>"),
                    numericInput("age", "Building age:", 2000, min =1950, max = 2020),
                    numericInput("sqft", "Square footage:", 1000, min =0, max = 10000),
                    actionButton("predict_price", label = "Compute Price"),
                    HTML("<hr/><b>Predicted Price: </b>"),
                    textOutput("price")
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
    
