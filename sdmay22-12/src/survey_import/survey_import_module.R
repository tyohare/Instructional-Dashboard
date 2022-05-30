#########
# Author: sdmay22-12 Team
#
# Survey Import Module: Contains the UI and server code for importing survey
# data
#########

library(DT)
library(shinyjs)
library(odbc)
library(DBI)

SurveyImportUI <- function(id) {
  ns <- NS(id)
  useShinyjs()
  
  fluidRow(
    box(
      width = 12,
      div(
        id = "form",
        fileInput(
          ns('file'),
          'Choose file to upload',
          accept = c(".zip")
        ) 
      )
    ),
    uiOutput(ns("importMessage")),
    uiOutput(ns("importActions")),
    tableOutput(ns("filedf"))
  )
}

SurveyImportServer <- function(id, con) {
  moduleServer(
    id,
    function(input, output, session) {
      ns <- session$ns
      
      # Called on successful file browsed
      observeEvent(input$file, {
        output$importActions <- renderUI({})
        output$filedf <- renderTable({})
        output$importMessage <- renderUI({})
        
        if(is.null(input$file)){return()}
        # Unpack zip and store in tempdir()
        infiles <- unzip(input$file$datapath, exdir = tempdir())
        filelist <- unzip(input$file$datapath,list = TRUE)
        check <- list.files(tempdir(),full.names=TRUE,pattern=".csv")
        output$filedf <- renderTable({check})
        # render the import button
        output$importActions <- renderUI({
          box(width = 12,
              textInput(ns("surveyId"), "Survey ID"),
              actionButton(ns("importData"), " Import to Database", icon = icon('database'))
          )
        })
      })
      
      # Called when import button is pressed
      observeEvent(input$importData, {
        # Get all survey ID's from SQL database
        identifiers <- getIdentifiers(con = con)
        # Check if ID already exists in 
        if(!(tolower(input$surveyId) %in% lapply(unlist(identifiers$identifier), tolower))) {
            # Render loading message
            output$importMessage <- renderUI({box(width = 12, status = "primary", paste("Importing data..."))})
            infiles <- unzip(input$file$datapath, exdir = tempdir())
            filelist <- unzip(input$file$datapath,list = TRUE)
            check <- list.files(tempdir(),full.names=TRUE,pattern=".csv")
            for(file in check) {
              data <- read.csv(file, sep = ",", quote = "\"", na = c("", ""))
              data[is.na(data)]<-""
              importCSV(file = file, data = data, con = con, id = input$surveyId)
            }
          
          # Add identifier to data base SuveryIdentifiers table.
          query <- sprintf("Insert into dbo.SurveyIdentifiers (identifier) Values ('%s')", input$surveyId)
          dbSendQuery(con, query)
          
          # Render success message
          output$importMessage <- renderUI({box(width = 12, status = "success", paste("Import Successful"))})
          # Hide actions
          output$importActions <- renderUI({})
          output$filedf <- renderTable({})
        } else {
          output$importMessage <- renderUI({box(width = 12, status = "danger", paste("Survey ID already exists"))})
        }
      })
      
      return (reactive({ input$file }))
    }
  )
}

# Get unique identifiers from database
getIdentifiers <- function(con) {
  ids <- dbGetQuery(con, "Select s.identifier from dbo.SurveyIdentifiers s")
  print("Got identifiers")
  return(ids)
}

# Clean up the CSV Data, wrap text in qoutes
sQuote.df <- function(data, con) {
  df <- mutate_if(data, is.logical, as.character)
  a <- lapply(df, class)
  for (c in 1:ncol(df)) {
    if(a[c] == "character") {
      df[,c] <- dbQuoteString(con, df[,c])
    }
  }
  return(df)
}


importCSV <- function(filename, con, data, id){
  
  # look at file name and determine which table to append data to
  # else throw error
  
  if(grepl("CNL_simulated_canvas.csv", filename)){
    appendToTable(table = 'dbo.SimulatedCanvasData', data = data, con = con, id = id)
  } 
  else if(grepl("attributeList_Person.csv", filename)) {
    appendToTable(table = 'dbo.Person', data = data, con = con, id = id)
  }
  else if(grepl("edgeList_freq_social.csv", filename)) {
    appendToTable(table = 'dbo.Social', data = data, con = con, id = id)
  }
  else if(grepl("edgeList_freq_study.csv", filename)) {
    appendToTable(table = 'dbo.Study', data = data, con = con, id = id)
  }
  else if(grepl("edgeList_Know_strength.csv", filename)) {
    appendToTable(table = 'dbo.KnowStrength', data = data, con = con, id = id)
  }
  else if(grepl("ego.csv", filename)) {
    appendToTable(table = 'dbo.Ego', data = data, con = con, id = id)
  }
  else {
    # TODO: throw file format error
    print("Error in filename.")
  }
}

appendToTable <- function( table, data, con,  id){
  # Add unique server identifier to the dataframe.
  data$identifier <- id
  # Write the query
  append <- sqlAppendTable(con, SQL(table), sQuote.df(data, con = con), row.names = FALSE)
  # Execute the query
  dbExecute(con, append)
  print("Importing file.")
}