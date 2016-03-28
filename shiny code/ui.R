library(shiny)
library(leaflet)
library(DT)
library(rCharts)

complain_type <- c(
        "All" = "", "HEAT/HOT WATER"="HEAT/HOT WATER", "Street Condition"="Street Condition","Blocked Driveway"="Blocked Driveway","Illegal Parking"="Illegal Parking","UNSANITARY CONDITION"="UNSANITARY CONDITION"
)

crime_type <- c(
        "All Crime" = "",
        "Grand Larceny" = "GRAND LARCENY",
        "Grand Larceny of Motor Vehicle" = "GRAND LARCENY OF MOTOR VEHICLE",
        "Rape" = "RAPE",
        "Murder" = "MURDER",
        "Robbery" = "ROBBERY",
        "Burglary" = "BURGLARY",
        "Felony Assault" = "FELONY ASSAULT"
)

shinyUI(navbarPage("Complain", id="nav",
                   
                   tabPanel("Interactive Map",
                            div(class="outer",
                                
                                tags$head(
                                        # Include our custom CSS
                                        includeCSS("styles.css"),
                                        includeScript("gomap.js")
                                ),
                                
                                leafletOutput("map", width="100%", height="100%"),
                                
                                # Shiny versions prior to 0.11 should use class="modal" instead.
                                absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                                              draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
                                              width = 330, height = "auto",
                                              
                                              h2("Make your choices"),
                                              
                                              radioButtons("Map Type", "Interactive Map Type:",
                                                           c("Complain" = "complain data",
                                                             "Crime" = "crime data")),
                                              
                                              selectInput("complain", "Choose complaints type", complain_type, selected = ""),
                                              selectInput("crime", "Choose crime type", crime_type, selected = "ROBBERY")
                                              
                                              
                                              # Simple integer interval
                                         
                                              #sliderInput("range", "Price Range:",
                                              #            min = 0, max = 10000, value = c(200,500)),
                                              #helpText("Choose the range of price")
                                )
                            )
                   ),
                   
                   tabPanel("Heat Map",br(),tags$div(class="descrip_text",
                                                              textOutput("heat_text")), br(),
                            chartOutput("baseMap", "leaflet"),
                            absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                                          draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
                                          width = 330, height = "auto",
                                          
                                          h2("Complain records"),
                                          
                                          radioButtons("Heatmap Type", "Heat Map Type:",
                                                       c("Complain" = "complain data",
                                                         "Crime" = "crime data")),
                                          
                                          selectInput("complaintype", "Choose complaints type", complain_type, selected = ""),
                                          selectInput("crimetype", "Choose crime type", crime_type, selected = "ROBBERY")
                                          
                                          # Simple integer interval
                                          
                                          #sliderInput("range", "Price Range:",
                                          #            min = 0, max = 10000, value = c(200,500)),
                                          #helpText("Choose the range of price")
                            ),
                            #leafletOutput("baseMap"),
                            tags$style('.leaflet {width: 930px;height:580px}'),
                            tags$head(tags$script(src="https://leaflet.github.io/Leaflet.heat/dist/leaflet-heat.js")),
                            uiOutput('heatMap'),value=2
                   ),
                   
                   tabPanel("Plots",br(),tags$div(class="descrip_text",
                                                              textOutput("trellis_text")), br(),
                            plotlyOutput("trellis", width="700px"),
                            
                            #leafletOutput("baseMap"),
                            value=1
                   ),
                   
                   conditionalPanel("false", icon("crosshair"))
))