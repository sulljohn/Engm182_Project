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

load("../grouped_data.rda")

# Define UI for application that draws a histogram
shinyUI(fluidPage(
    sidebarLayout(
        sidebarPanel(
            sliderTextInput(
                inputId = "date_select",
                label="Month",
                choices = sort(unique(grouped_data$month)),
                animate=TRUE,
                selected="2020-01"
            )
        ),
        mainPanel(
            leafletOutput(
                "map",
                width="100%",
                height="100vh"
            )
        ),
        position="left"
    ),
    title="NYC Housing and Crime Data"
    # hr(),
    # fluidRow(
    #     column(4,        
    #            sliderInput("date_select", 
    #                        "Select Mapping Date",
    #                        min = min(df_original$date),
    #                        max = max(df_original$date),
    #                        value = max(df_original$date),
    #                        animate = TRUE)
    #     ),
    #     column(4,
    #            radioButtons("color_by",
    #                         "Color Markers By Policy",
    #                         choices = list("Stay At Home Order" = "stay_at_home",
    #                                        "State of Emergency" = "state_of_emergency",
    #                                        "K-12 Schools Closed" = "schools_closed",
    #                                        "Non-essential Businesses Closed" = "non_essentials_closed"))
    #     ),
    #     column(4,
    #            radioButtons("size_by",
    #                         "Size Markers By Value",
    #                         choices = list("Total Confirmed Cases" = "confirmed_cases",
    #                                        "Total Confirmed Cases per 100k People" = "confirmed_cases_per_100k",
    #                                        "New Cases in Last Week" = "new_cases_week",
    #                                        "New Cases in Last Week per 100k People" = "new_cases_week_per_100k",
    #                                        "Total Deaths" = "deaths",
    #                                        "Deaths per 100k People" = "deaths_per_100k",
    #                                        "Deaths in Last Week" = "new_deaths_week",
    #                                        "Deaths in Last Week per 100k People" = "new_deaths_week_per_100k"), 
    #                         selected = "new_cases_week_per_100k")
    #     )
    # ),
    # hr(),
    # fluidRow(
    #     column(12,
    #            p("Data from ", 
    #              a("Johns Hopkins", 
    #                href = "https://github.com/CSSEGISandData/COVID-19", 
    #                target = "_blank"),
    #              " and ", 
    #              a("Boston University", 
    #                href = "https://docs.google.com/spreadsheets/d/1zu9qEWI8PsOI_i8nI_S29HDGHlIp2lfVMsGxpQ5tvAQ/edit?usp=sharing", 
    #                target = "_blank"))
    #     )
    # )
))
    
