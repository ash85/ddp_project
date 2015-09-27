# The user-interface definition of the Shiny web app.
library(shiny)
library(BH)
library(rCharts)
require(markdown)
require(data.table)
library(dplyr)
library(DT)

shinyUI(
  fluidPage(    
    
    # Give the page a title
    titlePanel("Natural Calamities Analysis"),       
           
          sidebarLayout(      
               
                          
                      sidebarPanel(
                        sliderInput("timeline", 
                                    "Years:", 
                                    min = 1950,
                                    max = 2015,
                                    value = c(1950, 2015)),
                        
                        sliderInput("pieces", 
                                    "Fatalities:",
                                    min = 1,
                                    max = 300,
                                    value = c(1, 100) 
                        )
                                           
                      ),
                      
                                        
                      mainPanel(
                        tabsetPanel(
                          # Data 
                          tabPanel(p(icon("table"), "Dataset"),
                                   dataTableOutput(outputId="dTable")
                          ),
                          tabPanel(p(icon("bar-chart"), "Visualize"), 
                                   h4('Number of Events by Year', align = "center"),
                                   showOutput("themesByYear", "nvd3")
                             
                                          
                      )
                        )
                      
                      )
                      
             )
                        
                          
             
)
  
)