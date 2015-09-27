library(shiny)

require(data.table)
library(dplyr)
library(DT)
library(rCharts)

# Read data
data <- fread("./data/events.csv")
head(data)
'
setnames(data, "t1", "theme")
setnames(data, "descr", "name")
setnames(data, "set_id", "setId")
'

setnames(data, "EVTYPE", "event")
setnames(data, "STATE", "state")
setnames(data, "YEAR", "year")
setnames(data, "FATALITIES","fatalities")
setnames(data, "COUNT","count")

groupByTheme <- function(dt, minYear, maxYear, 
                         minPiece, maxPiece, themes) {
  # use pipelining
  # print(dim(dt))
  dt <- groupByYearPiece(dt, minYear, maxYear, minPiece,
                         maxPiece, themes) 
  # print(dim(result))
  result <- datatable(dt, options = list(iDisplayLength = 50))
  return(result)

}

groupByYearPiece <- function(dt, minYear, maxYear, minPiece,
                             maxPiece, themes) {
  result <- dt %>% filter(year >= minYear, year <= maxYear,
                          fatalities >= minPiece, fatalities <= maxPiece,
                          event %in% themes) 
  return(result)
}

groupByYearAgg <- function(dt, minYear, maxYear, minPiece,
                           maxPiece, themes) {
  dt <- groupByYearPiece(dt, minYear, maxYear, minPiece,
                         maxPiece, themes)
  result <- dt %>% 
    group_by(year)  %>% 
    summarise(count = n()) %>%
    arrange(year)
  return(result)
}

plotThemesCountByYear <- function(dt, dom = "themesByYear", 
                                  xAxisLabel = "Year",
                                  yAxisLabel = "Number of Events") {
  themesByYear <- nPlot(
    count ~ year,
    data = dt,
    #type = "lineChart", 
    type = "multiBarChart",
    dom = dom, width = 650
  )
  themesByYear$chart(margin = list(left = 100))
  themesByYear$yAxis(axisLabel = yAxisLabel, width = 80)
  themesByYear$xAxis(axisLabel = xAxisLabel, width = 70)
  themesByYear
}

# Load data processing file
#source("data_processing.R")
themes <- sort(unique(data$event))

# Shiny server
shinyServer(
  function(input, output) {

    

     
    # Initialize reactive values
    values <- reactiveValues()
    values$themes <- themes
    
    
    # Prepare dataset
    dataTable <- reactive({
      groupByTheme(data, input$timeline[1], 
                   input$timeline[2], input$pieces[1],
                   input$pieces[2], themes)
    })
    
    dataTableByYear <- reactive({
      groupByYearAgg(data, input$timeline[1], 
                     input$timeline[2], input$pieces[1],
                     input$pieces[2], themes)
    })
    
    dataTableByPiece <- reactive({
      groupByYearPiece(data, input$timeline[1], 
                       input$timeline[2], input$pieces[1],
                       input$pieces[2], themes)
    })
    
    
    # Render data table
    output$dTable <- renderDataTable({
      dataTable()
    }
    )

    

    
    output$themesByYear <- renderChart({
      plotThemesCountByYear(dataTableByYear())
    })
    
    output$piecesByYear <- renderChart({
      plotPiecesByYear(dataTableByPiece())
    })
    
  } # end of function(input, output)
)