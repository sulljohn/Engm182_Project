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
library(sf)
library(RColorBrewer)
library(zoo)
library(scales)
library(ggplot2)
library(nnet)

load(paste0(rda_loc, "zip_polygons.rda"))
load(paste0(rda_loc, "neural_net.rda"))


shinyServer(function(input, output) {
    
    output$housing_data_select = reactive({
        return(housing_data_select())
    })
    
    housing_data_select = reactive({
        if (input$data_select %in% colnames(grouped_housing)[-c(1:3)]) {
            return(TRUE)
        } else {
            return(FALSE)
        }
    })
   
    # output$crimescore<- renderText({
    #     (input$year+input$area)/1000
    # })
    
    observeEvent(input$predict_price, {
        output$price <- renderText({
            input_data = data.frame(gross_square_feet = input$sqft, age = input$age, sale_year = input$sale_year, zip_code = as.character(input$zip))
            zip_data = zip_sf %>%
                filter(postalcode == input$zip) %>%
                slice(1) %>%
                data.frame() %>%
                select(postalcode, PerCapitaIncome, White, Black, Asian, Hispanic, Native, TotalPop.x = TotalPop, Unemployed, weight) %>%
                inner_join(input_data, by = c("postalcode" = "zip_code")) %>%
                select(-postalcode)
            
            return(dollar(predict(fit.nnet, newdata=zip_data)))
        })
    })

    df <- reactive({
        if (housing_data_select()) {
            data = grouped_housing %>% 
                filter(category == input$prop_category, month_char == input$date_select) %>%
                select(zip_code, disp_data = !!input$data_select)
        } else {
            data = crime_scores %>%
                filter(month_char == input$date_select) %>%
                select(zip_code, disp_data = !!input$data_select)
        }
        tmp = merge(zip_sf, data, by.x="postalcode", by.y="zip_code", all.x=TRUE)
        return(tmp)
    })
    
    output$map <- renderLeaflet({
        leaflet() %>%
            addTiles() %>%
            setView(-74.0060,40.7128, zoom=11)
    })
    
    observe({
        
        
        tmp = df()
        
        legend_labels = NULL
        
        pal = colorNumeric(
            palette = rev(brewer.pal(n=9, name = "RdYlGn")),
            domain = NULL
        )
        
        if (all(is.na(tmp$disp_data))) {
            func = labelFormat()
            tmp$disp_data = as.factor(rep("NA", nrow(tmp)))
            pal = colorFactor(palette = "#808080", domain = NULL)
        } else if (input$data_select == "avg_price_per_sqft") {
            func = labelFormat(prefix = " $")
        } else if (input$data_select == "total_proceeds") {
            func = labelFormat(prefix = " $", suffix = "M", transform=function(x) x/1E6)
        } else {
            func = labelFormat(prefix = " ")
        }
        
        leafletProxy("map", data = tmp) %>%
            clearControls() %>%
            clearShapes() %>%
            clearPopups() %>%
            addPolygons(
                fillColor = ~pal(disp_data),
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
            ) %>%
            addLegend(
                title=names(which(radioButtonOptions == input$data_select)),
                pal = pal, 
                values = ~disp_data, 
                position = "bottomright", 
                labFormat = func,
                labels = legend_labels
            )
    })
    
    
    # Observe shape clicks to display popup
    observeEvent(input$map_shape_click,{
        event = input$map_shape_click
        if (is.null(event))
            return()
        else {
            curr = FALSE
            if (housing_data_select()) {
                data = grouped_housing %>%
                    filter(category == input$prop_category, zip_code == event$id) %>%
                    select(month_char, !!input$data_select)
                title_suffix_str = paste("-", input$prop_category)
                if (input$prop_category == "All") {
                    title_suffix_str = paste(title_suffix_str, "Categories")
                }
                if (input$data_select %in% c("avg_price_per_sqft", "total_proceeds")) {
                    curr = TRUE
                }
            } else {
                data = crime_scores %>%
                    filter(zip_code == event$id) %>%
                    select(month_char, weight_normalized)
                title_suffix_str = "over Time"
            }
            showPopup(data, event$id, event$lat, event$lng, title_suffix_str, curr)
        }
    })
    
    showPopup <- function(df, id, lat, lng, suff_str, curr = FALSE) {
        
        # Get plot object and other popup data for the chosen zip code
        zip_data = zip_sf[which(zip_sf$postalcode == id),]
        if (nrow(df) > 0) {
            y = pull(df, 2)
            x = as.yearmon(pull(df, 1))
            title = paste(names(which(radioButtonOptions == colnames(df)[2])), suff_str)
            ylabel = names(which(radioButtonOptions == colnames(df)[2]))
            
            if (curr == TRUE) {
                if (max(y, na.rm=TRUE) > 1e6) {
                    label = label_number(prefix = "$", suffix = "M", scale = 1e-6)
                } else if (max(y, na.rm = TRUE) > 1e4) {
                    label =  label_number(prefix = "$", suffix = "K", scale = 1e-3)
                } else {
                    label = label_number(prefix = "$")
                }
            } else {
                label = label_number()
            }
            plot = ggplot(data=NULL, aes(x, y)) +
                geom_line() +
                geom_smooth() +
                labs(title = title, y = ylabel, x = "Month")  +
                scale_y_continuous(label = label, expand = c(0,0), limits = c(0, ifelse(colnames(df)[2] == "weight_normalized", 1, max(y, na.rm=TRUE)))) +
                theme_classic() +
                theme(plot.title = element_text(size = 11, hjust = 0.5), axis.title = element_text(size = 10))
    
            # Write svg file to temporary folder
            svg(filename= paste(folder,"plot.svg", sep = "/"),
                width = 500 * 0.01, height = 300 * 0.01)
            print(plot)
            dev.off()
    
            content <- paste(readLines(paste(folder,"plot.svg",sep="/")), collapse = "")
        } else {
            content = ""
        }
        
        # Create popup
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
    
    outputOptions(output, "housing_data_select", suspendWhenHidden = FALSE)
})

