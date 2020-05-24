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


load("../merged_housing_crime.rda")

zip_sf = st_read("../nyc_zip_code_tabulation_areas_polygons.geojson", stringsAsFactors = FALSE)
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
        palette = "YlGnBu",
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
                popup = ~paste0(
                    "<b>", postalcode, "</b><br/>"
                )
            )
    })
    
    observeEvent(input$data_select, {
        tmp = df()
        if (input$data_select %in% c("PerCapitaIncome", "avg_price_per_sqft")) {
            func = labelFormat(prefix = " $")
        } else if (input$data_select == "total_proceeds") {
            func = labelFormat(prefix = " $", suffix = "M", transform=function(x) x/1E6)
        } else if (input$data_select == "Unemployed") {
            func = labelFormat(suffix = "%")
            
            
        } else {
            func = labelFormat(prefix = " ")
        }
        leafletProxy("map", data = tmp) %>%
            clearControls() %>%
            addLegend(
                pal = pal(), 
                values = ~pull(merged_housing_crime, !!input$data_select), 
                position = "bottomright", 
                title = input$data_select,
                labFormat = func
            )
    })
})

