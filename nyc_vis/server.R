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

#df_original <- read_csv("./data/processed/2020-04-14-covid.csv")
#pal <- colorFactor(c("firebrick", "steelblue"), c(FALSE, TRUE))

load("../cleaned_housing.rda")

lng1 <- min(cleaned_df_housing$lng)
lat1 <- min(cleaned_df_housing$lat)
lng2 <- max(cleaned_df_housing$lng)
lat2 <- max(cleaned_df_housing$lat)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

    df <- reactive({
        # This is the same code we used to filter to the latest date in last week's lesson!
        tmp <- cleaned_df_housing %>%
            filter(sale_date >= input$date_range[1] & sale_date <= input$date_range[2])
        
        return(tmp)
    })
    
    output$map <- renderLeaflet({
        
        leaflet() %>%
            addTiles()
            #fitBounds(lng1, lat1, lng2, lat2)
            # addLegend("bottomright", 
            #           pal = pal, 
            #           values = c(FALSE, TRUE),
            #           title = input$color_by,
            #           opacity = 1)
        
        
    })
    
    observe({
        
        leafletProxy("map", data = df()) %>%
            clearMarkers() %>%
            addCircleMarkers(
                clusterOptions = markerClusterOptions()
            )
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

