#########
# Author: sdmay22-12 Team
#
# Module for canvas grade histogram
# 
#########
library(shinyWidgets)

GradeHistrogramUI <- function(id) {
  ns <- NS(id)
  fluidRow(

    column(12,
           
           br(),
           br(),
           br(),
           #histogram plot
           plotOutput(ns("distPlot")),
           #slider
           setSliderColor(c("darkgray "), c(1)),
           sliderInput(inputId = ns("bins"), label = "Number of bins:", min = 1, max = 50, value = 30),
           
    ),
    
  )
}


GradeHistogramServer <- function(id, surveyIdentity, con, files) {  
  moduleServer(id, function(input, output, session) {
    
    #output for the grade histogram
    output$distPlot <- renderPlot({
      #Get canvas grade data from database
      performanceData <- dbGetQuery(con, "SELECT * FROM SimulatedCanvasData")
      req(performanceData)
      
      #filter down to only get the grade once for each netid
      filteredData <- dplyr::filter(performanceData,  Course.Score > 0) 
      col_remove <- c("Category","Class","Title","Views","Participations","Action","Code","Group.Code","Context.Type","Context.ID", "Section", "Section.ID","Team")
      data_new <- filteredData%>%
        select(- one_of(col_remove))
      
      #final data after filtering down
      chartData <- unique(data_new) 
      colnames(chartData)[1] <- "NetID"
      
      #settings for the histogram
      x    = chartData$Course.Score 
      bins <- seq(min(x), max(x), length.out = input$bins + 1)
      
      hist(x, breaks = bins, col = "darkgray", border = "white",
           xlab = "Grade",
           ylab = "Number of Students",
           main = paste("Class Grade Distribution"))
      
      
    })
    
    
  })
  
}
