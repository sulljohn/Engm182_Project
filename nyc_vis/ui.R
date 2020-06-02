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
                    numericInput("age", "Building age (years):", 50, min=1800, max = 2030),
                    numericInput("sqft", "Square footage:", 2000, min=0, max = 1000000),
                    numericInput("sale_year", "Sale Year:", 2010, min=1950, max = 2030),
                    selectizeInput("zip", "Location:",
                        selected = NULL,
                        choices = unique_zips$select_names,
                        options = list(
                            placeholder = "Search by Neighborhood or Zip Code",
                            onInitialize = I('function() { this.setValue(""); }')
                        )
                    ),
                    radioButtons(
                        "model_select",
                        label="Predictive Model:",
                        choiceNames = c(
                            # "Bagged cart",
                            "Neural Net",
                            "Random forest"
                        ),
                        choiceValues = c(
                            # "fit.bgcrt", 
                            "fit.nnet",
                            "fit.rf"
                        )
                    ),
                    actionButton("predict_price", label = "Compute Price"),
                    HTML("<hr/><b>Predicted Price: </b>"),
                    htmlOutput("price")
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
    
