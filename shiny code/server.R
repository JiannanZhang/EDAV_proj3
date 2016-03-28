library(shiny)
library(leaflet)
library(RColorBrewer)
library(dplyr)
library(ggplot2)


shinyServer(function(input, output, session) {
        
        
        
        ## complain Map ###########################################
        
        # Create the map
        output$map <- renderLeaflet({
                leaflet() %>%
                        addTiles(
                                urlTemplate = "https://api.mapbox.com/v4/mapbox.satellite/{z}/{x}/{y}.png?access_token=pk.eyJ1IjoiZnJhcG9sZW9uIiwiYSI6ImNpa3Q0cXB5bTAwMXh2Zm0zczY1YTNkd2IifQ.rjnjTyXhXymaeYG6r2pclQ",
                                attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>'
                        ) %>%
                setView(lng = -73.97, lat = 40.75, zoom = 13)
        })
        
        # Filter crime data
        comdata <- reactive({
                draw <- data_2015_top5
                if (input$complain != ''){
                        t <- filter(draw, Complaint_Type==input$complain)
                        draw <- t
                }
                return(draw)
        })
        
        cridata <- reactive({
                draw <- crime
                if (input$crime != '') {
                        t <- filter(draw, Offense == input$crime)
                        draw <- t
                }
                
                return(draw)
        }) 
        
        observe({  
                pal1 <- colorFactor(palette()[2:6], levels(data_2015_top5$Complaint_Type))
                pal2 <- colorFactor(palette()[-1], levels(crime$Offense))
                Radius1 <- 2
                if (input$`Map Type`=="complain data"&length(as.matrix(comdata())) != 0){
                        leafletProxy("map") %>%
                                clearMarkers() %>%
                                # addPolylines(lng=c(a$lon,a$lon1),lat=c(a$lat,a$lat1),color="red") %>%
                                #addMarkers(data = ttype(), ~Long, ~Lat, icon = restroomIcon(), options = markerOptions(opacity = 0.9), popup = ~Name) %>%
                                        addCircleMarkers(data = comdata(), ~Long, ~Lat, radius = Radius1, stroke = FALSE, fillOpacity = 0.7, fillColor = pal1(comdata()[["Complaint_Type"]])) %>%
                                        addLegend("bottomleft", pal=pal1, values=comdata()[["Complaint_Type"]], title="complain",
                                          layerId="colorLegend")
                }
                if (input$`Map Type`=="crime data"&length(as.matrix(cridata())) != 0){
                        leafletProxy("map") %>%
                                clearMarkers() %>%
                                # addPolylines(lng=c(a$lon,a$lon1),lat=c(a$lat,a$lat1),color="red") %>%
                                #addMarkers(data = ttype(), ~Long, ~Lat, icon = restroomIcon(), options = markerOptions(opacity = 0.9), popup = ~Name) %>%
                                addCircleMarkers(data = cridata(), ~Long, ~Lat, radius = Radius1, stroke = FALSE, fillOpacity = 0.7, fillColor = pal2(cridata()[["Offense"]])) %>%
                                addLegend("bottomleft", pal=pal2, values=cridata()[["Offense"]], title="Crime",
                                          layerId="colorLegend")
                }
                if (length(as.matrix(cridata())) == 0|length(as.matrix(comdata())) == 0) {
                        leafletProxy("map") %>%
                                clearMarkers()
                }
                
        })
        
        output$heat_text = renderText({
                paste("Heat Graph of All Complaints")
        })
        
        output$baseMap  <- renderMap({
                baseMap <- Leaflet$new()
                baseMap$setView(c(40.7577,-73.9857), 10)
                baseMap$tileLayer(provider = "Stamen.TonerLite")
                baseMap
                
                #leaflet() %>% addTiles() %>% addProviderTiles("Stamen.TonerLite") %>%setView(lat=40.7577,lng=-73.9857, zoom=10)
                
        })
        
        
        output$heatMap <- renderUI({
                
                if (input$`Heatmap Type`=="complain data") {
                        if (input$complaintype == ''){
                                hdata <- data_2015_top5
                                
                        }
                        else{
                                hdata <- data_2015_top5[which(data_2015_top5$Complaint_Type==input$complaintype), ]
                                
                        }
                        
                        
                        complainmap1 <- as.data.table(hdata)
                        complainmap2 <- complainmap1[(Lat != ""), .(count = .N), by=.(Lat, Long)]
                        j <- paste0("[",complainmap2[,Lat], ",", complainmap2[,Long], ",", complainmap2[,count], "]", collapse=",")
                        j <- paste0("[",j,"]")
                        tags$body(tags$script(HTML(sprintf("
                                var addressPoints = %s
if (typeof heat === typeof undefined) {
            heat = L.heatLayer(addressPoints)
            heat.addTo(map)
          } else {
            heat.setOptions()
            heat.setLatLngs(addressPoints)
          }
                                         </script>"
                                                           , j))))
                }
                
                if (input$`Heatmap Type`=="crime data") {
                        if (input$crimetype == ''){
                                hdata <- crime
                                
                        }
                        else{
                                hdata <- crime[which(crime$Offense==input$crimetype), ]
                                
                        }
                        
                        
                        crimemap1 <- as.data.table(hdata)
                        crimemap2 <- crimemap1[(Lat != ""), .(count = .N), by=.(Lat, Long)]
                        j <- paste0("[",crimemap2[,Lat], ",", crimemap2[,Long], ",", crimemap2[,count], "]", collapse=",")
                        j <- paste0("[",j,"]")
                        tags$body(tags$script(HTML(sprintf("
                                var addressPoints = %s
if (typeof heat === typeof undefined) {
            heat = L.heatLayer(addressPoints)
            heat.addTo(map)
          } else {
            heat.setOptions()
            heat.setLatLngs(addressPoints)
          }
                                         </script>"
                                                           , j))))
                }
                
                
                
        })
        
        output$trellis <- renderPlotly({
                
                gg <- ggplot(trellis_data, aes(Room, Price)) +
                        geom_point(aes(color = Type ))+
                        facet_wrap(~RegionName, ncol=3)+coord_flip()+
                        ggtitle("Comparison of Home Value and Lease")
                # Convert the ggplot to a plotly
                p <- ggplotly(gg)
                p
        })
        
        
})
