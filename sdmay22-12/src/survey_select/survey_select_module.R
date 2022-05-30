#########
# Author: sdmay22-12 Team
#
# Survey Select Module: Contains the UI and server code for fetching survey instances
# for a drop down select
#########

library(odbc)
library(DBI)

SurveySelectUI <- function(id) {
  ns <- NS(id)
  
  fluidRow(
    box(
      width = 12,
      status = "primary",
      actionButton(ns("refreshSurveys"), "Refresh"),
      selectInput(
        ns("surveySelect"), 
        "Survey ID",
        c("None"),
        c("Select a survey."),
      )
    )
  )
}

SurveySelectServer <- function(id, con) {
  moduleServer(
    id,
    function(input, output, session) {
      observeEvent(input$refreshSurveys, {
        
        # Fetch unique survey identifiers
        identifiers <- getIdentifiers(con = con)
        
        # Update survey select list with new options
        updateSelectInput(
          session = session,
          "surveySelect",
          label = "Survey ID",
          choices = unlist(identifiers$identifier),
        )
      })
      
      # Return the survey input as a reactive element
      return(reactive({ input$surveySelect }))
    }
  )
}

getIdentifiers <- function(con) {
  dbGetQuery(con, "Select s.identifier from dbo.SurveyIdentifiers s")
}