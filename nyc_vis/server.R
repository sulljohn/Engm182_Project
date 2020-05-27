#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/

library(tidyverse)
library(shiny)
library(leaflet)
library(jsonlite)
library(sf)
library(rmapshaper)
library(RColorBrewer)


load("../zip_polygons.rda")
zip_sf = rmapshaper::ms_simplify(zip_sf, keep_shapes=TRUE)

shinyServer(function(input, output) {

    df <- reactive({
        data = merged_housing_crime %>%
            filter(month_char == input$date_select) %>%
            select(zip_code, disp_data = !!input$data_select)
        tmp = merge(zip_sf, data, by.x="postalcode", by.y="zip_code", all.x=TRUE)
        return(tmp)
    })
    
    output$map <- renderLeaflet({
        leaflet() %>%
            addTiles() %>%
            setView(-74.0060,40.7128, zoom=11)
    })
    
    
    pal = eventReactive(input$data_select, {colorNumeric(
        palette = rev(brewer.pal(n=9, name = "RdYlGn")),
        domain = pull(merged_housing_crime, !!input$data_select)
    )})
    
    observe({
        
        tmp = df()
        
        leafletProxy("map", data = tmp) %>%
            clearShapes() %>%
            addPolygons(
                fillColor = ~pal()(disp_data),
                color = "#b2aeae", # you need to use hex colors
                fillOpacity = 0.7, 
                weight = 1, 
                smoothFactor = 0.2,
                # Highlight neighbourhoods upon mouseover
                highlight = highlightOptions(
                    weight = 3,
                    color = "black",
                    opacity = 1.0
                ),
                popup = ~paste0(
                    "<b>", postalcode, "</b><br/>",
                    "Per capita income in 2015:    $", round(PerCapitaIncome),"</b><br/>",
                    "Total Population in 2015: ", TotalPop, "</b><br/>",
                    "Unemployment rate in 2015: ", round(Unemployed), "%"
                )
            )
    })
    
    observeEvent(input$data_select, {
        tmp = df()
        if (input$data_select == "avg_price_per_sqft") {
            func = labelFormat(prefix = " $")
        } else if (input$data_select == "total_proceeds") {
            func = labelFormat(prefix = " $", suffix = "M", transform=function(x) x/1E6)
        } else {
            func = labelFormat(prefix = " ")
        }
        leafletProxy("map", data = tmp) %>%
            clearControls() %>%
            addLegend(
                title=names(which(radioButtonOptions == input$data_select)),
                pal = pal(), 
                values = ~pull(merged_housing_crime, !!input$data_select), 
                position = "bottomright", 
                labFormat = func
            )
    })
})

