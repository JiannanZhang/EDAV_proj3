library(shiny)
library(leaflet)
library(DT)
library(rCharts)

complain_type <- c(
        "All" = "", "HEAT/HOT WATER"="HEAT/HOT WATER", "Street Condition"="Street Condition","Blocked Driveway"="Blocked Driveway","Illegal Parking"="Illegal Parking","UNSANITARY CONDITION"="UNSANITARY CONDITION"
)

shinyUI(navbarPage("Complain", id="nav",
                   
                   tabPanel("Complain Map",
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
                                              
                                              h2("Complain records"),
                                              
                                              selectInput("complain", "Show Just One type", complain_type, selected = "Blocked Driveway")
                                              
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
                                          
                                          selectInput("complaintype", "Show Just One type", complain_type, selected = "Blocked Driveway")
                                          
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