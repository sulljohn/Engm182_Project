#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(tidyverse)
library(shiny)
library(leaflet)

source("Import_All.R")

#df_original <- read_csv("./data/processed/2020-04-14-covid.csv")
#pal <- colorFactor(c("firebrick", "steelblue"), c(FALSE, TRUE))

load("../clean_housing.rda")

lng1 <- 74.2
lat1 <- 40.6
lng2 <- 73.8
lat2 <- 40.8

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

    df <- reactive({
        # This is the same code we used to filter to the latest date in last week's lesson!
        tmp <- clean_housing
        #     filter(date == input$date_select)
        
        return(tmp)
    })
    
    output$map <- renderLeaflet({
        
        leaflet() %>%
            addTiles() %>%
            fitBounds(lng1, lat1, lng2, lat2)
            # addLegend("bottomright", 
            #           pal = pal, 
            #           values = c(FALSE, TRUE),
            #           title = input$color_by,
            #           opacity = 1)
        
        
    })
    
    observe({
        
        leafletProxy("map", data = df()) %>%
            clearMarkers() %>%
            addCircleMarkers()
                 #radius = ~sqrt(get(input$size_by)),
                 # stroke = FALSE,
                 # fillOpacity = 0.5,
                 # color = ~pal(get(input$color_by)),
                 # popup = ~paste0(
                 #     "<b>", region, "</b><br/>",
                 #     "Total confirmed cases to this date: ", confirmed_cases, "<br/>",
                 #     "Per 100k people: ", confirmed_cases_per_100k, "<br/><br/>",
                 #     "Total confirmed deaths to this date: ", deaths, "<br/>",
                 #     "Per 100k people: ", deaths_per_100k, "<br/><br/>",
                 #     "Cases in the preceding week: ", new_cases_week, "<br/>",
                 #     "Per 100k people: ", new_cases_week_per_100k, "<br/><br/>",
                 #     "Deaths in the preceding week: ", new_deaths_week, "<br/>",
                 #     "Per 100k people: ", new_deaths_week_per_100k, "<br/><br/>",
                 #     "Stay at home in place on this date: ", stay_at_home))
    })
    
})

