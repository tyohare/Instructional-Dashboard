#########
# Author: sdmay22-12 Team
#
# Module for canvas grade and network information datatable
# 
#########
library(shinyWidgets)

DataTableUI <- function(id) {
  ns <- NS(id)
  #Put datatable into UI
  DT::dataTableOutput(ns('table1'))
}


DataTableServer <- function(id, surveyIdentity, con, files) {  
  moduleServer(id, function(input, output, session) {
    
    #Returns necessary data for the datatable
    data <- reactive({
      surveyIdentity()
      files()
      
      #Grabbing data from database...
      updateTextInput(session = session, "tabId", label = surveyIdentity())
      performanceData <- dbGetQuery(con, "SELECT * FROM SimulatedCanvasData")
      alterData <- dbGetQuery(con, paste0("SELECT * FROM Person WHERE identifier='", surveyIdentity(), "';"))
       

      datacheck <- reactive({validate(
        need(alterData$networkCanvasUUID, 'No attribute aata found, upload new files or make sure there is data from SQL!'),
        need(performanceData$Login.ID, 'No lms data found, upload new files or make sure there is data from SQL!')
      )})
      datacheck()
      
      #filter and combine both data frames
      joinedData <- inner_join(performanceData,alterData, by = c("Login.ID" = "NetID")) %>% rename(NetID = Login.ID)
      filteredDataAlter <- dplyr::filter(joinedData,  self != "")
      col_remove <- c("nodeID","networkCanvasEgoUUID","contexts_1","know","knowbefore","contexts_2","contexts_3","contexts_4","contexts_5","contexts_6", "First", "Last", "self","X", "x","Category","Class","Title","Views","Participations","Action","Code","Group.Code","Context.Type","Context.ID", "Section", "Section.ID","Team","identifier.x","identifier.y")
      data_new_alter <- filteredDataAlter%>%
        select(- one_of(col_remove))
      dfFin <- unique(data_new_alter)
      
      #reordering the columns
      allData <- dfFin[, c(3, 5, 4, 1, 2)]
      allData2 <- row.names(allData) <- NULL

      return(allData)
    })


    output$table1 = DT::renderDataTable(data(), server = FALSE)
    
    
  })
  
}
