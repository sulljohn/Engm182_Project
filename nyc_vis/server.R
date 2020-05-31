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

# Create temp folder for popup plots
folder <- tempfile()
dir.create(folder)

shinyServer(function(input, output) {
    
   
    output$crimescore<- renderText({
        (input$year+input$area)/1000
    })
    
    output$price <- renderText({
        input$year-input$area
    })

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
            clearPopups() %>%
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
                layerId = ~postalcode
            ) 
    })
    
    
    # Observe shape clicks to display popup
    observeEvent(input$map_shape_click,{
        event = input$map_shape_click
        if (is.null(event))
            return()
        else {
            showPopup(event$id, event$lat, event$lng, input$data_select)
        }
    })
    
    showPopup <- function(id, lat, lng, plot_type) {
        
        # Get plot object and other popup data for the chosen zip code
        plot_type_str = paste(plot_type, "_plot", sep="")
        zip_data = zip_sf[which(zip_sf$postalcode == id),]
        cat(zip_data$neighborhood)
        plot = pull(zip_data, !!plot_type_str)
        
        # Write svg file to temporary folder
        svg(filename= paste(folder,"plot.svg", sep = "/"), 
            width = 500 * 0.01, height = 300 * 0.01)
        print(plot)
        dev.off()
        
        # Create popup
        content <- paste(readLines(paste(folder,"plot.svg",sep="/")), collapse = "")
        leafletProxy("map") %>%
            addPopups(
                lng,
                lat,
                popup = paste0(
                    "<h4>", zip_data$neighborhood, " - ", id, "</h4><br/>",
                    content, "<br/>",
                    "<b>2015 Census Data</b><br/>",
                    "Per capita income:    $", round(zip_data$PerCapitaIncome),"</b><br/>",
                    "Total Population: ", zip_data$TotalPop, "</b><br/>",
                    "Unemployment rate: ", round(zip_data$Unemployed), "%"
                ),
                layerId = id,
                options = popupOptions(maxWidth = 500)
            )
    }
    
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

